<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:pxp="http://exproc.org/proposed/steps"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
  
  <p:option name="debug" select="'no'"/>
  
  <p:input  port="source"/>

  <p:input port="parameters" kind="parameter"/>
  
  <p:output primary="true" port="result" sequence="true"/>
  <p:serialization         port="result" indent="true"/>
  
  <p:output primary="false" port="debug" sequence="true">
    <p:pipe step="opf-source" port="result"/>
    <p:pipe step="opf-file"   port="bound-to-URI"/>
  </p:output>
  <p:serialization port="debug" indent="true"/>
  
  <p:import href="xml-bindtoURI.xpl"/>
  
  <p:import href="jatskit-ebook-sequence.xpl"/>

  <p:declare-step type="pxp:zip" xml:base="file:/projects/github/docs-calabash/src/declarations.xml">
    <p:input port="source" sequence="true" primary="true"/>
    <p:input port="manifest"/>
    <p:output port="result"/>
    <p:option name="href" required="true"/>                       <!-- anyURI -->
    <p:option name="compression-method"/>                         <!-- "stored" | "deflated" -->
    <p:option name="compression-level"/>                          <!-- "smallest" | "fastest" | "default" | "huffman" | "none" -->
    <p:option name="command" select="'update'"/>                  <!-- "update" | "freshen" | "create" | "delete" -->
  </p:declare-step>
  
  <p:variable name="source-filename" select="document-uri(/)"/>
  
  <p:variable name="book-code" select="replace($source-filename,'^.*/|\.\w*$','')"/>

  <!-- The next subpipeline (called via import) supports production of two file sets:
    A page sequence of results of splitting BITS book and rendering as HTML
    A set of top-level pages, apparatus and metadata for the former.
    
    These are produced as a set of HTML files including Title page, ToC and colophon, all linked.
    They come already bound to document URIs although those contents have not been serialized.

    In subsequent steps we will be binding to the results of ports in the sub pipeline.
  -->
  
  <jatskit:book-web-sequence name="web-sequence"/>

<!-- For producing the output, we assemble a sequence of resources,
     including both pipeline results (bound to URIs for zipping), or
     references to resources on the file system (such as graphics files).
  --> 

  <!-- Aggregates files acquired from the web-sequence sub pipeline into a single sequence. -->
  <p:identity name="web-files">
    <p:input port="source">
      <!-- Web apparatus (top-level files) including ToC, colophon etc. -->
      <p:pipe step="web-sequence" port="apparatus"/>
      <!-- Web page sequence for book contents -->
      <p:pipe step="web-sequence" port="page-sequence"/>
    </p:input>
  </p:identity>
  
  <!-- Same with any files produced only for the EPUB such as NCX or what have you.
       Note this does not include the generated OPF file, which we produce later
       once we have generated and listed all the other results, or any files
       to be produced statically, such as mimetype and META-INF/control.xml. -->
  <p:identity name="epub-files">
    <p:input port="source">
      <p:empty/>
      <!-- Any EPUB apparatus, except for mimetype, META-INF/control.xml (which are static)
           and the OPF file - which is not included since these results are
           inputs to the step that produces it. -->
      <!-- <p:pipe step="ncx-file" port="result"/>-->
    </p:input>
  </p:identity>


  <!-- Additionally, we need pipelines able to generate result files proper to EPUB,
     hence not produced in the subpipeline. -->
  
  <!-- 
    Map of the EPUB produced - {$book-code}.epub :
    
    Files specific to EPUB
        mimetype - static file
        META-INF/container.xml - static file
        JATSKit-ncx.ncx - dynamically generated for this book
        JATSKit-opf.opf - "           "         "   "    "
      
    Generic files (produced in pipeline book-web-sequence.xpl)
        ToC (directory) page {$book-code}-toc.html
        Title page           {$book-code}-title.html 
        Colophon             {$bookID-code}-colophon.html
    Content files produced for each book-part or other "split" from XML source
        contents/{$partID-page.html}
    Graphics files copied from source directory
        graphics
    CSS (copied from JATSKit)
    
  -->
  
<!-- Next we produce a compilation of all this stuff (wrapped as $jatskit:kit)
     which we can process to produce manifests for the EPUB internally (OPF file)
     and for zipping the results. -->
  <p:wrap-sequence name="file-set" wrapper="jatskit:kit">
    <p:input port="source">
      <p:pipe port="result" step="web-files"/>
      <p:pipe port="result" step="epub-files"/>
      
      <!-- List of graphics -->
      <p:pipe step="web-sequence" port="graphics-manifest"/>
      <!-- List of static resources -->
      <p:pipe step="web-sequence" port="support-manifest"/>
    </p:input>
  </p:wrap-sequence>
  
  <!-- The inputs are a mix of XHTML files and references to files
       as jatskit:graphic jatskit:css etc. These are flattened
       out to a simple list of references. -->
  <p:xslt name="file-manifest">
    <p:with-param name="source-filename" select="$source-filename"/>
    <p:with-param name="book-code" select="$book-code"/>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0" xmlns:xhtml="http://www.w3.org/1999/xhtml"
           exclude-result-prefixes="#all">
          <xsl:param name="source-filename" required="yes"/>
          <xsl:param name="book-code" required="yes"/>
          <xsl:variable name="target-dir" select="concat(resolve-uri($book-code,$source-filename),'/')"/>
          <!-- Unwrapping these ... -->
          <xsl:template match="jatskit:kit//jatskit:kit">
            <xsl:apply-templates/>
          </xsl:template>
          <xsl:template match="xhtml:html">
            <jatskit:html target="{base-uri(.)}" as="{substring-after(base-uri(.),$target-dir)}">
              <xsl:copy-of select="@*"/>
            </jatskit:html>
          </xsl:template>
          <xsl:template match="*">
            <xsl:copy>
              <xsl:copy-of select="@*"/>
              <xsl:apply-templates/>
            </xsl:copy>
          </xsl:template>
          <xsl:template match="text()"/>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
 
<!-- For the zipping process, we need a zip manifest, which we produce here
     from the jatskit:kit element resulting from the last step. -->
  <p:xslt name="zip-manifest">
    <p:with-param name="source-filename" select="$source-filename"/>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0" xmlns:xhtml="http://www.w3.org/1999/xhtml">
          <xsl:param name="source-filename" required="yes"/>
          <xsl:variable name="base-dir" select="concat(replace($source-filename,'\..*$',''),'/')"/>
          <xsl:template match="/jatskit:kit">
            <c:zip-manifest>
              <!-- First, the files that are always the same. -->
              <c:entry name="mimetype" compression-method="stored" compression-level="none"
                href="../epub/mimetype.text"/>
              <c:entry href="../epub/container.xml" name="META-INF/container.xml"/>
              <!-- OPF file named literally, since it doesn't come in through the 'source' pipe -->
              <!--<c:entry href="../epub/mimetype.text" name="JATSKit-opf.opf"/>-->
              <c:entry href="{$base-dir}JATSKit-opf.opf" name="JATSKit-opf.opf"/>
              <!-- Attributes on XML inside jatskit:fileset provides for these to be listed.
                   These include EPUB resources such as OPF, HTML resources, and static
                   resources listed in pipeline steps above (graphics etc.) -->
              <xsl:apply-templates/>
            </c:zip-manifest>
          </xsl:template>

          <xsl:template match="jatskit:html">
            <c:entry name="{substring-after(@target,$base-dir)}" href="{@target}"/>
          </xsl:template>
          <xsl:template match="jatskit:*">
            <c:entry name="{@as}" href="{@href}"/>
          </xsl:template>
          <xsl:template match="text()"/>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>

  <!-- Here we aggregate resources from which we will generate the OPF file:
       The jatskit:kit file listing (for an internal manifest) along with
       a copy of original book input (for its metadata). -->
  <p:wrap-sequence wrapper="jatskit:kit" name="opf-source">
    <p:input port="source"  sequence="true">
      <p:pipe port="result" step="file-manifest"/>
      <p:pipe port="source-ready" step="web-sequence"/>
    </p:input>
  </p:wrap-sequence>

  <!-- The OPF is produced by running this through a transformation. -->
  <p:xslt name="make-opf">
    <p:with-param name="source-filename" select="$source-filename"/>
    <p:input port="stylesheet">
      <p:document href="../xslt/epub/jatskit-opf.xsl"/>
    </p:input>
  </p:xslt>
  
  <!-- Now, bind it to its URI (as given on @xml:base) on a secondary port, and make that available. -->
  <jatskit:xml-bindtoURI name="opf-file"/>
  
  <p:sink/>

<!-- All set up: this is the main step of the pipeline. Depending on a runtime option provided, we
     either echo all the pipeline results we see, or run it through a zip routine, which
     pulls the zip manifest in along with the bound results of file generation. -->

  <p:choose>
    <p:when test="$debug='yes'">
      <p:identity name="generated-sources">
        <p:input port="source">
          <p:pipe port="bound-to-URI" step="opf-file"/>
          <p:pipe port="result"       step="epub-files"/>
          <p:pipe port="result"       step="web-files"/>
        </p:input>
      </p:identity>
    </p:when>
    <p:otherwise>
      <pxp:zip name="zipped">
        <p:input port="source">
          <p:pipe port="bound-to-URI" step="opf-file"/>
          <p:pipe port="result" step="epub-files"/>
          <p:pipe port="result" step="web-files"/>
        </p:input>
        <p:input port="manifest">
          <!-- Note that the zip manifest lists not only generated files, but also files to be copied
               (e.g. graphics and other resources). -->
          <p:pipe step="zip-manifest" port="result"/>
        </p:input>
        <!-- We write the EPUB to a file named after the input, with 'EPUB' replacing any current "*ml" file suffix. -->
        <p:with-option name="href" select="replace($source-filename,'\..*ml$','.epub')"/>
        <p:with-option name="command" select="'create'"/>
      </pxp:zip>
      
      <p:identity name="zip-echo"/>
    </p:otherwise>
  </p:choose>
  
  <p:xslt name="report-results">
    <p:with-param name="source-filename" select="$source-filename"/>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0" xmlns:xhtml="http://www.w3.org/1999/xhtml"
          exclude-result-prefixes="#all">

          <xsl:param name="source-filename" required="yes"/>
          <xsl:variable name="base-dir" select="concat(replace($source-filename,'\..*$',''),'/')"/>
          <xsl:template match="c:zipfile" priority="2">
            <report>
              <source>
                <xsl:value-of select="$source-filename"/>
              </source>
              <result filecount="{count(c:file)}">
                <xsl:value-of select="@href"/>
              </result>
            </report>
          </xsl:template>
          
          <xsl:template match="/*">
            <xsl:copy-of select="."/>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  
  <p:identity name="result"/>
  
</p:declare-step>