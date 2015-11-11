<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:import href="jats-preview-xslt/xslt/main/jats-html.xsl"/>
  
  <xsl:param name="transform" as="xs:string">jatskit-html.xsl</xsl:param>
  
  <xsl:param name="css" select="resolve-uri('../web-css/jatskit-simple.css',document-uri(document('')))"/>
  
  <xsl:template match="book">
    <!--  (collection-meta*,book-meta?,front-matter?,book-body?,book-back?)  -->
    <xsl:apply-templates/>  
    <div id="{@id/concat(.,'-')}footer" class="footer">
      <xsl:call-template name="footer-metadata"/>
      <xsl:call-template name="footer-branding"/>
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
      
    <xsl:apply-templates select="book-part-meta"/>
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