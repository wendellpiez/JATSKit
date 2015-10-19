<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  xmlns:opf="http://www.idpf.org/2007/opf"
  type="jatskit:xml-bindtoURI" name="xml-bindtoURI">
  
  <!-- Given a known document type, where @xml:base is assigned, this pipeline produces a copy
       on the secondary port.
       The base URI assigned to the copy is assigned to the value of @xml:base. -->

  <p:input port="source"/>
  
  <p:input port="parameters" kind="parameter"/>
  
  <p:output primary="true" port="bound-to-URI" sequence="true">
    <p:pipe port="secondary" step="bound-resource-on-secondary"/>
  </p:output>
  
  <p:output primary="false" port="diagnostic" sequence="true">
    <p:pipe port="result" step="bound-resource-on-secondary"/>
  </p:output>
  
  <p:xslt name="bound-resource-on-secondary">
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0" xmlns:xhtml="http://www.w3.org/1999/xhtml">
          <!-- Any element we expect to be serialized as a document, when assigned an explicit @xml:base,
               produces a copy of itself on the secondary port. -->
          <xsl:template match="xhtml:html[matches(@xml:base,'\S')] | opf:package[matches(@xml:base,'\S')]">
            <xsl:result-document href="{@xml:base}" encoding="utf-8">
              <xsl:next-match/>
            </xsl:result-document>
            <xsl:next-match/>
          </xsl:template>
          <xsl:template match="@xml:base"/>
          <xsl:template match="node() | @*">
            <xsl:copy>
              <xsl:apply-templates select="node() | @*"/>
            </xsl:copy>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>

  <p:sink/>
    
</p:declare-step>

<!-- end of D-hub2epub.xpl -->


