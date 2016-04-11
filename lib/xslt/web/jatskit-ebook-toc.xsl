<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  xmlns:epub="http://www.idpf.org/2007/ops"
  exclude-result-prefixes="xs jatskit"
  version="2.0">

  <xsl:import href="jatskit-ebook-html.xsl"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="book"/>
  </xsl:template>
  
  <xsl:template match="book">
    <xsl:call-template name="make-html-page">
      <xsl:with-param name="attribute-proxies" as="element()?">
        <html class="nav">
          <xsl:call-template name="locate-page">
            <xsl:with-param name="page-label"  as="xs:string">toc</xsl:with-param>
            <xsl:with-param name="page-format" as="xs:string">xhtml</xsl:with-param>
          </xsl:call-template>
        </html>        
      </xsl:with-param>      
      <xsl:with-param name="html-contents">
        <nav epub:type="toc">
          <xsl:for-each select="book-meta/book-title-group/book-title">
            <h1>
              <xsl:apply-templates/>
              <xsl:text>: Table of Contents</xsl:text>
            </h1>
          </xsl:for-each>
          <ol>
            <xsl:call-template name="toc-component-links">
              <xsl:with-param name="pages" as="element()*">
                <jatskit:titlepage/>
                <jatskit:halftitle/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:for-each-group
              select="
                (front-matter | book-body | book-back)/
                (book-part | *[exists(named-book-part-body)] | ack)"
              group-by="true()">
              <xsl:apply-templates select="current-group()" mode="directory"/>
            </xsl:for-each-group>
            <xsl:call-template name="toc-component-links">
              <xsl:with-param name="pages" as="element()*">
                <jatskit:colophon/>
              </xsl:with-param>
            </xsl:call-template>
          </ol>
        </nav>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="toc-component-links">
    <xsl:param name="pages" as="element()+"/>
    <xsl:variable name="book-code" select="jatskit:book-code(/)"/>
    <xsl:for-each select="$pages">
      <li>
        <xsl:call-template name="jatskit-component-link">
          <xsl:with-param name="page" select="."/>
          <xsl:with-param name="book-code" select="$book-code"/>
        </xsl:call-template>
      </li>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="*" mode="directory">
    <li>
      <xsl:value-of select="local-name()"/>
    </li>
  </xsl:template>
  
  <xsl:template match="book-part | *[exists(named-book-part-body)] | ack" mode="directory">
    <li>
      <xsl:apply-templates select="." mode="title-link"/>
      <xsl:for-each-group select="*/sec | */book-part" group-by="true()">
        <ol>
          <xsl:apply-templates select="current-group()" mode="#current"/>
        </ol>
      </xsl:for-each-group>
    </li>
  </xsl:template>
  
  <xsl:template match="sec" mode="directory">
    <li>
      <xsl:apply-templates select="." mode="title-link"/>
      <xsl:for-each-group select="sec" group-by="true()">
        <ol>
          <xsl:apply-templates select="current-group()" mode="#current"/>
        </ol>
      </xsl:for-each-group>
    </li>
  </xsl:template>
  
  <xsl:template match="*[exists(named-book-part-body)]" mode="title-link">
    <xsl:variable name="title" select="book-part-meta/title-group/title | title"/>
    <xsl:apply-templates select="." mode="link-here">
      <xsl:with-param name="path">contents</xsl:with-param>
      <xsl:with-param name="text">
        <xsl:apply-templates select="$title" mode="link-text"/>
        <xsl:if test="empty($title)">
          <xsl:apply-templates select="@book-part-type" mode="link-text"/>
          <xsl:if test="empty(@book-part-type)">
            <xsl:value-of select="local-name()"/>
          </xsl:if>
        </xsl:if>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="ack" mode="title-link">
    <xsl:apply-templates select="." mode="link-here">
      <xsl:with-param name="path">contents</xsl:with-param>
      <xsl:with-param name="text">Acknowledgements</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="@book-part-type" mode="link-text">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="@book-part-type[.]" mode="link-text">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="book-part | sec" mode="title-link">
    <xsl:variable name="title" select="book-part-meta/title-group/title | title"/>
    <xsl:apply-templates select="." mode="link-here">
      <xsl:with-param name="path">contents</xsl:with-param>
      <xsl:with-param name="text">
        <xsl:apply-templates select="$title" mode="link-text"/>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  
  
</xsl:stylesheet>