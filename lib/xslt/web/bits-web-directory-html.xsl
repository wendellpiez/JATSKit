<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ojf="https://github.com/wendellpiez/oXygenJATSframework/ns"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:include href="html-util.xsl"/>
  
  <xsl:template match="/">
    <xsl:call-template name="make-html-page">
      <xsl:with-param name="attribute-proxies" as="element()?">
        <html id="{ojf:book-code(.)}-directory" base="{resolve-uri(concat(ojf:book-code(/),'/directory.html'),document-uri(/))}"/>        
      </xsl:with-param>
      
      <xsl:with-param name="html-contents"><h1>Boo! a directory</h1></xsl:with-param>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>