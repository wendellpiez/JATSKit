<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  exclude-result-prefixes="xlink">
  
  <xsl:import href="jats-preview-xslt/xslt/main/jats-xslfo.xsl"/>
  
  <xsl:template match="book">
    <fo:page-sequence master-reference="cover-sequence" force-page-count="even">
      <xsl:call-template name="define-footnote-separator"/>
      <fo:flow flow-name="body">
        <fo:block line-stacking-strategy="font-height"
          line-height-shift-adjustment="disregard-shifts">
          <xsl:call-template name="set-book-cover-page"/>
        </fo:block>
      </fo:flow>
    </fo:page-sequence>
    
    <!-- We hop over the wrappers so our selected elements have position
         in sequence ... -->
    <xsl:apply-templates select="front-matter/*, book-body/*, book-back"/>
    
    <!-- produce document diagnostics after the end of 
       the article; this has a page sequence in it
       and all else needed -->
    <xsl:call-template name="run-diagnostics"/>
  </xsl:template>
  
  <xsl:template name="set-book-cover-page">
    <!--should account for collection-meta and book-meta -->
    <!--<xsl:text>Boo!</xsl:text>-->
    <xsl:apply-templates select="collection-meta | book-meta" mode="grid"/>
  </xsl:template>

  <xsl:template match="front-matter/* | book-body/* | book-back">
    
  <!-- Populate the content sequence -->
  
  
  <fo:page-sequence master-reference="content-sequence">
    <xsl:if test="position() eq 1">
      <xsl:attribute name="initial-page-number">1</xsl:attribute>
    </xsl:if>
    
    <fo:static-content flow-name="recto-header">
      <fo:block xsl:use-attribute-sets="page-header">
        <xsl:call-template name="make-page-header">
          <xsl:with-param name="face" select="'recto'"/>
        </xsl:call-template>
      </fo:block>
    </fo:static-content>
    <fo:static-content flow-name="verso-header">
      <fo:block xsl:use-attribute-sets="page-header">
        <xsl:call-template name="make-page-header">
          <xsl:with-param name="face" select="'verso'"/>
        </xsl:call-template>
      </fo:block>
    </fo:static-content>
    <xsl:call-template name="define-footnote-separator"/>
    <fo:flow flow-name="body">
      <fo:block line-stacking-strategy="font-height"
        line-height-shift-adjustment="disregard-shifts"
        widows="2" orphans="2">
        
        <!-- set the article opener, body, and backmatter -->
        <!--<xsl:call-template name="set-article-opener"/>-->
        <xsl:call-template name="set-book-part-opener"/>
        
        <!--<xsl:call-template name="set-article"/>-->
        <xsl:apply-templates/>
        
      </fo:block>
      
    </fo:flow>
  </fo:page-sequence>
  </xsl:template>
  
<!-- modified from set-article-opener -->
  <xsl:template name="set-book-part-opener">
    <xsl:for-each select="book-part-meta">
      <fo:block>
        <xsl:call-template name="set-copyright-note"/>
        <xsl:apply-templates select="title-group"/>
        <xsl:call-template name="set-correspondence-note"/>
      </fo:block>
      
      <xsl:call-template name="banner-rule"/>
      
      <fo:block xsl:use-attribute-sets="contrib-block">
        <xsl:apply-templates select="contrib-group"/>
        <xsl:apply-templates select="aff | aff-alternatives/aff" mode="contrib"/>
        <xsl:apply-templates select="author-notes"/>
      </fo:block>
      
      <xsl:variable name="abstracts"
        select="abstract[not(@abstract-type='toc')] |
        trans-abstract[not(@abstract-type='toc')]"/>
      
      <xsl:if test="$abstracts">
        <xsl:call-template name="banner-rule"/>
      </xsl:if>
      <xsl:apply-templates select="$abstracts"/>
      
      <xsl:call-template name="banner-rule"/>
      
      <!-- content model:
        
        (book-part-id*, subj-group*, title-group?, (contrib-group | aff | aff-alternatives | x)*,
        author-notes?, pub-date*, edition*, issn*, issn-l?, isbn*, publisher*, ((fpage, lpage?) |
        elocation-id)?, supplementary-material*, pub-history*, permissions?, self-uri*, (related-article | related-object)*, (abstract)*, trans-abstract*, (kwd-group)*, funding-group*, conference*, counts?, custom-meta-group*, (notes)*)-->
      
    </xsl:for-each>
  </xsl:template>
  
<!-- Mode 'grid' generates a nested grid for metadata structured according to the native XML,
     labelled with formal names (from the Tag Library) -->
  
<!-- Overriding the imported stylesheet -->
  <xsl:template name="page-header-title">
    <xsl:variable name="running-head-title"
      select="(/article/front/article-meta | /book/book-meta)/
                 (title-group|book-title-group)/
                 (alt-title[@alt-title-type='running-head'],
                  article-title, book-title)[1]"/>
    <xsl:for-each select="$running-head-title">
      <xsl:apply-templates mode="page-header-text"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:variable name="element-names" select="document('taglib-names.xml')/*/element"/>
  
  <xsl:template mode="grid" match="*">
    <xsl:variable name="n" select="name()"/>
    <fo:block xsl:use-attribute-sets="metadata-grid">
      <fo:block xsl:use-attribute-sets="label generated smaller">
        <xsl:value-of select="$element-names[@gi=$n]"/>
        <xsl:call-template name="attribute-string"/>
      </fo:block>
      <xsl:apply-templates mode="#current"/>
    </fo:block>
  </xsl:template>
  
  <!-- Matches anything with a non-whitespace-only text node *child* -->
  <xsl:template mode="grid" match="*[some $t in text() satisfies matches($t,'\S')]">
    <xsl:variable name="n" select="name()"/>
    <fo:block xsl:use-attribute-sets="metadata-grid">
      <fo:inline xsl:use-attribute-sets="generated"><xsl:value-of select="$element-names[@gi=$n]"/>: </fo:inline>
      <!-- Falling out of mode to format anything inline. -->
      <xsl:apply-templates/>
      <xsl:variable name="attribute-string">
        <xsl:call-template name="attribute-string"/>
      </xsl:variable>
      <xsl:if test="matches($attribute-string,'\S')">
        <fo:inline xsl:use-attribute-sets="generated smaller"><xsl:sequence select="$attribute-string"/></fo:inline>
      </xsl:if>
    </fo:block>
  </xsl:template>
  
  <xsl:template name="attribute-string">
    <!-- Tests true if any attribute has a value not whitespace. -->
    <xsl:if test="@*/matches(.,'\S')">
      <xsl:text> [</xsl:text>
      <xsl:for-each select="@*[matches(.,'\S')]">
        <xsl:if test="position() gt 1">; </xsl:if>
        <xsl:value-of select="name()"/>
        <xsl:text>=</xsl:text>
        <xsl:value-of select="."/>
      </xsl:for-each>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="grid" match="p | license-p" priority="1">
    <fo:block xsl:use-attribute-sets="metadata-grid">
      <!-- Falling out of mode to format anything inline. -->
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>
  
  <xsl:attribute-set name="metadata-grid">
    <xsl:attribute name="margin-left">1em</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="smaller">
    <xsl:attribute name="font-size">90%</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="generated">
    <xsl:attribute name="font-size">90%</xsl:attribute>
    <xsl:attribute name="font-family">sans-serif</xsl:attribute>
    <xsl:attribute name="color">midnightblue</xsl:attribute>
  </xsl:attribute-set>
  
<!-- Overriding the template imported from xhtml-tables-fo.xsl.  -->
  <xsl:template name="process-common-attributes">
    <xsl:if test="not(self::colgroup | self::col)">
      <xsl:attribute name="role">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
    </xsl:if>
    
    <xsl:copy-of select="@xml:lang"/>
    <xsl:for-each select="@lang">
      <xsl:attribute name="xml:lang">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:for-each>
    
    <xsl:for-each select="self::a/@name">
      <xsl:attribute name="id">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:for-each>
    <xsl:copy-of select="@id"/>
    
    <!-- (following is verbatim AH code -->
    <xsl:if test="@align">
      <xsl:choose>
        <xsl:when test="self::caption"/>
        
        <xsl:when test="self::img or self::object">
          <xsl:if test="@align = 'bottom' or @align = 'middle' or @align = 'top'">
            <xsl:attribute name="vertical-align">
              <xsl:value-of select="@align"/>
            </xsl:attribute>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="process-cell-align">
            <xsl:with-param name="align" select="@align"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="@valign">
      <xsl:call-template name="process-cell-valign">
        <xsl:with-param name="valign" select="@valign"/>
      </xsl:call-template>
    </xsl:if>
    
    <xsl:if test="@style">
      <xsl:call-template name="process-style">
        <xsl:with-param name="style" select="@style"/>
      </xsl:call-template>
    </xsl:if>
    
  </xsl:template>
  
</xsl:stylesheet>