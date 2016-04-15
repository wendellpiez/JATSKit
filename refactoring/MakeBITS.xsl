<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!--<!DOCTYPE book
  PUBLIC "-//NLM//DTD BITS Book Interchange DTD with OASIS and XHTML Tables v2.0 20151225//EN"
  "BITS-book2.dtd">
  -->
  
  <xsl:output
    doctype-system="BITS-book2.dtd"
    doctype-public="-//NLM//DTD BITS Book Interchange DTD with OASIS and XHTML Tables v2.0 20151225//EN"/>
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <!-- Assigning these namespace everywhere so their declarations float to the top. -->
      <xsl:namespace name="xlink">http://www.w3.org/1999/xlink</xsl:namespace>
      <xsl:namespace name="mml">http://www.w3.org/1998/Math/MathML</xsl:namespace>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
      
      
  <xsl:template match="book/@dtd-version">
    <xsl:attribute name="dtd-version">2.0</xsl:attribute>
  </xsl:template>
  
</xsl:stylesheet>