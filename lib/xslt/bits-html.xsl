<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:import href="jats-preview-xslt/xslt/main/jats-html.xsl"/>
  
  <xsl:param name="transform" as="xs:string">bits-html.xsl</xsl:param>
  
  <xsl:param name="css"       as="xs:string">bits-preview.css</xsl:param>
  
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
  
  
</xsl:stylesheet>