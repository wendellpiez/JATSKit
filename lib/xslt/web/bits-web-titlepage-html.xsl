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
        <html class="apparatus">
          <xsl:call-template name="locate-page">
            <xsl:with-param name="page-label"  as="xs:string">titlepage</xsl:with-param>
            <xsl:with-param name="page-format" as="xs:string">xhtml</xsl:with-param>
          </xsl:call-template>
        </html>        
      </xsl:with-param>      
      <xsl:with-param name="html-contents">
        <div class="titlepage-body">
          <xsl:for-each select="book-meta/book-title-group/book-title">
            <h1>
              <xsl:apply-templates/>
            </h1>
          </xsl:for-each>
          
          <ol>
            <xsl:call-template name="toc-component-links">
              <xsl:with-param name="pages" as="element()*">
                <jatskit:halftitle/>
                <jatskit:toc/>
                <jatskit:colophon/>
              </xsl:with-param>
            </xsl:call-template>
          </ol>
        </div>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
 
  
  
</xsl:stylesheet>