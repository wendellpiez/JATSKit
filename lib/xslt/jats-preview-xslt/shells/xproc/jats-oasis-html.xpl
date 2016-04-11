<?xml version="1.0" encoding="UTF-8"?>
<!--                                                                -->
<!-- =============================================================  -->
<!--  MODULE:    XProc pipeline                                     -->
<!--  DATE:      January 2014                                       -->
<!--                                                                -->
<!-- =============================================================  -->
<!--                                                                -->
<!-- =============================================================  -->
<!--  SYSTEM:    NISO 1.0 JATS (Journal Article Tag Set)            -->
<!--                                                                -->
<!--  PURPOSE:   Pipelines stylesheets to convert                   -->
<!--             NISO JATS XML for preview                          -->
<!--                                                                -->
<!--  PROCESSOR DEPENDENCIES:                                       -->
<!--             An XProc processor supporting XSLT 2.0             -->
<!--             Tested using Calabash 1.0.16-95                    -->
<!--                                                                -->
<!--  COMPONENTS REQUIRED:                                          -->
<!--             XSLT stylesheets named in input ports              -->
<!--                                                                -->
<!--  INPUT:     NISO JATS 3.0 XML                                  -->
<!--             Also supports NLM 3.0                              -->
<!--             and NLM 2.3 (with some limitations)                -->
<!--                                                                -->
<!--  OUTPUT:    HTML, XHTML or XSL-FO, as indicated in the         -->
<!--             final step                                         -->
<!--                                                                -->
<!--  CREATED FOR:                                                  -->
<!--             Digital Archive of Journal Articles                -->
<!--             National Center for Biotechnology Information  (NCBI)     -->
<!--             National Library of Medicine (NLM)                 -->
<!--                                                                -->
<!--  CREATED BY:                                                   -->
<!--             Wendell Piez, http://www.wendellpiez.com           -->
<!--                                                                -->
<!-- =============================================================  -->
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
<!-- =============================================================  -->

<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  version="1.0">

  <p:serialization port="result" encoding="utf-8" indent="true"/>

  <p:input port="source"/>

  <p:input port="parameters" kind="parameter"/>

  <p:output port="result"/>

  <p:xslt name="oasis-tables-to-html" version="2.0">
    <!-- convert OASIS tables to HTML, copying everything else -->
    <p:input port="stylesheet">
      <p:document href="../../xslt/prep/oasis-tables-only-html.xsl"/>
    </p:input>
  </p:xslt>
  
  
  <p:xslt name="display-html" version="1.0">
    <!-- convert into HTML for display -->
    <p:with-param name="transform" select="'jats-oasis-html.xpl'"/>
    <p:input port="stylesheet">
      <p:document href="../../xslt/main/jats-html.xsl"/>
    </p:input>
  </p:xslt>

  <!-- Since Calabash, the XProc processor, fails to emit an HTML 'meta' element
       on serializing HTML, we do so by hand. -->
  <p:xslt name="insert-encoding-meta">
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

          <xsl:template match="*">
            <xsl:copy>
              <xsl:apply-templates select="node() | @*"/>
            </xsl:copy>
          </xsl:template>

          <xsl:template match="html/head">
            <xsl:copy>
              <xsl:copy-of select="@*"/>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
              <xsl:copy-of select="node()"/>
            </xsl:copy>
          </xsl:template>

          <xsl:template match="html/body">
            <xsl:copy-of select="."/>
          </xsl:template>

        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  
</p:declare-step>
