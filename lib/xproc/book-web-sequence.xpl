<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:xprs="http://xpressionspub.com/xproc/util"
  xmlns:ojf="https://github.com/wendellpiez/oXygenJATSframework/ns"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  type="ojf:book-web-sequence" name="book-web-sequence">

  <!-- serialization steps for steps -->

  
  <!--<p:serialization port="final" indent="false"
    encoding="utf-8" method="xhtml"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    omit-xml-declaration="false"/>-->

  

<!-- set intput ports -->

  <p:input port="source"/>
  
  <p:input port="parameters" kind="parameter"/>
  
<!-- set output ports - these are mostly for debugging;
     we need only the primary port for production -->

<!--  <p:output primary="false" port="oasis-tables-xhtml">
    <p:pipe port="result" step="oasis-tables-xhtml"/>
  </p:output>
-->
  <p:output primary="false" port="marked-for-splitting"><!-- A single BITS document, with marks for splitting -->
    <!-- x -->
    <p:pipe port="result" step="marked-for-splitting"/>
  </p:output>
  
  <p:output primary="false" port="bookparts-split-document"><!-- A 'book-sequence' element aggregating books, each containing a (split) section as a (single) book-part. -->
    <!-- x -->
    <p:pipe port="result" step="bookparts-split"/>
  </p:output>
  
  <!-- Ports for actual (wanted) results go here -->
  <!-- These are captured on the secondary port that binds the results
       via xsl:result-document to the indicated baseURI (to be available for zipping later). -->
  <p:output primary="false" port="page-sequence" sequence="true"><!-- A sequence of HTML pages, one per (split) chunk -->
    <p:pipe port="secondary" step="bookpart-page-sequence"/>
  </p:output>
  
  <!--<p:output primary="false" port="page-files" sequence="true"><!-\- A sequence of HTML pages, one per (split) chunk -\->
    <p:pipe port="secondary" step="page-files"/>
  </p:output>-->
  
  <!--<p:output primary="false" port="directory-page"><!-\- An HTML ToC page for the (entire) book, accounting for splitting -\->
    <p:pipe port="result" step="directory-page"/>
  </p:output>-->
  
  <p:output primary="false" port="apparatus" sequence="true">
    <p:pipe port="secondary" step="directory-file"/>
    <!--<p:pipe port="result" step="titlepage"/>
    <p:pipe port="result" step="colophon"/>-->
  </p:output>
  
  
  <p:serialization port="page-sequence" indent="true"/>
  
  
  <p:xslt name="marked-for-splitting">
    <!-- Adds a flag where files should be split out. Note: these can nest!
         Splitting will occur recursively.
         
         Complex "chunking" (which may entail not only splitting but also merging)
         is possible iff concerns about metadata propagation and (valid) result element
         construction can be mitigated in the implementation.
                  
         Also adds IDs where there are none, on book-part and sec elements - but
         inputs invalid to the unique ID requirement will result in spazzy outputs.
         The assumption is that all other XIncludes or other inclusion
         mechanism will provide unique identifiers within the *new* (assembled) document scope.
         
         An exception: if subordinate JATS 'article' elements are found, their IDs and @rid values
         are prepended with the JATS @id value for disambiguation.
    -->
    <p:input port="stylesheet">
      <p:document href="../xslt/web/bits-mark-for-splitting.xsl"/>
    </p:input>  
  </p:xslt>
  
  <!--<p:identity name="bookparts-split"/>-->
  <p:xslt name="bookparts-split">
    <p:input port="stylesheet">
      <p:document href="../xslt/web/bits-split.xsl"/>
    </p:input>  
  </p:xslt>
  
  <!--<p:identity name="bookpart-page-sequence"/>-->
  <!--  For each of the split 'books', generate an HTML page result.
        Note that the page contains a single book-part, but most of
        its templates can be the same-old plain vanilla HTML page production.
  -->
  <!--<p:for-each name="bookpart-page-sequence">
    <p:iteration-source select="/book | /*/book"/>
    <p:output port="result" sequence="true"/>
    <p:xslt name="bits-html">
      <p:input port="stylesheet">
        <p:document href="../xslt/web/bits-web-html.xsl"/>
      </p:input>
    </p:xslt>
    <!-\- In a subsequent step we write the files out via xsl:result-document,
         so they will appear on the pipeline's secondary port. -\->
    <!-\-<p:xslt name="tuned-for-web">
      <p:input port="stylesheet">
        <p:document href="xslt/web/bits-web-tune.xsl"/>
      </p:input>  
    </p:xslt>-\->
    
  </p:for-each>-->

  <p:xslt name="bookpart-page-sequence">
    <!--<p:input port="source">
      <p:pipe port="result" step="bookpart-page-sequence"/>
    </p:input>-->
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
          <xsl:import href="../xslt/web/bits-web-html.xsl"/>
          <xsl:template match="/">
            <pages>
              <xsl:apply-templates select="/book | /*/book"/>
            </pages>
          </xsl:template>
          <xsl:template match="book">
            <xsl:variable name="html-result" as="element()?">
              <xsl:apply-imports/>
            </xsl:variable>
            <xsl:result-document href="{$html-result/@xml:base}">
              <xsl:sequence select="$html-result"/>
            </xsl:result-document>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  
  <p:sink/>
  
  <!--<p:identity name="directory-page">
    <p:input port="source">
      <p:pipe port="result" step="marked-for-splitting"/>
    </p:input>
  </p:identity>-->
  <p:xslt name="directory-page">
    <p:input port="source">
      <!-- Main source port: the original, unsplit BITS documen, after ID cleanup, marked for splitting -->
      <p:pipe port="result" step="marked-for-splitting"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xslt/web/bits-web-directory-html.xsl"/>
      <!-- Note the directory needs to know where files are being split, to
           write links correctly ... -->
    </p:input>  
  </p:xslt>

  <p:xslt name="directory-file">
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
          <xsl:template match="/*">
            <xsl:result-document href="{@xml:base}">
              <xsl:sequence select="."/>
            </xsl:result-document>
            <xsl:sequence select="."/>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>
  
  <p:sink/>
  
  <p:identity name="titlepage">
    <p:input port="source">
      <p:pipe port="result" step="marked-for-splitting"/>
    </p:input>
  </p:identity>
  <!--<p:xslt name="titlepage">
    <p:input port="source">
      <!-\- Main source port: the original, unsplit BITS document -
           after ID cleanup, marked for splitting -\->
      <p:pipe port="result" step="marked-for-splitting"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xslt/web/bits-web-titlepage-html.xsl"/>
      <!-\- Note the directory needs to know where files are being split, to
           write links correctly ... -\->
    </p:input>  
  </p:xslt>-->
  
  <p:sink/>
  
  <p:identity name="colophon">
    <p:input port="source">
    <p:pipe port="result" step="marked-for-splitting"/>
  </p:input>
  </p:identity>
  <!--<p:xslt name="colophon">
    <p:input port="source">
      <!-\- Main source port: the original, unsplit BITS document -
           after ID cleanup, marked for splitting -\->
      <p:pipe port="result" step="marked-for-splitting"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xslt/web/bits-colophon-html.xsl"/>
      <!-\- Note the directory needs to know where files are being split, to
           write links correctly ... -\->
    </p:input>  
  </p:xslt>-->
  
  <p:sink/>

</p:declare-step>

<!-- end of D-hub2epub.xpl -->


