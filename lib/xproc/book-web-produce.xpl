<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  xmlns:pxp="http://exproc.org/proposed/steps"
  xmlns:pxf="http://exproc.org/proposed/steps/file"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">

  <p:option name="debug" select="false()"/>
  
  <p:input port="source"/>
  
  <p:input port="parameters" kind="parameter"/>

  <!--<p:output port="result"/>-->
  
  <p:import href="book-web-sequence.xpl"/>
  
  <!--<p:variable name="result-basedir" select="resolve-uri('web',document-uri(/))"/>-->

  <p:declare-step type="pxf:copy">
    <p:output port="result" primary="false"/>
    <p:option name="href" required="true"/>                       <!-- anyURI -->
    <p:option name="target" required="true"/>                     <!-- boolean -->
    <p:option name="fail-on-error" select="'true'"/>              <!-- boolean -->
  </p:declare-step>

  <!-- The subpipeline produces a set of HTML files including Title page, ToC and colophon. -->
  <jatskit:book-web-sequence name="web-sequence">
    <p:with-option name="target-format" select="'web'"/>
  </jatskit:book-web-sequence>
  
  <!-- Hey having specified that, we are all set up to serialize and copy resources
       here and there. -->

  <p:for-each>
    <p:iteration-source>
      <!-- page-sequence is the bare HTML pages -->
      <p:pipe step="web-sequence" port="page-sequence"/>
      <!-- Additionally, there are top-level files such as title page and what not. -->
      <p:pipe step="web-sequence" port="apparatus"/>
    </p:iteration-source>
    
    <p:store>
      <p:with-option name="method" select="'xml'" />
      <p:with-option name="href" select="base-uri(/)" />
    </p:store>
  </p:for-each>
  
  <!-- Next we produce a graphics list and iterate over its
       members in order to copy graphics over. -->
  <p:identity name="graphics-list">
    <p:input port="source">
      <p:pipe step="web-sequence" port="graphics-manifest"/>
    </p:input>
  </p:identity>
  
  <p:for-each name="store-graphics">
    <p:iteration-source select="/*/jatskit:graphic"/>
    <!--<p:identity/>-->
    <pxf:copy>
      <p:with-option name="href" select="/*/@href"/>
      <p:with-option name="target" select="/*/@target"/>
    </pxf:copy>
  </p:for-each>

<!-- And then having done that, we do the same for a manifest
     of any static resources we need. (At time of writing only CSS,
     but this could include branding, javascript etc.) -->
  <p:identity name="support-file-list">
    <p:input port="source">
      <p:pipe step="web-sequence" port="support-manifest"/>
    </p:input>
  </p:identity>
  
  <p:for-each name="store-support-files">
    <p:iteration-source select="/*/jatskit:*"/>
    <!--<p:identity/>-->
    <pxf:copy>
      <p:with-option name="href" select="/*/@href"/>
      <p:with-option name="target" select="/*/@target"/>
    </pxf:copy>
  </p:for-each>
  
</p:declare-step>