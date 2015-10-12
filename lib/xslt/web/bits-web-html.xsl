<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ojf="https://github.com/wendellpiez/oXygenJATSframework/ns"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <!-- Should include bits-html.xsl, OASIS table handling -->
  
  <xsl:import  href="../bits-html.xsl"/>

  <xsl:include href="html-util.xsl"/>
  
  <xsl:template match="book">
    <xsl:call-template name="make-html-page">
      <xsl:with-param name="attribute-proxies" as="element()?">
        <xsl:variable name="page-id" select="concat((.//@ojf:split/../@id,@id,'book')[1],'-page')"/>
        <html id="{$page-id}" book="{ojf:book-code(/)}" base="{resolve-uri(concat(ojf:book-code(/),'/contents/',$page-id,'.html'),document-uri(/))}"/>        
      </xsl:with-param>
      <xsl:with-param name="html-contents">
        <xsl:apply-templates select="book-part" mode="build-part"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
</xsl:stylesheet>