<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:ojf="https://github.com/wendellpiez/oXygenJATSframework/ns"
  xmlns:pxp="http://exproc.org/proposed/steps"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
  <!--
  
  -->
  <p:input  port="source"/>

  <p:output primary="true" port="zip-echo"/>
  
  <p:output primary="false" port="page-sequence" sequence="true">
    <p:pipe port="page-sequence" step="web-sequence"/>
  </p:output>
  
  <p:output primary="false" port="wrapped-fileset">
    <p:pipe port="result" step="fileset"/>
  </p:output>
  
  <p:output primary="false" port="zip-manifest">
    <p:pipe port="result" step="zip-manifest"/>
  </p:output>
  
  <p:input port="parameters" kind="parameter"/>
  
  
  <p:import href="book-web-sequence.xpl"/>
  
  <p:serialization port="page-sequence" indent="true"/>
  <p:serialization port="wrapped-fileset" indent="true"/>
  <p:serialization port="zip-manifest" indent="true"/>
  <p:serialization port="zip-echo" indent="true"/>
  
  <p:variable name="source-filename" select="document-uri(/)"/>
  
  <!-- The subpipeline supports production of two file sets:
    A page sequence of results of splitting BITS book and rendering as HTML
    A set of top-level pages, apparatus and metadata for the former.
    
    produces a set of HTML files including Title page, ToC and colophon. -->
  <ojf:book-web-sequence name="web-sequence"/>
  
  <p:wrap-sequence name="fileset" wrapper="fileset">
    <p:input port="source">
      <p:pipe step="web-sequence" port="page-sequence"/>
      <p:pipe step="web-sequence" port="apparatus"/>
      <!-- Add files to be generated for EPUB e.g. ncx, meta-inf here
        and also below in step 'zipped' -->
    </p:input>
  </p:wrap-sequence>

  <p:xslt name="zip-manifest">
    <p:with-param name="source-filename" select="$source-filename"/>
    <p:input port="stylesheet">
      <p:inline>
      <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        version="2.0">
        <xsl:param name="source-filename" required="yes"/>
        <xsl:variable name="base-dir" select="concat(replace($source-filename,'\..*$',''),'/')"/>
        <xsl:template match="/fileset">
          <c:zip-manifest>
            <!-- @name is the full path of the file in the zip (epub); @href is where we find it -->
            <!-- For now, we only want a single 'mimetype' file, compression level 0 as per EPUB specs. -->
            <c:entry name="mimetype" compression-method="stored" compression-level="none" 
              href="file:/D:/Work/Projects/PublicProjects/JATS-oXygen-framework/Working/lib/static/mimetype.text"/>
            
            <!-- Static files should go here: CSS etc., excluding those that appear
              on the 'fileset' port due to having been auto-generated e.g. ncx etc. -->
            <!-- Finally, we need graphics files called in. Do this by grouping
                 over //xhtml:img/@src ! to generate references for files to be copied... -->
            <xsl:apply-templates/>
          </c:zip-manifest>
        </xsl:template>
        
        <xsl:template match="/*/*">
          <c:entry name="{substring-after(base-uri(.),$base-dir)}" href="{base-uri(.)}"/>
        </xsl:template>
      </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  
  <!--<p:xslt name="meta-inf-container">
    <p:input port="source">
      <!-\- Main source port: the original, unsplit BITS document -
           after ID cleanup, marked for splitting -\->
      <p:pipe port="marked-for-splitting" step="web-sequence"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xslt/bits-meta-inf-container.xsl"/>
      <!-\- Note the directory needs to know where files are being split, to
           write links correctly ... -\->
    </p:input>  
  </p:xslt>
  
  <p:sink/>-->
  
 
  <!--Files specific to EPUB
        META-INF/container.xml - subpipeline 'meta-inf-container'
        {$bookID}-ncx.ncx
        {$bookID}-opf.opf
      
      Generic files (from book-web-sequence.xpl)
      Also collects a pipeline that generates, with the book,
        Title page {$bookID}-titlepage.html 
        ToC (directory) page (contents.html)
        Colophon   {$bookID}-colophon.html
          Post-processes all these to rewrite their CSS file links
          to the EPUB css, as well as attach a base-uri()
      Placing them in a "files" directory or some such?
-->

  <p:declare-step type="pxp:zip" xml:base="file:/projects/github/docs-calabash/src/declarations.xml">
    <p:input port="source" sequence="true" primary="true"/>
    <p:input port="manifest"/>
    <p:output port="result"/>
    <p:option name="href" required="true"/>                       <!-- anyURI -->
    <p:option name="compression-method"/>                         <!-- "stored" | "deflated" -->
    <p:option name="compression-level"/>                          <!-- "smallest" | "fastest" | "default" | "huffman" | "none" -->
    <p:option name="command" select="'update'"/>                  <!-- "update" | "freshen" | "create" | "delete" -->
  </p:declare-step>
  
  <pxp:zip name="zipped">
    <!-- Primary input source contains documents with base-uris assigned via /*/@xml:base, which should correspond to the files
         listed in the (dynamically generated) zip-manifest. -->
    <p:input port="source">
      <!-- Add pipelines for dynamic EPUB-specific files here
           such as meta-inf, ncx and what not.
       -->
      <p:pipe step="web-sequence" port="page-sequence"/>
      <p:pipe step="web-sequence" port="apparatus"/>
    </p:input>
    <p:input port="manifest">
      <p:pipe step="zip-manifest" port="result"/>
    </p:input>
    <!--<p:with-option name="href"    select="resolve-uri(concat('eLibrary-packages/',/zip/@href),$source-path)"/>-->
    <!--<p:with-option name="href" select="'file:/D:/Work/Projects/PublicProjects/JATS-oXygen-framework/Working/test.epub'"/>-->
    <p:with-option name="href" select="replace($source-filename,'\..*$','.epub')"/>
    <p:with-option name="command" select="'create'"/>
  </pxp:zip>
  
  <p:identity name="zip-echo"/>
  
</p:declare-step>