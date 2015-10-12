<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ojf="https://github.com/wendellpiez/oXygenJATSframework/ns"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:template name="make-html-page">
    <xsl:param name="attribute-proxies" as="element()?"/>
    <xsl:param name="html-contents">
      <xsl:apply-templates/>
    </xsl:param>
    <html>
      <xsl:apply-templates select="$attribute-proxies/@*" mode="html-page-attrs"/>
      <head>
        <title>
          <xsl:for-each select="/descendant::title[1]">
            <xsl:apply-templates mode="plain"/>
          </xsl:for-each>
        </title>
      </head>
      <body>
        <xsl:sequence select="$html-contents"/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="@*" mode="html-page-attrs">
    <xsl:copy-of select="." copy-namespaces="no"/>
  </xsl:template>
  
  <xsl:template match="html/@base" mode="html-page-attrs">
    <!-- Non-standard @base becomes xml:base -->
    <xsl:attribute name="xml:base" select="."/>
  </xsl:template>
  
  <xsl:function name="ojf:book-code" as="xs:string">
    <xsl:param name="doc" as="document-node()"/>
    <xsl:variable name="book-filename" select="replace(document-uri($doc),'^.*/','')"/>
    <xsl:variable name="book-basename" select="replace($book-filename,'\..*$','')"/>
    <xsl:sequence select="$book-basename"/>    
  </xsl:function>

</xsl:stylesheet>