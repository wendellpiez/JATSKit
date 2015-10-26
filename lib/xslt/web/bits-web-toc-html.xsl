<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  xmlns:epub="http://www.idpf.org/2007/ops"
  exclude-result-prefixes="xs jatskit"
  version="2.0">

  <xsl:import href="bits-web-html.xsl"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="book"/>
  </xsl:template>
  
  <xsl:template match="book">
    <xsl:call-template name="make-html-page">
      <xsl:with-param name="attribute-proxies" as="element()?">
        <html class="nav">
          <xsl:call-template name="locate-page">
            <xsl:with-param name="page-label"  as="xs:string">toc</xsl:with-param>
            <xsl:with-param name="page-format" as="xs:string">xhtml</xsl:with-param>
          </xsl:call-template>
        </html>        
      </xsl:with-param>      
      <xsl:with-param name="html-contents">
        <xsl:for-each-group select="(book-body | bookback)/book-part" group-by="true()">
          <nav epub:type="toc">
            <xsl:for-each select="/book-meta/title-group/title">
              <h1>
                <xsl:apply-templates/>
                <xsl:text>: Table of Contents</xsl:text>
              </h1>
            </xsl:for-each>
            <ol>
              <xsl:apply-templates select="current-group()" mode="directory"/>
            </ol>
          </nav>
        </xsl:for-each-group>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="*" mode="directory">
   <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="book-part" mode="directory">
    <li>
      <xsl:apply-templates select="." mode="title-link"/>
      <xsl:for-each-group select="*/sec | */book-part" group-by="true()">
        <ol>
          <xsl:apply-templates select="current-group()" mode="#current"/>
        </ol>
      </xsl:for-each-group>
    </li>
  </xsl:template>
  
  <xsl:template match="sec" mode="directory">
    <li>
      <xsl:apply-templates select="." mode="title-link"/>
      <xsl:for-each-group select="sec" group-by="true()">
        <ol>
          <xsl:apply-templates select="current-group()" mode="#current"/>
        </ol>
      </xsl:for-each-group>
    </li>
  </xsl:template>
  
  <xsl:template match="book-part | sec" mode="title-link">
    <xsl:variable name="title" select="book-part-meta/title-group/title | title"/>
    <xsl:apply-templates select="." mode="link-here">
      <xsl:with-param name="path">contents</xsl:with-param>
      <xsl:with-param name="text">
        <xsl:apply-templates select="$title"/>
        <xsl:if test="empty($title)">[Untitled]</xsl:if>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  
  
</xsl:stylesheet>