<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:import href="jats-preview-xslt/xslt/main/jats-html.xsl"/>
  
  <xsl:import href="jats-preview-xslt/xslt/oasis-tables/oasis-table-html.xsl"/>
  
  <xsl:param name="transform" as="xs:string">jatskit-html.xsl</xsl:param>
  
  <!-- Overriding the imported value. -->
  <xsl:param name="css" select="false()"/>
  
<!--  -->

<!-- Overriding certain templates to patch jats-html.xsl - these can be pushed upstream! -->
  <xsl:template name="make-html-header">
    <head>
      <title>
        <xsl:variable name="authors">
          <xsl:call-template name="author-string"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space(string($authors))"/>
        <xsl:if test="normalize-space(string($authors))">: </xsl:if>
        <xsl:value-of
          select="(/article/front/article-meta/title-group/article-title,
                   /book/book-meta/book-title-group/book-title[1])[1]"/>
      </title>
      <xsl:choose>
        <!-- $css is set to false() by default; any provided (string) value will test true(). -->
        <xsl:when test="boolean($css)"><link rel="stylesheet" type="text/css" href="{$css}"/></xsl:when>
        <!-- Otherwise we want CSS inline. -->
        <xsl:otherwise>
          <xsl:copy-of select="$css-literal"/>
        </xsl:otherwise>
      </xsl:choose>
      <!-- Template in jats-oasis-html.xsl to insert CSS for our tables. -->
      <xsl:call-template name="p:table-css" xmlns:p="http://www.wendellpiez.com/oasis-tables/util"/>
    </head>
  </xsl:template>
  
  
  <xsl:template name="author-string">
    <xsl:variable name="all-contribs"
      select="(/article/front/article-meta/contrib-group/contrib |
               /book/book-meta/contrib-group/contrib)
            / ( name/surname | collab | anonymous | string-name | name-alternatives/name[1]/surname | collab-alternatives/collab[1])"/>
    <xsl:for-each select="$all-contribs">
      <xsl:if test="count($all-contribs) &gt; 1">
        <xsl:if test="position() &gt; 1">
          <xsl:if test="count($all-contribs) &gt; 2">,</xsl:if>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="position() = count($all-contribs)">and </xsl:if>
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:for-each>
  </xsl:template>

<!--  -->
  
<!-- Now, amendments to cover 'book' elements. -->
  <xsl:template match="book">
    <xsl:call-template name="page-header"/>
    <!--  (collection-meta*,book-meta?,front-matter?,book-body?,book-back?)  -->
    <xsl:apply-templates/>  
    <div id="{@id/concat(.,'-')}footer" class="footer">
      <xsl:call-template name="footer-metadata"/>
      <xsl:call-template name="footer-branding"/>
    </div>
  </xsl:template>
  
  <xsl:template name="page-header">
    <!-- context is /book, /article/front or /article/front-stub -->
    <div class="page-header">
      <xsl:apply-templates mode="page-header" select="(article-meta | book-meta)/(title-group | book-title-group)/(article-title | book-title | subtitle)"/>
      <xsl:apply-templates mode="page-header" select="(article-meta | book-meta)/contrib-group/contrib"/>
    </div>
  </xsl:template>

  <xsl:template mode="page-header" match="article-title | book-title">
    <h1 class="page-title">
      <xsl:apply-templates/>
    </h1>
  </xsl:template>

  <xsl:template mode="page-header" match="subtitle">
    <h2 class="page-subtitle">
      <xsl:apply-templates/>
    </h2>
  </xsl:template>
  
  <xsl:template mode="page-header" match="contrib">
    <h3 class="page-authors">
      <xsl:for-each select="name | collab | anonymous | string-name | name-alternatives/name[1] | collab-alternatives/collab[1]">
        <xsl:if test="position() gt 1">
          <xsl:choose>
            <xsl:when test="position() eq last()"> and </xsl:when>
            <xsl:otherwise>, </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </h3>
  </xsl:template>
  
  
  <!-- New processing for all metadata! -->
  <xsl:template match="book-meta | journal-meta | collection-meta | article-meta | book-part-meta | sec-meta">
    <div class="metadata {name()}">
      <xsl:apply-templates select="." mode="grid"/>
    </div>
  </xsl:template>
  
  <!-- for articles we skip the 'metadata mode' insanity of the imported stylesheet ... -->
  <xsl:template match="article/front | article/front-stub">
    <xsl:call-template name="page-header"/>
    <xsl:apply-templates/>
  </xsl:template>
    
  <xsl:variable name="element-names" select="document('taglib-names.xml')/*/element"/>
    
  <xsl:template mode="grid" match="*">
    <xsl:variable name="n" select="name()"/>
    <div class="grid">
      <p class="label generated">
        <xsl:value-of select="$element-names[@gi=$n]"/>
        <xsl:call-template name="attribute-string"/>
      </p>
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <!-- Matches anything with a non-whitespace-only text node *child* -->
  <xsl:template mode="grid" match="*[some $t in text() satisfies matches($t,'\S')]">
    <xsl:variable name="n" select="name()"/>
    <p class="grid">
      <span class="generated"><xsl:value-of select="$element-names[@gi=$n]"/>: </span>
      <!-- Falling out of mode to format anything inline. -->
      <xsl:apply-templates/>
      <xsl:variable name="attribute-string">
        <xsl:call-template name="attribute-string"/>
      </xsl:variable>
      <xsl:if test="matches($attribute-string,'\S')">
      <span class="generated smaller"><xsl:sequence select="$attribute-string"/></span>
      </xsl:if>
    </p>
  </xsl:template>
  
  <xsl:template name="attribute-string">
    <!-- Tests true if any attribute has a value not whitespace. -->
    <xsl:if test="@*[matches(.,'\S')]">
      <xsl:text> [</xsl:text>
      <xsl:for-each select="@*[matches(.,'\S')]">
        <xsl:if test="position() gt 1">; </xsl:if>
        <xsl:value-of select="name()"/>
        <xsl:text>=</xsl:text>
        <xsl:value-of select="."/>
      </xsl:for-each>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="grid" match="p | license-p" priority="1">
    <p class="grid">
      <!-- Falling out of mode to format anything inline. -->
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:template match="front-matter | front-matter/*">
    <div class="{ local-name(.) }">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="book-body">
    <xsl:apply-templates/>
    <xsl:apply-templates select="book-part" mode="build-part"/>
  </xsl:template>
  
  <!-- In ordinary traversal, we drop book-parts, so we can control its
       appearance with a 'pull' into mode 'build-part' -->
  <xsl:template match="book-part"/>
  
  <xsl:template match="book-part" mode="build-part">
    <xsl:call-template name="make-book-part"/>
  </xsl:template>
  
  <xsl:template name="make-book-part">
    <xsl:variable name="part-footnotes"
      select=".//fn except (.//book-part-meta//fn | .//book-part//fn | .//fn-group//fn | .//table-wrap//fn )"/>
    
    <!-- book-part (book-part-meta?,front-matter?,body?,back?) -->
    
    <!-- variable to be used in div id's to keep them unique -->
    <xsl:variable name="this">
      <xsl:apply-templates select="." mode="id"/>
    </xsl:variable>
    
    <div class="book-part book-part{count(ancestor-or-self::book-part)}" id="{$this}">
      
    <xsl:apply-templates select="book-part-meta" mode="metadata"/>
    <xsl:apply-templates select="front-matter"/>
    
    
    <!-- body -->
    <xsl:for-each select="body">
      <div id="{$this}-body" class="body">
        <xsl:apply-templates/>
      </div>
    </xsl:for-each>
    
    <xsl:if test="exists(back | $part-footnotes)">
      <div id="{$this}-back" class="back">
        <xsl:call-template name="make-bookpart-back">
          <xsl:with-param name="bookpart-notes" select="$part-footnotes"/>
        </xsl:call-template>
      </div>
    </xsl:if>
    
    <!-- Unlike JATS article or kindred formats, we have no floats or floats-group -->
    
    <!-- more metadata goes in the footer -->
    
    
    <xsl:apply-templates select="body/book-part" mode="build-part"/>
    
    </div>
    
  </xsl:template>
 
  <!-- Context is the bookpart, not the back, which may not exist. -->
  <xsl:template name="make-bookpart-back">
    <xsl:param name="bookpart-notes" select="()"/>
    <xsl:apply-templates select="back"/>
    <xsl:if test="exists($bookpart-notes)">
      <!-- autogenerating a section for footnotes only if there is no
           back element, and if footnotes exist for it -->
      <xsl:call-template name="bookpart-footnotes">
        <xsl:with-param name="notes" select="$bookpart-notes"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="book-part/back">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template name="bookpart-footnotes">
    <xsl:param name="notes" select="()"/>
    <xsl:if test="exists($notes)">
      <xsl:call-template name="backmatter-section">
        <xsl:with-param name="generated-title">
          <xsl:text>Note</xsl:text>
          <xsl:if test="count($notes) ne 1">s</xsl:if>
        </xsl:with-param>
        <xsl:with-param name="contents">
          <xsl:apply-templates select="$notes" mode="footnote"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  
  
<!--
    
    <xsl:template match="book-part">
    <div class="book-part">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <!-\- With this stylesheet we suspend the footnote-gathering logic in the imported stylesheet. -\->
  <xsl:variable name="loose-footnotes" select="()"/>
  
  <!-\- Footnotes to display in line with display toggle on the link. -\->
  <xsl:template match="fn">
    <xsl:variable name="id">
      <xsl:apply-templates select="." mode="id"/>
    </xsl:variable>
    <sup class="fn-ref" id="ref-{$id}">
      <a href="javascript:flashID('{$id}','collapsed')">
        <xsl:apply-templates select="." mode="label-text"/>
      </a>
    </sup>
    <div id="{$id}" class="fn inline collapsed">
      <xsl:apply-templates select="p"/>
    </div>
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="fn/p">
    <p>
      <xsl:call-template name="assign-id"/>
      <xsl:variable name="fn-id">
        <xsl:apply-templates select=".." mode="id"/>
      </xsl:variable>
      <xsl:if test="not(preceding-sibling::p)">
        <!-\- drop an inline label text into the first p -\->
        <a href="javascript:flashID('{$fn-id}','collapsed')">
          <xsl:apply-templates select="parent::fn" mode="label-text"/>
        </a>
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
-->  
<!-- Where the imported XSLT goes to lengths to pull inline footnotes (fn) out of line, this
     stylesheet simple renders them inline, with a bit of scripting to toggle display. -->

  <xsl:template match="named-content[@content-type=('worktitle','stress')]">
    <i class="{@content-type}">
      <xsl:apply-templates/>
    </i>
  </xsl:template>

  <xsl:variable as="element()*" name="quoted-types">
    <content-type>quoted</content-type>
    <content-type>quote</content-type>
    <content-type>quoted-title</content-type>
    <content-type>called</content-type>
    <content-type>mention</content-type>
  </xsl:variable>
  
  <xsl:template match="named-content[@content-type=$quoted-types]">
    <span class="{@content-type}">
      <xsl:apply-templates select="." mode="left-quote"/>
      <xsl:apply-templates/>
      <xsl:apply-templates select="." mode="right-quote"/>
    </span>
  </xsl:template>
  
  <xsl:template match="named-content[count(ancestor::named-content[@content-type=$quoted-types]) mod 2 = 1]" mode="left-quote">
    <xsl:text>‘</xsl:text></xsl:template>
  
  <xsl:template match="named-content[count(ancestor::named-content[@content-type=$quoted-types]) mod 2 = 1]" mode="right-quote">
    <xsl:text>’</xsl:text>
  </xsl:template>
  
  <xsl:template match="named-content" mode="left-quote">
    <xsl:text>“</xsl:text>
  </xsl:template>
  
  <xsl:template match="named-content" mode="right-quote">
    <xsl:text>”</xsl:text>
  </xsl:template>
  
<!-- For generating a footnotes section when no back matter is present, we have to override
     the imported templates to avoid colliding @ids ...  -->
  <xsl:template name="footnotes">
    <xsl:call-template name="backmatter-section">
      <xsl:with-param name="generated-title">Notes</xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:apply-templates select="$loose-footnotes" mode="footnote"/>
      </xsl:with-param>
      <xsl:with-param name="nominated-id" select="concat(@id,'-footnotes')"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="backmatter-section">
    <xsl:param name="generated-title"/>
    <xsl:param name="contents">
      <xsl:apply-templates/>
    </xsl:param>
    <xsl:param name="nominated-id" select="''"/>
    <div class="back-section">
      <xsl:call-template name="named-anchor">
        <xsl:with-param name="nominated-id" select="$nominated-id"/>
      </xsl:call-template>
      <xsl:if test="not(title) and $generated-title">
        <xsl:choose>
          <!-- The level of title depends on whether the back matter itself
               has a title -->
          <xsl:when test="ancestor::back/title">
            <xsl:call-template name="section-title">
              <xsl:with-param name="contents" select="$generated-title"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="main-title">
              <xsl:with-param name="contents" select="$generated-title"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:copy-of select="$contents"/>
    </div>
  </xsl:template>
  
  <!-- The 'named-anchor' template from jats-html.xsl has a subtle
       bug when applied for a generated section e.g. back matter
       for a 'Notes' section created ad-hoc. Since the context node
       when this template is called is at the top of the book-part,
       we get the book-part's ID, which is no good, since we use it
       for the book-part div.
       So this override permits us to assign an ID in the call. -->
  <xsl:template name="named-anchor">
    <xsl:param name="nominated-id" select="''"/>
    <!-- generates an HTML named anchor -->
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="normalize-space($nominated-id)">
          <xsl:value-of select="$nominated-id"/>
        </xsl:when>
        <xsl:when test="@id">
          <!-- if we have an @id, we use it -->
          <xsl:value-of select="@id"/>
        </xsl:when>
        <xsl:when test="not(preceding-sibling::*) and
          (parent::alternatives | parent::name-alternatives |
          parent::citation-alternatives | parent::collab-alternatives |
          parent::aff-alternatives)/@id">
          <!-- if not, and we are first among our siblings inside one of
               several 'alternatives' wrappers, we use its @id if available -->
          <xsl:value-of select="(parent::alternatives | parent::name-alternatives |
            parent::citation-alternatives | parent::collab-alternatives |
            parent::aff-alternatives)/@id"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- otherwise we simply generate an ID -->
          <xsl:value-of select="generate-id(.)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a id="{$id}">
      <xsl:comment> named anchor </xsl:comment>
    </a>
  </xsl:template>
  
  <xsl:template match="name[@name-style='eastern']">
    <xsl:apply-templates select="prefix, (* except prefix)"/>
  </xsl:template>
  
  <xsl:template match="name">
    <xsl:apply-templates select="prefix, given-names, surname, suffix"/>
  </xsl:template>
  
  <xsl:template match="name/*">
    <xsl:if test="position() gt 1">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
<!-- $css-literal presents CSS for embedding directly in the HTML result. -->
  
  <xsl:variable name="css-literal">
    <style type="text/css">
      <![CDATA[

/* The following code was modified from CSS provided as part of the NLM/NCBI
   JATS Preview XSLT (cf https://github.com/ncbi/JATSPreviewStylesheets)
*/


/* --------------- Page setup ------------------------ */

/* page and text defaults */

body { margin-left: 8%;
margin-right: 8%;
background-color: cornsilk }

div > *:first-child { margin-top:0em }

div { margin-top: 0.5em }

div.page-header { text-align: center }

div.front, div.footer { }

.back, .body { font-family: serif }

div.metadata { font-family: sans-serif; font-size: 80%; padding: 0.5em;
  border: thin inset black; background-color: #f5ffdc }

div.grid .grid { margin-left: 1em }

div.centered { text-align: center }

div.table { display: table }
div.row { display: table-row }
div.cell { display: table-cell; padding-left: 0.25em; padding-right: 0.25em }

div.branding { text-align: center }

div.book-part { margin-top: 1em; padding-top: 1em; border-top: thin solid black }

div.document-title-notes {
text-align: center;
width: 60%;
margin-left: auto;
margin-right: auto
}

div.footnote { font-size: 90% }

/* rules */
hr.part-rule {
border: thin solid black;
width: 50%;
margin-top: 1em;
margin-bottom: 1em;
}

hr.section-rule {
border: thin dotted black;
width: 50%;
margin-top: 1em;
margin-bottom: 1em;
}

/* superior numbers that are cross-references */
.xref {
color: red;
}

/* generated text */     
.generated { color: gray; }

.warning, tex-math {
font-size:80%; font-family: sans-serif }

.warning {
color: red }

.tex-math { color: green }

.data {
color: black;
}

.formula {
font-family: sans-serif;
font-size: 90% }

/* --------------- Titling levels -------------------- */


h1, h2, h3, h4, h5, h6 {
display: block;
margin-top: 0em;
margin-bottom: 0.5em;
font-family: helvetica, sans-serif;
font-weight: bold;
color: darkgreen;
}
/* titling level 1: document title */
.document-title {
text-align: center;
}

/* callout titles appear in a left column (table cell)
opposite what they head */
.callout-title { text-align: right;
margin-top: 0.5em;
margin-right: 1em;
font-size: 140% }



div.section, div.back-section {
margin-top: 1em; margin-bottom: 0.5em }

div.panel { background-color: white;
font-size: 90%;
border: thin solid black;
padding-left: 0.5em; padding-right: 0.5em;
padding-top: 0.5em; padding-bottom: 0.5em;
margin-top: 0.5em; margin-bottom: 0.5em }

div.fn.inline {
font-size: 90%; margin-left: 40%;
border-top: thin dotted black; border-bottom: thin dotted black;
padding-left: 0.5em; padding-right: 0.5em;
padding-top: 0.5em; padding-bottom: 0.5em;
margin-top: 0.5em; margin-bottom: 0.5em }

.collapsed { display: none }

div.blockquote { font-size: 90%;
margin-left: 1em; margin-right: 1em;
margin-top: 0.5em; margin-bottom: 0.5em }

div.caption {
margin-top: 0.5em; margin-bottom: 0.5em }

div.speech {
margin-left: 1em; margin-right: 1em;
margin-top: 0.5em; margin-bottom: 0.5em }

div.verse-group {
margin-left: 1em;
margin-top: 0.5em; margin-bottom: 0.5em }

div.verse-group div.verse-group {
margin-left: 1em;
margin-top: 0em; margin-bottom: 0em }

div.note { margin-top: 0em; margin-left: 1em;
font-size: 85% }

.ref-label { margin-top: 0em; vertical-align: top }

.ref-content { margin-top: 0em; padding-left: 0.25em }

h5.label { margin-top: 0em; margin-bottom: 0em }

p { margin-top: 0.5em; margin-bottom: 0em }

p.first { margin-top: 0em }

p.verse-line, p.citation { margin-top: 0em; margin-bottom: 0em; margin-left: 2em; text-indent: -2em }

p.address-line { margin-top: 0em; margin-bottom: 0em; margin-left: 2em }

ul, ol { margin-top: 0.5em }

li { margin-top: 0.5em; margin-bottom: 0em }
li > p { margin-top: 0.2em; margin-bottom: 0em  }

div.def-list { border-spacing: 0.25em }

div.def-list div.cell { vertical-align: top;
border-bottom: thin solid black;
padding-bottom: 0.5em }

div.def-list div.def-list-head {
text-align: left }

/* text decoration */
.label { font-weight: bold; font-family: sans-serif; font-size: 80% }

.monospace {
font-family: monospace;
}

.overline{
text-decoration: overline;
}

.smaller { font-size: 90% }

a       { text-decoration: none }
a:hover { text-decoration: underline }

/* ---------------- End ------------------------------ */

      
      ]]>
    </style>
  </xsl:variable>
  
  <!-- 
    THE FOLLOWING TEMPLATES ARE DEPRECATED 
    Mode 'metadata' is amended for books, but not comprehensively; currently these templates
    are not even used (but they are left in place for possible future use). -->
  
  <xsl:template match="book-meta/subj-group" mode="metadata">
    <xsl:call-template name="metadata-area">
      <xsl:with-param name="label">Subject assignments</xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="metadata"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-meta/subject" mode="metadata">
    <xsl:call-template name="metadata-area">
      <xsl:with-param name="label">Subject</xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="metadata"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  
  <!--book-id book-title-group contrib-group isbn publisher edition pub-history permissions counts-->
  <xsl:template match="book-meta/book-id" mode="metadata">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">
        <xsl:text>Book ID</xsl:text>
        <xsl:for-each select="@book-id-type">
          <xsl:text> (</xsl:text>
          <span class="data">
            <xsl:value-of select="."/>
          </span>
          <xsl:text>)</xsl:text>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-title-group | book-part-meta/title-group" mode="metadata" priority="0.5">
    <xsl:apply-templates mode="metadata"/>
  </xsl:template>
  
  <xsl:template match="book-title" mode="metadata" priority="0.5">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">Title</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  
  <xsl:template match="book-title-group/subtitle" mode="metadata">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">Subtitle</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="trans-title-group" mode="metadata">
    <xsl:apply-templates mode="metadata"/>
  </xsl:template>
  
  <xsl:template match="book-title-group/alt-title" mode="metadata">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">
        <xsl:text>Alternative title</xsl:text>
        <xsl:for-each select="@alt-title-type">
          <xsl:text> (</xsl:text>
          <span class="data">
            <xsl:value-of select="."/>
          </span>
          <xsl:text>)</xsl:text>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-meta/contrib-group" mode="metadata">
    <xsl:call-template name="metadata-area">
      <xsl:with-param name="label">
        <xsl:text>Contributor</xsl:text>
        <xsl:if test="exists(contrib[2])">s</xsl:if>
      </xsl:with-param>
      
      <xsl:with-param name="contents">
        
        <xsl:for-each select="contrib">
          <!-- Essentially borrowed from jats-html.xsl -->
          
          <div class="metadata">
            <xsl:call-template name="contrib-identify"/>
            <xsl:variable name="info">
              <xsl:call-template name="contrib-info"/>
            </xsl:variable>
            <xsl:sequence select="$info[exists(.//text()[matches(.,'\S')])]"/>
            <!-- handles
                   (address | aff | author-comment | bio | email |
                    ext-link | on-behalf-of | role | uri) -->
          </div>
          
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
    
    <xsl:variable name="misc-contrib-data"
      select="*[not(self::contrib | self::xref)]"/>
    <xsl:if test="$misc-contrib-data">
      <div class="metadata-group">
        <xsl:apply-templates mode="metadata"
          select="$misc-contrib-data"/>
      </div>
    </xsl:if></xsl:template>
  
  <!-- Overriding imported stylesheet -->
  <xsl:template name="contrib-identify">
    <!-- Placed in a left-hand pane  -->
    <!--handles
    (anonymous | collab | collab-alternatives |
    name | name-alternatives | degrees | xref)
    and @equal-contrib -->
    <div class="metadata-group">
      <xsl:for-each select="anonymous | string-name |
        collab | collab-alternatives/* | name | name-alternatives/*">
        <xsl:call-template name="metadata-entry">
          <xsl:with-param name="contents">
            <xsl:if test="position() = 1">
              <!-- a named anchor for the contrib goes with its
              first member -->
              <xsl:call-template name="named-anchor"/>
              <!-- so do any contrib-ids -->
              <xsl:apply-templates mode="metadata-inline"
                select="../contrib-id"/>
            </xsl:if>
            <xsl:apply-templates select="." mode="metadata-inline"/>
            <xsl:if test="position() = last()">
              <xsl:apply-templates mode="metadata-inline"
                select="degrees | xref"/>
              <!-- xrefs in the parent contrib-group go with the last member
              of *each* contrib in the group -->
              <xsl:apply-templates mode="metadata-inline"
                select="following-sibling::xref"/>
            </xsl:if>
            
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:if test="@equal-contrib='yes'">
        <xsl:call-template name="metadata-entry">
          <xsl:with-param name="contents">
            <span class="generated">(Equal contributor)</span>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </div>
  </xsl:template>
  
  
  <!-- end of contrib -->
  
  
  
  <!--<xsl:template match="contrib" mode="inline-name">-->
  
  <xsl:template match="isbn | issn" mode="metadata" priority="0.5">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">
        <xsl:value-of select="upper-case(local-name())"/>
        <xsl:for-each select="@content-type">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>)</xsl:text>
        </xsl:for-each>
        <xsl:text>:</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-meta/publisher" mode="metadata">
    <xsl:call-template name="metadata-area">
      <xsl:with-param name="label">Publisher</xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="metadata"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-meta/edition" mode="metadata">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">Edition</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-meta/pub-history" mode="metadata">
    <xsl:call-template name="metadata-area">
      <xsl:with-param name="label">Publication history</xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="metadata"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  
  <xsl:template match="pub-history/date" mode="metadata">
    <xsl:call-template name="metadata-labeled-entry">
      <xsl:with-param name="label">
        <xsl:text>Date</xsl:text>
        <xsl:for-each select="@date-type">
          <xsl:choose>
            <xsl:when test=".='accepted'"> accepted</xsl:when>
            <xsl:when test=".='received'"> received</xsl:when>
            <xsl:when test=".='rev-request'"> revision requested</xsl:when>
            <xsl:when test=".='rev-recd'"> revision received</xsl:when>
            <xsl:otherwise>
              <xsl:text> </xsl:text>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:call-template name="format-date"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-meta/permissions" mode="metadata">
    <xsl:call-template name="metadata-area">
      <xsl:with-param name="label">Rights and permissions</xsl:with-param>
      <xsl:with-param name="contents">
        <xsl:apply-templates mode="metadata"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  
  
</xsl:stylesheet>
