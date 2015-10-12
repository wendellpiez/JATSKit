<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:ojf="https://github.com/wendellpiez/oXygenJATSframework/ns"
  xmlns:pxp="http://exproc.org/proposed/steps"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
  <!--
  
  -->
  <p:input  port="source"/>
  
  <p:input port="parameters" kind="parameter"/>
  
  <p:import href="book-web-sequence.xpl"/>
  
  <p:variable name="result-basedir" select="resolve-uri('web',document-uri(/))"/>

  
  <!-- The subpipeline produces a set of HTML files including Title page, ToC and colophon. -->
  <ojf:book-web-sequence name="web-sequence"/>
  
  <!--<p:sink/>-->
  
  <!--<p:store name="directory">
    <p:with-option name="href" select="string-join(($result-basedir,'directory.html'),'/')"/>
    <p:input port="source">
      <p:pipe step="web-sequence" port="directory-page"/>
    </p:input>
  </p:store>-->
  
  <p:for-each name="scrubbed-fileset">
    <p:iteration-source>
      <p:pipe step="web-sequence" port="page-sequence"/>
      <p:pipe step="web-sequence" port="apparatus"/>
    </p:iteration-source>
    <p:xslt name="scrubbed">
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            version="2.0">
            <!--<xsl:param name="source-filename" required="yes"/>
            <xsl:variable name="base-dir" select="concat(replace($source-filename,'\..*$',''),'/')"/>-->
            <xsl:template match="/*">
              <xsl:copy copy-namespaces="no">
                <xsl:copy-of select="attribute::* except @xml:base" copy-namespaces="no"/>
                <xsl:copy-of select="child::node()"                 copy-namespaces="no"/>
              </xsl:copy>
            </xsl:template>
          </xsl:stylesheet>
        </p:inline>
      </p:input>
    </p:xslt>  
  </p:for-each>
  
  <p:for-each>
    <!--<p:iteration-source select="/"/>-->
    <!--<p:iteration-source>
      <p:pipe step="web-sequence" port="page-sequence"/> 
      <p:pipe step="web-sequence" port="apparatus"/> 
    </p:iteration-source>-->
    <!--<p:variable name="page-name" select="concat(/*/@id,'.html')"/>-->
    <p:store>
      <p:with-option name="method" select="'xml'" />
      <p:with-option name="href" select="base-uri(/)" />
    </p:store>
  </p:for-each>
  
<!-- Also have to copy in graphics via another subpipeline also available to  -->
  <!--<p:identity name="collected-epub-pages">
    <p:input port="source">
      <p:pipe step="bookpart-page-sequence" port="result"/>
      <p:pipe step="directory-page" port="result"/>
      <p:pipe step="titlepage" port="result"/>
      <p:pipe step="colophon" port="result"/>
      <!-\- CSS ... -\->
    </p:input>
  </p:identity> -->
  
<!--  <p:identity/>-->
</p:declare-step>