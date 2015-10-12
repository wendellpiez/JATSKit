<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:p="http://www.wendellpiez.com/oasis-tables/util"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:output indent="yes"/>
  
  <xsl:variable name="test" as="element(entry)">
    <entry align="char" char="." charoff="0.5in">
      <p>Here's some <emph>mixed content</emph>. Already. How does it look?</p>
    </entry>
  </xsl:variable>
  
  <!--<xsl:template match="/">
    <xsl:apply-templates select="$test" mode="p:split-char">
      <xsl:with-param name="char" select="string($test/@char)" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>-->
  
  <!--
    Uncomment this template if your table model contains *block-level*
      elements inside 'entry' (such as paragraphs) not just
      inline (mixed) content.
      Note that (unless you adjust the logic) the contents of *all*
      these blocks will be delivered by this stylesheet in
      p:left/p:right element pairs; the calling stylesheet will have
      to be adapted to deal with this.
      You might decide only to split the first paragraph, or all
      blocks of given types (excluding figures, for example), or
      something else depending on your content models.
    <xsl:template match="entry" mode="p:split-char">
      <xsl:param name="char" tunnel="yes" select="string(@char)"/>
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="p:split-char"/>
      </xsl:copy>
    </xsl:template>-->
  
  <xsl:template match="*" mode="p:split-char">
    <xsl:param name="char" tunnel="yes" select="string(@char)"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="left" as="node()*">
        <xsl:apply-templates select="node()[1]" mode="p:char-left">
          <xsl:with-param name="char" select="$char" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:variable name="right">
        <xsl:apply-templates select="node()[1]" mode="p:find-char">
          <xsl:with-param name="char" select="$char" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:variable>
      <p:left>
        <xsl:copy-of select="$left"/>
      </p:left>
      <xsl:if test="exists($right)">
        <p:right>
          <xsl:copy-of select="$right"/>
        </p:right>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*" mode="p:char-left">
    <xsl:param name="char" tunnel="yes"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()[1]" mode="#current"/>
    </xsl:copy>
    <xsl:if test="not(contains(.,$char))">
      <xsl:apply-templates select="following-sibling::node()[1]" mode="#current"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*" mode="p:find-char">
    <xsl:param name="char" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="contains(.,$char)">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates select="node()[1]" mode="p:find-char"/>
        </xsl:copy>
        <xsl:apply-templates select="following-sibling::node()[1]" mode="p:char-right"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="following-sibling::node()[1]" mode="p:find-char"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*" mode="p:char-right">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()[1]" mode="#current"/>
    </xsl:copy>
    <xsl:apply-templates select="following-sibling::node()[1]" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="comment() | processing-instruction()" mode="p:char-left p:char-right">
    <xsl:copy-of select="."/>
    <xsl:apply-templates select="following-sibling::node()[1]" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="comment() | processing-instruction()" mode="p:find-char">
    <xsl:apply-templates select="following-sibling::node()[1]" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="text()" mode="p:char-left">
    <xsl:param name="char" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="contains(.,$char)">
        <xsl:value-of select="substring-before(.,$char)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
        <xsl:apply-templates select="following-sibling::node()[1]" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text()" mode="p:find-char">
    <xsl:param name="char" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="contains(.,$char)">
        <xsl:value-of select="$char"/>
        <xsl:value-of select="substring-after(.,$char)"/>
        <xsl:apply-templates select="following-sibling::node()[1]" mode="p:char-right"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="following-sibling::node()[1]" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text()" mode="p:char-right">
    <xsl:copy-of select="."/>
    <xsl:apply-templates select="following-sibling::node()[1]" mode="#current"/>
  </xsl:template>

</xsl:stylesheet>