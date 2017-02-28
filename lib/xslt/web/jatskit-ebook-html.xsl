<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <!-- Should include bits-html.xsl, OASIS table handling -->
  
  <xsl:import  href="../jatskit-html.xsl"/>

  <xsl:include href="jatskit-util.xsl"/>

  <!-- Inside jatskit-util.xsl: <xsl:param name="format" as="xs:string">epub</xsl:param> -->

  <xsl:variable name="auto-label-app"              select="true()"/>
  <xsl:variable name="auto-label-boxed-text"       select="true()"/>
  <xsl:variable name="auto-label-chem-struct-wrap" select="true()"/>
  <xsl:variable name="auto-label-disp-formula"     select="true()"/>
  <xsl:variable name="auto-label-fig"              select="true()"/>
  <xsl:variable name="auto-label-ref"              select="not(//ref[label])"/>
  <!-- ref elements are labeled unless any ref already has a label -->
  <xsl:variable name="auto-label-statement"        select="false()"/>
  <xsl:variable name="auto-label-supplementary"    select="true()"/>
  <xsl:variable name="auto-label-table-wrap"       select="true()"/>
  
  <!-- Overriding the imported one, just in case. -->
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="jatskit:book-sequence">
    <jatskit:page-sequence>
      <xsl:apply-templates/>
    </jatskit:page-sequence>
  </xsl:template>
  
  <xsl:template match="book">
    <!-- $discrete-part is true iff there is only a single top-level book-part for the book -
         which should be the case when the input has been split. -->
    <xsl:variable name="single-part" select=".[count(*/book-part) eq 1]/*/book-part"/>
    <xsl:call-template name="make-html-page">
      <xsl:with-param name="attribute-proxies" as="element()?">
        <html id="{jatskit:page-id(.)}" base="{jatskit:page-path(.)}"/>
      </xsl:with-param>
      <xsl:with-param name="page-title">
        <xsl:sequence select="$show-book-title"/>
        <xsl:for-each select="$single-part">
          <xsl:text>: </xsl:text>
          <xsl:apply-templates select="." mode="link-text"/>
        </xsl:for-each>
      </xsl:with-param>
      <xsl:with-param name="html-contents">
        <xsl:for-each select="$single-part[not($format = 'epub')]">
          <xsl:call-template name="web-navigation"/>
        </xsl:for-each>
        <xsl:apply-templates select="*/book-part" mode="build-part"/>
        <xsl:for-each select="$single-part[not($format = 'epub')]">
          <xsl:call-template name="web-navigation"/>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <!-- The context for $web-navigation should be a book-part. -->
  
  <xsl:template name="web-navigation">
    <xsl:variable name="here"  select="self::book-part"/>
    <xsl:variable name="first" select="empty($here/preceding::book-part)"/>
    <xsl:variable name="last"  select="empty($here/following::book-part)"/>
    <table class="navigation" style="width:100%">
      <tr>
        <td colspan="3" style="text-align:center; font-weight: bold">
          <xsl:for-each select="ancestor::book/book-meta/book-title-group/book-title">
            <xsl:apply-templates/>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <xsl:for-each select="preceding::book-part[1]">
          <!-- If there is a following book-part in another book, split from this one. --> 
          <td width="{if (not($last)) then '30%' else '50%'}">
            <span class="label">Back: </span>
            <xsl:apply-templates select="." mode="link-here">
              <xsl:with-param name="text">
                <xsl:apply-templates select="book-part-meta/title-group/title" mode="link-text"/>
              </xsl:with-param>
              <xsl:with-param name="path">../contents</xsl:with-param>
            </xsl:apply-templates>
          </td>
        </xsl:for-each>
        <td style="text-align: {if ($first) then 'left' else if ($last) then 'right' else 'center'}">
          <span class="label">
          <xsl:call-template name="jatskit-component-link">
            <xsl:with-param name="page" as="element()">
              <jatskit:toc/>
            </xsl:with-param>
          </xsl:call-template>
          </span>
<!--          <a href="{$path-to-root}/{jatskit:book-code(/)}-toc.xhtml">Contents</a>-->
        </td>
        <xsl:for-each select="following::book-part[1]">
          <!-- If there is a following book-part in another book, split from this one. --> 
          <td width="{if (not($first)) then '30%' else '50%'}" style="text-align: right">
            <span class="label">Next: </span>
            <xsl:apply-templates select="." mode="link-here">
              <xsl:with-param name="text">
                <xsl:apply-templates select="book-part-meta/title-group/title" mode="link-text"/>
              </xsl:with-param>
              <xsl:with-param name="path">../contents</xsl:with-param>
            </xsl:apply-templates>
          </td>
        </xsl:for-each>
      </tr>
    </table>
  </xsl:template>


  <!-- Rewriting graphic links to point to destination location. -->
  
  <xsl:template match="graphic | inline-graphic">
    <xsl:variable name="filename" select="replace(@xlink:href,'^.*/','')"/>
    <xsl:apply-templates/>
    <img alt="{$filename}">
      <xsl:attribute name="src">
        <xsl:text>../graphics/</xsl:text>
        <xsl:value-of select="$filename"/>
      </xsl:attribute>
      <xsl:for-each select="alt-text">
        <xsl:attribute name="alt">
          <xsl:value-of select="normalize-space(string(.))"/>
        </xsl:attribute>
      </xsl:for-each>
    </img>
  </xsl:template>
  
  <!--<xsl:template match="graphic/@xlink:href">
    
  </xsl:template>
  -->

  <xsl:template match="book-part/book-part-meta/title-group/title">
    <xsl:if test="normalize-space(string(.))">
      <header>
        <h1 class="title">
        <xsl:apply-templates/>
      </h1>
      </header>
    </xsl:if>
  </xsl:template>

  <xsl:template name="section-title" match="sec/title">
    <xsl:param name="contents">
      <xsl:apply-templates/>
    </xsl:param>   
    <xsl:if test="normalize-space(string($contents))">
      <!-- coding defensively since empty titles make glitchy HTML -->
      <header>
      <h1 class="section-title">
        <xsl:copy-of select="$contents"/>
      </h1>
      </header>
    </xsl:if>
  </xsl:template>
  
  <!-- xref becomes a no-op unless its @rid points to a single @id. -->
  <xsl:template match="xref">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="xref[@rid = //@id]">
    <xsl:variable name="target" select="key('element-by-id',@rid)"/>
    <xsl:apply-templates select="$target" mode="link-here">
      <xsl:with-param name="path">../contents</xsl:with-param>
      <!-- Unlike other links, here we want the contents of the xref, not any generated text,
           as the link text.
           (For special handling, modify the xref coming in, in XSLT bits-fixup.xsl.) -->
      <xsl:with-param name="text">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="*" mode="link-here">
    <xsl:param name="path" select="$path-to-root"/>
    <xsl:param name="text">
      <xsl:apply-templates select="." mode="link-text"/>
    </xsl:param>
    <xsl:variable name="href">
      <xsl:apply-templates select="ancestor-or-self::*[exists(@jatskit:split)][1]" mode="id"/>
      <xsl:text>-page.xhtml</xsl:text>
      <!-- We point the link deeper into the file only if not splitting here. -->
      <xsl:if test="empty(@jatskit:split)">
        <xsl:text>#</xsl:text>
        <xsl:apply-templates select="." mode="id"/>
      </xsl:if>
    </xsl:variable>
    <a href="{string-join(($path,$href),'/')}">
      <xsl:sequence select="$text"/>
    </a>
  </xsl:template>
  
  <xsl:template match="sec" mode="link-text">
    <xsl:for-each select="title">
      <xsl:apply-templates mode="link-text"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="book-part" mode="link-text">
    <xsl:for-each select="book-meta/title-group/title">
      <xsl:apply-templates mode="link-text"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="boxed-text | chem-struct-wrap | disp-formula-group | fig | fig-group |
    graphic | media | supplementary-material | table-wrap | table-wrap-group" mode="link-text">
    <xsl:apply-templates select="." mode="label-text"/>
    <xsl:apply-templates select="caption/title"/>
  </xsl:template>
  
  
  <xsl:template name="toc-component-links">
    <xsl:param name="pages" as="element()+"/>
    <xsl:variable name="book-code" select="jatskit:book-code(/)"/>
    <xsl:for-each select="$pages">
      <li>
        <xsl:call-template name="jatskit-component-link">
          <xsl:with-param name="page" select="."/>
          <xsl:with-param name="book-code" select="$book-code"/>
        </xsl:call-template>
      </li>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="jatskit-component-link">
    <xsl:param name="page" as="element()"/>
    <xsl:param name="book-code" select="jatskit:book-code(.)"/>
    <a href="{$path-to-root}/{$book-code}-{local-name($page)}.xhtml">
      <xsl:apply-templates select="$page" mode="component-title"/>
    </a>
  </xsl:template>
  
  <xsl:template match="jatskit:toc" mode="component-title">Contents</xsl:template>
  
  <xsl:template match="jatskit:titlepage" mode="component-title">Title page</xsl:template>
  
  <xsl:template match="jatskit:halftitle" mode="component-title">Metadata</xsl:template>
  
  <xsl:template match="jatskit:colophon" mode="component-title">Colophon</xsl:template>
  
  <xsl:template match="book-id" mode="metadata">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">
        <xsl:choose>
          <xsl:when test="@book-id-type='art-access-id'">Accession ID</xsl:when>
          <xsl:when test="@book-id-type='coden'">Coden</xsl:when>
          <xsl:when test="@book-id-type='doi'">DOI</xsl:when>
          <xsl:when test="@book-id-type='manuscript'">Manuscript ID</xsl:when>
          <xsl:when test="@book-id-type='medline'">Medline ID</xsl:when>
          <xsl:when test="@book-id-type='pii'">Publisher Item ID</xsl:when>
          <xsl:when test="@book-id-type='pmid'">PubMed ID</xsl:when>
          <xsl:when test="@book-id-type='publisher-id'">Publisher ID</xsl:when>
          <xsl:when test="@book-id-type='sici'">Serial Item and Contribution ID</xsl:when>
          <xsl:when test="@book-id-type='doaj'">DOAJ ID</xsl:when>
          <xsl:when test="@book-id-type='arXiv'">arXiv.org ID</xsl:when>
          <xsl:otherwise>
            <xsl:text>Book ID</xsl:text>
            <xsl:for-each select="@pub-id-type">
              <xsl:text> (</xsl:text>
              <span class="data">
                <xsl:value-of select="."/>
              </span>
              <xsl:text>)</xsl:text>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-title-group" mode="metadata">
    <!-- content model:
    article-title, subtitle*, trans-title-group*, alt-title*, fn-group? -->
    <!-- trans-title and trans-subtitle included for 2.3 -->
    <xsl:apply-templates select="*" mode="metadata"/>
  </xsl:template>
  
  
  <xsl:template match="book-title-group/book-title" mode="metadata">
    <h1 class="book-title">
      <xsl:apply-templates/>
      <xsl:if test="../subtitle">:</xsl:if>
    </h1>
  </xsl:template>
  
  
  <xsl:template match="book-title-group/subtitle | book-trans-title-group/subtitle"
    mode="metadata">
    <h2 class="book-title">
      <xsl:apply-templates/>
    </h2>
  </xsl:template>
  
  
  <xsl:template match="book-title-group/trans-title-group" mode="metadata">
    <!-- content model: (trans-title, trans-subtitle*) -->
    <xsl:apply-templates mode="metadata"/>
  </xsl:template>
  
  
  
  <xsl:template match="book-title-group/alt-title" mode="metadata">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">
        <xsl:text>Alternative title</xsl:text>
        <xsl:for-each-group select="@alt-title-type | @xml:lang" group-by="true()">
          <xsl:text> (</xsl:text>
          <span class="data">
            <xsl:value-of select="current-group()" separator=", "/>
          </span>
          <xsl:text>)</xsl:text>
        </xsl:for-each-group>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  
  <xsl:template match="book-title-group/fn-group" mode="metadata">
    <xsl:apply-templates/>
  </xsl:template>
  
</xsl:stylesheet>