<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <!-- The NLM JATS Preview Stylesheets have a module that does *almost*
       what we need ... everything but MathML is cast into the XHTML
       namespace. -->
  <xsl:import href="../jats-preview-xslt/xslt/post/xhtml-ns.xsl"/>
  
  <!-- We want to keep the jatskit namespace, to head off any confusion. -->
  <xsl:template match="jatskit:*">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>