<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:pxp="http://exproc.org/proposed/steps"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
  <!--
  
  -->
  <p:input  port="source"/>

  <p:output primary="true" port="zip-echo"/>
  
  <p:output primary="false" port="zip-manifest">
    <p:pipe port="result" step="zip-manifest"/>
  </p:output>
  
  <!--<p:output primary="false" port="page-sequence" sequence="true">
    <p:pipe port="page-sequence" step="web-sequence"/>
  </p:output>-->
  
  <p:output primary="false" port="debug" sequence="true">
    <p:pipe port="diagnostic" step="opf-file"/>
  </p:output>
  
  <!--<p:output primary="false" port="wrapped-fileset">
    <p:pipe port="result" step="fileset"/>
  </p:output>-->
  
  <p:input port="parameters" kind="parameter"/>
  
  <p:import href="xml-bindtoURI.xpl"/>
  
  <p:import href="book-web-sequence.xpl"/>
  
  <p:serialization port="zip-manifest" indent="true"/>
  <p:serialization port="zip-echo" indent="true"/>
  <p:serialization port="debug" indent="true"/>
  
  <p:variable name="source-filename" select="document-uri(/)"/>
  
  <p:variable name="book-code" select="replace($source-filename,'^.*/|\.\w*$','')"/>
  <!-- The subpipeline supports production of two file sets:
    A page sequence of results of splitting BITS book and rendering as HTML
    A set of top-level pages, apparatus and metadata for the former.
    
    produces a set of HTML files including Title page, ToC and colophon. -->
  
<!-- Initially we execute a sub-pipeline to whose ports we will be binding. -->
  <!--
    It is able to produce not only paged HTML files, but page apparatus
    such as table of contents, colophon etc. -->
  
  <jatskit:book-web-sequence name="web-sequence"/>
 
 
<!-- Next we generate files proper to EPUB, not produced in the subpipeline. -->
  <!--Files specific to EPUB
        META-INF/container.xml - subpipeline 'meta-inf-container'
        {$bookID}-ncx.ncx
        {$bookID}-opf.opf
-->
  
 
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

  <p:xslt name="make-opf">
    <p:input port="source">
      <!-- Main source port: the original, unsplit BITS documen, after ID cleanup, marked for splitting -->
      <p:pipe port="source-marked" step="web-sequence"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xslt/epub/jatskit-opf.xsl"/>
      <!-- Note the directory needs to know where files are being split, to
           write links correctly ... hence the usefulness of @jatskit:spit markers. -->
    </p:input>  
  </p:xslt>
  
  <!-- Now, bind it to its URI (as given on @xml:base) on a secondary port, and make that available. -->
  <jatskit:xml-bindtoURI name="opf-file"/>
  
  <p:sink/>
  <!--<p:xslt name="opf-file">
    <p:input port="source">
      <p:pipe port="source-marked" step="web-sequence"/>
    </p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0" xmlns:xlink="http://www.w3.org/1999/xlink">
          <!-\- Function declarations for here... -\->
          <xsl:import href="../xslt/web/html-util.xsl"/>
          <xsl:template match="/">
            <xsl:variable name="target-dir" select="resolve-uri(jatskit:book-code(/),document-uri(/))"/>
            <jatskit:resources>
              <jatskit:css href="../web-css/jatskit-web.css"
                target="{$target-dir}/css/jatskit-web.css"
                as="css/jatskit-web.css"/>
              <jatskit:css href="../xslt/jats-preview-xslt/jats-preview.css"
                target="{$target-dir}/css/jats-preview.css"
                as="css/jats-preview.css"/>
            </jatskit:resources>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  
  <jatskit:xml-bindtoURI name="bookpart-page-sequence"/>-->
  
  <!-- For producing the output, we assemble a sequence of resources,
       including both pipeline results (bound to URIs for zipping), or
       references to resources on the file system (such as graphics files). --> 
       
  <p:wrap-sequence name="fileset" wrapper="fileset">
    <p:input port="source">
      <!-- EPUB apparatus -->
      <p:pipe step="opf-file"     port="bound-to-URI"/>
      
      <!-- Web apparatus (top-level files) -->
      <p:pipe step="web-sequence" port="apparatus"/>
      <!-- Web page sequence -->
      <p:pipe step="web-sequence" port="page-sequence"/>
      <!-- List of graphics -->
      <p:pipe step="web-sequence" port="graphics-manifest"/>
      <!-- List of static resources -->
      <p:pipe step="web-sequence" port="support-manifest"/>
      <!--<p:pipe port="result" step="make-opf"/>-->
    </p:input>
  </p:wrap-sequence>

  <p:xslt name="zip-manifest">
    <p:with-param name="source-filename" select="$source-filename"/>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0" xmlns:xhtml="http://www.w3.org/1999/xhtml">
          <xsl:param name="source-filename" required="yes"/>
          <xsl:variable name="base-dir" select="concat(replace($source-filename,'\..*$',''),'/')"/>
          <xsl:template match="/fileset">
            <c:zip-manifest>
              <!-- @name is the full path of the file in the zip (epub); @href is where we find it -->
              <!-- For now, we only want a single 'mimetype' file, compression level 0 as per EPUB specs. -->
              <c:entry name="mimetype" compression-method="stored" compression-level="none"
                href="../epub/mimetype.text"/>
              <c:entry href="../epub/container.xml" name="META-INF/container.xml"/>
              
              <!-- Static files should go here: CSS etc., excluding those that appear
              on the 'fileset' port due to having been auto-generated e.g. ncx etc. -->
              <!-- Finally, we need graphics files called in. Do this by grouping
                 over //xhtml:img/@src ! to generate references for files to be copied... -->
              <xsl:apply-templates select="xhtml:html | opf:package | jatskit:resources/*"/>
            </c:zip-manifest>
          </xsl:template>

          <xsl:template match="xhtml:html | opf:package">
            <c:entry name="{substring-after(base-uri(.),$base-dir)}" href="{base-uri(.)}"/>
          </xsl:template>
          <!-- Handling proxies for resources not generated by pipelines. -->
          <xsl:template match="jatskit:resources/*">
            <c:entry name="{@as}" href="{@href}"/>
          </xsl:template>

          <xsl:template match="text()"/>

        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
 
 
 
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
      <!-- page-sequence is the dynamically produced set of HTML files -->
      <p:pipe step="web-sequence" port="page-sequence"/>
      <!-- apparatus includes top-level files eg ToC, titlepage -->
      <p:pipe step="web-sequence" port="apparatus"/>
      
      <!-- Files generated for the EPUB only also go here. -->
      <p:pipe step="opf-file"     port="bound-to-URI"/>
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