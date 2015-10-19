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
  
  <xsl:function name="jatskit:book-code" as="xs:string">
    <xsl:param name="doc" as="document-node()"/>
    <!-- Trimming for an aft from the document's URI to get a nominal code.
         Note: does not necessarily match \i\c* (an XML name) so not safe as an ID. -->
    <xsl:variable name="book-basename" select="replace(document-uri($doc),'^.*/|\.\w*$','')"/>
    
    <xsl:sequence select="$book-basename"/>    
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
</xsl:stylesheet>