<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:import href="jats-preview-xslt/xslt/main/jats-html.xsl"/>
  
  <xsl:param name="transform" as="xs:string">jatskit-html.xsl</xsl:param>
  
  <xsl:param name="css" select="resolve-uri('../web-css/jatskit-simple.css',document-uri(document('')))"/>
  
<!--  -->

<!-- Overriding certain templates to patch jats-html.xsl - these can be pushed upstream! -->
  <xsl:template name="make-html-header">
    <head>
      <title>
        <xsl:variable name="authors">
          <xsl:call-template name="author-string"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space(string($authors))"/>
        <xsl:if test="normalize-space(string($authors))">: </xsl:if>
        <xsl:value-of
          select="(/article/front/article-meta/title-group/article-title,
                   /book/book-meta/book-title-group/book-title[1])[1]"/>
      </title>
      <link rel="stylesheet" type="text/css" href="{$css}"/>
      <!-- When importing jats-oasis-html.xsl, we can call a template to insert CSS for our tables. -->
      <!--<xsl:call-template name="p:table-css" xmlns:p="http://www.wendellpiez.com/oasis-tables/util"/>-->
    </head>
  </xsl:template>
  
  
  <xsl:template name="author-string">
    <xsl:variable name="all-contribs"
      select="(/article/front/article-meta/contrib-group/contrib |
               /book/book-meta/contrib-group/contrib)
            / ( name/surname | collab )"/>
    <xsl:for-each select="$all-contribs">
      <xsl:if test="count($all-contribs) &gt; 1">
        <xsl:if test="position() &gt; 1">
          <xsl:if test="count($all-contribs) &gt; 2">,</xsl:if>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="position() = count($all-contribs)">and </xsl:if>
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:for-each>
  </xsl:template>
  

<!--  -->
  
<!-- Now, amendments to cover 'book' elements. -->
  <xsl:template match="book">
    <!--  (collection-meta*,book-meta?,front-matter?,book-body?,book-back?)  -->
    <xsl:apply-templates/>  
    <div id="{@id/concat(.,'-')}footer" class="footer">
      <xsl:call-template name="footer-metadata"/>
      <xsl:call-template name="footer-branding"/>
    </div>
  </xsl:template>
  
  <xsl:template match="book-meta">
    <div class="metadata book-meta">
      <xsl:apply-templates mode="metadata"/>
    </div>
  </xsl:template>

  <xsl:template match="book-meta/subj-group" mode="metadata">
    <xsl:call-template name="metadata-area">
      <xsl:with-param name="label">Subject assignments</xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="metadata"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-meta/subj-group" mode="metadata">
    <xsl:call-template name="metadata-area">
      <xsl:with-param name="label">Electronic Location Identifier</xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="metadata"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  
<!--book-id book-title-group contrib-group isbn publisher edition pub-history permissions counts-->
  <xsl:template match="book-meta/book-id" mode="metadata">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">
        <xsl:text>Book ID</xsl:text>
        <xsl:for-each select="@book-id-type">
          <xsl:text> (</xsl:text>
          <span class="data">
            <xsl:value-of select="."/>
          </span>
          <xsl:text>)</xsl:text>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-title-group | book-part-meta/title-group" mode="metadata" priority="0.5">
    <xsl:apply-templates mode="metadata"/>
  </xsl:template>
  
  <xsl:template match="book-title" mode="metadata" priority="0.5">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">Title</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  
  <xsl:template match="book-title-group/subtitle" mode="metadata">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">Subtitle</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="trans-title-group" mode="metadata">
    <xsl:apply-templates mode="metadata"/>
  </xsl:template>
  
  <xsl:template match="book-title-group/alt-title" mode="metadata">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">
        <xsl:text>Alternative title</xsl:text>
        <xsl:for-each select="@alt-title-type">
          <xsl:text> (</xsl:text>
          <span class="data">
            <xsl:value-of select="."/>
          </span>
          <xsl:text>)</xsl:text>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-meta/contrib-group" mode="metadata">
    <xsl:call-template name="metadata-area">
      <xsl:with-param name="label">
        <xsl:text>Contributor</xsl:text>
        <xsl:if test="exists(contrib[2])">s</xsl:if>
      </xsl:with-param>
      
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="metadata"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="isbn | issn" mode="metadata" priority="0.5">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">
        <xsl:value-of select="upper-case(local-name())"/>
        <xsl:for-each select="@content-type">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>)</xsl:text>
        </xsl:for-each>
        <xsl:text>:</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-meta/publisher" mode="metadata">
    <xsl:call-template name="metadata-area">
      <xsl:with-param name="label">Publisher</xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="metadata"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-meta/edition" mode="metadata">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">Edition</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-meta/pub-history" mode="metadata">
    <xsl:call-template name="metadata-area">
      <xsl:with-param name="label">Publication history</xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="metadata"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  
  <xsl:template match="pub-history/date" mode="metadata">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">
        <xsl:text>Date</xsl:text>
        <xsl:for-each select="@date-type">
          <xsl:choose>
            <xsl:when test=".='accepted'"> accepted</xsl:when>
            <xsl:when test=".='received'"> received</xsl:when>
            <xsl:when test=".='rev-request'"> revision requested</xsl:when>
            <xsl:when test=".='rev-recd'"> revision received</xsl:when>
            <xsl:otherwise>
              <xsl:text> </xsl:text>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:call-template name="format-date"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-meta/permissions" mode="metadata">
    <xsl:call-template name="metadata-area">
      <xsl:with-param name="label">Rights and permissions</xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="metadata"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  
  
  <xsl:template match="book-meta/* | book-part-meta/*" mode="metadata" priority="0.4">
    <xsl:call-template name="metadata-area">
      <xsl:with-param name="label">
        <xsl:value-of select="local-name()"/>
      </xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="metadata"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  
  
  
  <xsl:template match="front-matter | front-matter/*">
    <div class="{ local-name(.) }">
      <xsl:apply-templates/>
    </div>
    
  </xsl:template>
  <xsl:template match="book-body">
    <xsl:apply-templates/>
    <xsl:apply-templates select="book-part" mode="build-part"/>
  </xsl:template>
  
  <!-- In ordinary traversal, we drop book-parts, so we can control its
       appearance with a 'pull' into mode 'build-part' -->
  <xsl:template match="book-part"/>
  
  <xsl:template match="book-part" mode="build-part">
    <xsl:call-template name="make-book-part"/>
  </xsl:template>
  
  <xsl:template name="make-book-part">
    <xsl:variable name="part-footnotes"
      select="descendant::fn[not(ancestor::front|parent::fn-group|ancestor::table-wrap)]"/>
    
    <!-- Generates a series of (flattened) divs for contents of any
	       article, sub-article or response -->
    
    <!-- book-part (book-part-meta?,front-matter?,body?,back?) -->
    
    <!-- variable to be used in div id's to keep them unique -->
    <xsl:variable name="this">
      <xsl:apply-templates select="." mode="id"/>
    </xsl:variable>
    
    <div class="book-part book-part{count(ancestor-or-self::book-part)}" id="{$this}">
      
    <xsl:apply-templates select="book-part-meta" mode="metadata"/>
    <xsl:apply-templates select="front-matter"/>
    
    
    <!-- body -->
    <xsl:for-each select="body">
      <div id="{$this}-body" class="body">
        <xsl:apply-templates/>
      </div>
    </xsl:for-each>
    
    <xsl:if test="back | $part-footnotes">
      <!-- $loose-footnotes is defined below as any footnotes outside
           front matter or fn-group -->
      <div id="{$this}-back" class="back">
        <xsl:call-template name="make-back"/>
      </div>
    </xsl:if>
    
    <!-- Unlike JATS article or kindred formats, we have no floats or floats-group -->
    
    <!-- more metadata goes in the footer -->
    
    
    <xsl:apply-templates select="body/book-part" mode="build-part"/>
    
    </div>
    
  </xsl:template>
 
 
  
  <xsl:template match="named-content[@content-type=('worktitle','stress')]">
    <i class="{@content-type}">
      <xsl:apply-templates/>
    </i>
  </xsl:template>

  <xsl:variable as="element()*" name="quoted-types">
    <content-type>quoted</content-type>
    <content-type>quote</content-type>
    <content-type>quoted-title</content-type>
    <content-type>called</content-type>
    <content-type>mention</content-type>
  </xsl:variable>
  
  <xsl:template match="named-content[@content-type=$quoted-types]">
    <span class="{@content-type}">
      <xsl:apply-templates select="." mode="left-quote"/>
      <xsl:apply-templates/>
      <xsl:apply-templates select="." mode="right-quote"/>
    </span>
  </xsl:template>
  
  <xsl:template match="named-content[count(ancestor::named-content[@content-type=$quoted-types]) mod 2 = 1]" mode="left-quote">
    <xsl:text>‘</xsl:text></xsl:template>
  
  <xsl:template match="named-content[count(ancestor::named-content[@content-type=$quoted-types]) mod 2 = 1]" mode="right-quote">
    <xsl:text>’</xsl:text>
  </xsl:template>
  
  <xsl:template match="named-content" mode="left-quote">
    <xsl:text>“</xsl:text>
  </xsl:template>
  
  <xsl:template match="named-content" mode="right-quote">
    <xsl:text>”</xsl:text>
  </xsl:template>
  
<!-- For generating a footnotes section when no back matter is present, we have to override
     the imported templates to avoid colliding @ids ...  -->
  <xsl:template name="footnotes">
    <xsl:call-template name="backmatter-section">
      <xsl:with-param name="generated-title">Notes</xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:apply-templates select="$loose-footnotes" mode="footnote"/>
      </xsl:with-param>
      <xsl:with-param name="nominated-id" select="concat(@id,'-footnotes')"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="backmatter-section">
    <xsl:param name="generated-title"/>
    <xsl:param name="contents">
      <xsl:apply-templates/>
    </xsl:param>
    <xsl:param name="nominated-id" select="''"/>
    <div class="back-section">
      <xsl:call-template name="named-anchor">
        <xsl:with-param name="nominated-id" select="$nominated-id"/>
      </xsl:call-template>
      <xsl:if test="not(title) and $generated-title">
        <xsl:choose>
          <!-- The level of title depends on whether the back matter itself
               has a title -->
          <xsl:when test="ancestor::back/title">
            <xsl:call-template name="section-title">
              <xsl:with-param name="contents" select="$generated-title"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="main-title">
              <xsl:with-param name="contents" select="$generated-title"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:copy-of select="$contents"/>
    </div>
  </xsl:template>
  
  <!-- The 'named-anchor' template from jats-html.xsl has a subtle
       bug when applied for a generated section e.g. back matter
       for a 'Notes' section created ad-hoc. Since the context node
       when this template is called is at the top of the book-part,
       we get the book-part's ID, which is no good, since we use it
       for the book-part div.
       So this override permits us to assign an ID in the call. -->
  <xsl:template name="named-anchor">
    <xsl:param name="nominated-id" select="''"/>
    <!-- generates an HTML named anchor -->
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="normalize-space($nominated-id)">
          <xsl:value-of select="$nominated-id"/>
        </xsl:when>
        <xsl:when test="@id">
          <!-- if we have an @id, we use it -->
          <xsl:value-of select="@id"/>
        </xsl:when>
        <xsl:when test="not(preceding-sibling::*) and
          (parent::alternatives | parent::name-alternatives |
          parent::citation-alternatives | parent::collab-alternatives |
          parent::aff-alternatives)/@id">
          <!-- if not, and we are first among our siblings inside one of
               several 'alternatives' wrappers, we use its @id if available -->
          <xsl:value-of select="(parent::alternatives | parent::name-alternatives |
            parent::citation-alternatives | parent::collab-alternatives |
            parent::aff-alternatives)/@id"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- otherwise we simply generate an ID -->
          <xsl:value-of select="generate-id(.)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a id="{$id}">
      <xsl:comment> named anchor </xsl:comment>
    </a>
  </xsl:template>
  
  <xsl:template match="name[@name-style='eastern']">
    <xsl:apply-templates select="prefix, (* except prefix)"/>
  </xsl:template>
  
  <xsl:template match="name">
    <xsl:apply-templates select="prefix, given-names, surname, suffix"/>
  </xsl:template>
  
  <xsl:template match="name/*">
    <xsl:if test="position() gt 1">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  
  
  
  
</xsl:stylesheet>