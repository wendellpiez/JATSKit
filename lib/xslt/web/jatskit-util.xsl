<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:param name="path-to-root" as="xs:string">.</xsl:param>
  
  <!-- Files may need links to CSS. 
       The assumption is that the file generated will be placed at the top level;
       a runtime override permits files to be placed elsewhere. -->
  <xsl:variable name="path-to-css" select="concat($path-to-root,'/css/jatskit-web.css')"/>

  <xsl:key name="element-by-id" match="*[exists(@id)]" use="@id"/>
  
  <xsl:template name="make-html-page">
    <xsl:param name="attribute-proxies" as="element()?"/>
    <xsl:param name="page-title">
      <xsl:apply-templates select="/descendant::book-title[1]" mode="plain"/>
    </xsl:param>
    <xsl:param name="html-contents">
      <xsl:apply-templates/>
    </xsl:param>
    <html>
      
      <xsl:apply-templates select="$attribute-proxies/@*" mode="html-page-attrs"/>
      <head>
        <title>
          <xsl:sequence select="$page-title"/>
        </title>
        <meta charset="utf-8"/>
        <link rel="stylesheet" type="text/css" href="{$path-to-css}"/>
      </head>
      <body>
        <xsl:sequence select="$html-contents"/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="@*" mode="html-page-attrs">
    <xsl:copy-of select="." copy-namespaces="no"/>
  </xsl:template>
  
  <xsl:template match="html/@base" mode="html-page-attrs"
    xmlns:opf="http://www.idpf.org/2007/opf">
    <!-- Non-standard @base becomes xml:base -->
    <xsl:attribute name="xml:base" select="."/>
  </xsl:template>
  
  <xsl:function name="jatskit:uri-basename" as="xs:string">
    <xsl:param name="file-uri" as="xs:string"/>
    <!-- Trimming for and aft from the document's URI to get a nominal code.
         Note: does not necessarily match \i\c* (an XML name) so not safe as an ID. -->
    <xsl:sequence select="replace($file-uri,'^.*/|\.\w*$','')"/>
  </xsl:function>

  <xsl:function name="jatskit:book-code" as="xs:string">
    <xsl:param name="e" as="node()"/>
    <xsl:sequence select="jatskit:uri-basename(document-uri(root($e)))"/>    
  </xsl:function>
  
  <xsl:function name="jatskit:page-id" as="xs:string">
    <xsl:param name="page" as="element(book)"/>
    <!-- We get a page-id for a (split) book from:
      (a) the assigned ID of the first component (probably a book-part) marked for splitting
          (there will always be one, and only one, on controlled inputs)
      (b) or, the @id of the book (if no splits are marked)
      (c) or, the string 'book' -->
    <xsl:sequence select="concat(($page//@jatskit:split/../@id,$page/@id,'book')[1],'-page')"/>
  </xsl:function>

  <xsl:function name="jatskit:page-path" as="xs:anyURI">
    <xsl:param name="book" as="element(book)"/>
    <xsl:sequence select="resolve-uri(concat(jatskit:book-code(root($book)),'/contents/',jatskit:page-id($book),'.html'),document-uri(root($book)))"/>
  </xsl:function>
  
  <xsl:function name="jatskit:current-lang" as="xs:string?">
    <xsl:param name="who" as="element()"/>
    <xsl:sequence select="$who/ancestor::*[exists(@xml:lang)][1]/@xml:lang/string(.)"/>
  </xsl:function>
  
  <xsl:template match="*" mode="target-link">
    <xsl:param name="path"/>
    <xsl:param name="text">
      <xsl:apply-templates mode="link-text"/>
    </xsl:param>
    <xsl:variable name="href">
      <xsl:apply-templates select="ancestor-or-self::*[exists(@jatskit:split)][1]" mode="id"/>
      <xsl:text>-page.html#</xsl:text>
      <xsl:apply-templates select="." mode="id"/>
    </xsl:variable>
    <a href="{string-join(($path,$href),'/')}">
      <xsl:sequence select="$text"/>
    </a>
  </xsl:template>
  
  <xsl:template match="*" mode="id">
    <xsl:value-of select="(@id,generate-id())[1]"/>
  </xsl:template>
  
  <xsl:template name="locate-page">
    <!-- Adds appropriate @id and @base attributes to any element;
      to used at the top ('html' elements) to write location attributes
      to be picked up by subsequent steps.
    
    So for file d:/path/to/books/BigBook.xml, where book-code is 'BigBook',
    with $page-label='toc' and $page-format='page', we get
      id="BigBook-toc" base="file:/d:/path/to/books/BigBook/Big-Book-toc.page -->
    <xsl:param name="page-label" as="xs:string"  required="yes"/>
    <xsl:param name="page-format" as="xs:string" required="yes"/>
    <xsl:variable name="page-code" select="string-join((jatskit:book-code(/),$page-label),'-')"/>
    
    <xsl:attribute name="id" select="$page-code"/>
    <xsl:attribute name="base" select="resolve-uri(concat(jatskit:book-code(/),'/',$page-code,'.html'),document-uri(/))"/>
  </xsl:template>
  
<!-- Attempts to produce an ISO formatted date string from a JATS/BITS 'date' element.
     Can be overridden or extended to support local date usage or dates not in English. -->
  <xsl:function name="jatskit:iso-date" as="xs:string">
    <xsl:param name="date" as="element(date)"/>
    <xsl:choose>
      <xsl:when test="$date/@iso-8601-date castable as xs:date">
        <xsl:value-of select="$date/@iso-8601-date"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of>
          <xsl:value-of select="$date/year"/>
          <xsl:variable name="month" select="$date/month[matches(.,'\d\d?')],
            index-of(('jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'),
            lower-case(substring($date/month,1,3)) )"/>
          <xsl:text>-</xsl:text>
          <xsl:value-of select="format-number($month,'00')"/>
          <xsl:text>-</xsl:text>
          <xsl:value-of select="format-number($date/day,'00')"/>
        </xsl:value-of>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>