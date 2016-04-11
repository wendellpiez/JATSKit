<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:import href="jats-preview-xslt/xslt/main/jats-html.xsl"/>
  
  <xsl:import href="jats-preview-xslt/xslt/oasis-tables/oasis-table-html.xsl"/>
  
  <xsl:param name="p:hard-styles" select="true()" xmlns:p="http://www.wendellpiez.com/oasis-tables/util"/>
</xsl:stylesheet>