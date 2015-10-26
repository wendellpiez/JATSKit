<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <!-- Should include bits-html.xsl, OASIS table handling -->
  
  <xsl:import  href="../bits-html.xsl"/>

  <xsl:include href="jatskit-util.xsl"/>


  <xsl:variable name="auto-label-app"              select="true()"/>
  <xsl:variable name="auto-label-boxed-text"       select="true()"/>
  <xsl:variable name="auto-label-chem-struct-wrap" select="true()"/>
  <xsl:variable name="auto-label-disp-formula"     select="true()"/>
  <xsl:variable name="auto-label-fig"              select="true()"/>
  <xsl:variable name="auto-label-ref"              select="not(//ref[label])"/>
  <!-- ref elements are labeled unless any ref already has a label -->
  <xsl:variable name="auto-label-statement"        select="true()"/>
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
    <xsl:call-template name="make-html-page">
      <xsl:with-param name="attribute-proxies" as="element()?">
        <html id="{jatskit:page-id(.)}" base="{jatskit:page-path(.)}"/>        
      </xsl:with-param>
      <xsl:with-param name="page-title">
          <xsl:apply-templates select="book-meta/book-title-group/book-title" mode="plain"/>
          <xsl:if test="count(*/book-part) eq 1">
            <xsl:for-each  select="descendant::book-part/book-part-meta/title-group/title">
            <xsl:text>: </xsl:text>
            <xsl:apply-templates select="." mode="plain"/>
            </xsl:for-each>
          </xsl:if>
        
      </xsl:with-param>
      <xsl:with-param name="html-contents">
        <xsl:apply-templates select="*/book-part" mode="build-part"/>
      </xsl:with-param>
    </xsl:call-template>
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

  <!-- xref becomes a no-op unless its @rid points to a single @id. -->
  <xsl:template match="xref">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="xref[@rid = //@id]">
    <xsl:variable name="target" select="key('element-by-id',@rid)"/>
    <xsl:apply-templates select="$target" mode="link-here">
      <xsl:with-param name="path">../contents</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="*" mode="link-here">
    <xsl:param name="path"/>
    <xsl:param name="text">
      <xsl:apply-templates select="." mode="link-text"/>
    </xsl:param>
    <xsl:variable name="href">
      <xsl:apply-templates select="ancestor-or-self::*[exists(@jatskit:split)][1]" mode="id"/>
      <xsl:text>-page.xhtml#</xsl:text>
      <xsl:apply-templates select="." mode="id"/>
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
    <xsl:for-each select="book-meta/book-title-group/title">
      <xsl:apply-templates mode="link-text"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="boxed-text | chem-struct-wrap | disp-formula-group | fig | fig-group |
    graphic | media | supplementary-material | table-wrap | table-wrap-group" mode="link-text">
    <xsl:apply-templates select="." mode="label-text"/>
    <xsl:apply-templates select="caption/title"/>
  </xsl:template>
  
</xsl:stylesheet>