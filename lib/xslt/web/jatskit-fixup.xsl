<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- We need to add titles to book-parts and 'sec' elements that have none ...
       this is tricky, since in the case of book-part, the title is three steps down
       a branch of optional elements, any of which may have to be added. -->
  
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
  
  <xsl:template match="title-group | sec">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="label"/>
      <xsl:if test="empty(title)">
        <xsl:sequence select="$book-part-title-proxy/title-group/title"/>
      </xsl:if>
      <xsl:apply-templates select="* except label"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>