<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  exclude-result-prefixes="xs"
  version="2.0">
  
<!-- This stylesheet should be extended or forked to provide for local conversion logic into JATS. -->

  <!--
    
  <!DOCTYPE article
    PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Publishing DTD with OASIS Tables with MathML3 v1.1 20151215//EN"
           "JATS-journalpublishing-oasis-article1-mathml3.dtd">

  <article dtd-version="1.1"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mml="http://www.w3.org/1998/Math/MathML">
...
    
  -->
  
  <xsl:output
    doctype-system="JATS-journalpublishing-oasis-article1-mathml3.dtd"
    doctype-public="-//NLM//DTD JATS (Z39.96) Journal Publishing DTD with OASIS Tables with MathML3 v1.1 20151215//EN"/>
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:namespace name="xlink">http://www.w3.org/1999/xlink</xsl:namespace>
      <xsl:namespace name="mml">http://www.w3.org/1998/Math/MathML</xsl:namespace>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="article/@dtd-version">
    <xsl:attribute name="dtd-version">1.1</xsl:attribute>
  </xsl:template>
  
</xsl:stylesheet>