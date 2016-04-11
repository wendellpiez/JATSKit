<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  This work is in the public domain and may be reproduced, published or 
  otherwise used without the permission of the National Library of Medicine (NLM).
  
  We request only that the NLM is cited as the source of the work.
  
  Although all reasonable efforts have been taken to ensure the accuracy and 
  reliability of the software and data, the NLM and the U.S. Government  do 
  not and cannot warrant the performance or results that may be obtained  by
  using this software or data. The NLM and the U.S. Government disclaim all 
  warranties, express or implied, including warranties of performance, 
  merchantability or fitness for any particular purpose.
-->
<!-- ============================================================= -->
<!--  Function of this stylesheet:

       This stylesheet copies input, processing (only) OASIS table
       elements into (unnamespaced) HTML. For XHTML, add a postprocessing
       step calling xhtml-ns.xsl. -->
      
      

<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:oasis="http://www.niso.org/standards/z39-96/ns/oasis-exchange/table"
  xmlns:p="http://www.wendellpiez.com/oasis-tables/util"
  exclude-result-prefixes="#all">
  
  <xsl:import href="../oasis-tables/oasis-table-html.xsl"/>

  <!-- $p:hard-styles should be true() if CSS styles should be presented locally on table elements. -->
  <!-- Alternatively, call template 'p:table-css' into the HTML header to provide CSS for 'soft'
       (i.e. class-driven) styling for table cells. -->
  <xsl:param name="p:hard-styles" select="true()"/>
  
  <xsl:template match="oasis:* | p:*" priority="2">
    <xsl:apply-imports/>
  </xsl:template>
  
  <xsl:template match="node() | @*">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="html/head">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
      <!-- Since styles are 'soft' by default, we call the template that inserts CSS for
           table elements. -->
      <xsl:call-template name="p:table-css"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
