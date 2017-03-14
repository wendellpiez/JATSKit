<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:template match="node() | @*" mode="#all">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- We need to add titles to book-parts that have none ...
       as a purely defensive measure. (So something is there at least at
       book-part level in the ToC.) -->
  
  <xsl:variable name="book-part-title-proxy" as="element(book-part-meta)">
    <book-part-meta>
      <title-group>
        <title>[UNTITLED]</title>
      </title-group>
    </book-part-meta>
  </xsl:variable>
  
  <xsl:template match="book-part">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:if test="empty(book-part-meta)">
        <xsl:sequence select="$book-part-title-proxy"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="book-part-meta">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="book-part-id, subj-group"/>
      <xsl:if test="empty(title-group)">
        <xsl:sequence select="$book-part-title-proxy/title-group"/>
      </xsl:if>
      <xsl:apply-templates select="* except (book-part-id, subj-group)"/>
    </xsl:copy>
  </xsl:template>
  
<!-- XXXX fixup here to permit untitled sections -->
  <xsl:template match="title-group">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="label"/>
      <xsl:if test="empty(title | article-title)">
        <xsl:sequence select="$book-part-title-proxy/title-group/title"/>
      </xsl:if>
      <xsl:apply-templates select="* except label"/>
    </xsl:copy>
  </xsl:template>
  
<!-- Mapping JATS into BITS for EPUB production. This spares downstream XSLT
     from having to do both formats. -->
  
  <xsl:template match="book">
  <book>
    <xsl:copy-of select="@* | //namespace::*"/>
    <xsl:call-template name="book-id"/>
    <xsl:apply-templates/>
  </book>
  </xsl:template>
  
  <xsl:template name="book-id">
    <xsl:variable name="made-id">book</xsl:variable>
    <xsl:attribute name="id">
      <xsl:value-of select="(@id,$made-id)[1]"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="article">
    <book>
      <xsl:copy-of select="@* | //namespace::*"/>
      <xsl:call-template name="book-id"/>
      <book-meta>
      <!-- mode book-meta permits necessary modifications to make a nominal book
        from a JATS article. Some slight adjustments are necessary. We are not aiming 
        for valid BITS, so JATS metadata is okay - as long as it is BITS-like enough -->
        <xsl:apply-templates mode="book-meta"
          select="front/journal-meta/* | front/article-meta/* | front/notes"/>
      </book-meta>
      <book-body>
        <book-part>
          <book-part-meta>
            <xsl:apply-templates select="front/*/(title-group | contrib-group)"/>
          </book-part-meta>
          <xsl:apply-templates select="body | back | sub-article | response"/>
        </book-part>
      </book-body>
    </book>
  </xsl:template>
  
  <xsl:template match="sub-article | response">
    <book-part>
      <xsl:for-each select="front | front-stub">
        <book-part-meta>
          <xsl:apply-templates select="journal-meta/*, article-meta/*, notes, self::front-stub/*"/>
        </book-part-meta>
      </xsl:for-each>
      <xsl:apply-templates select="body | back | sub-article | response"/>
    </book-part>
  </xsl:template>
  
  <xsl:template match="article-meta/title-group" mode="book-meta">
    <book-title-group>
      <xsl:apply-templates mode="#current"/>
    </book-title-group>
  </xsl:template>
  
  <xsl:template match="article-title" mode="book-meta">
    <book-title>
      <xsl:apply-templates/>
    </book-title>
  </xsl:template>
  
  <xsl:template match="article-title">
    <title>
      <xsl:apply-templates/>
    </title>
  </xsl:template>
  
  
</xsl:stylesheet>