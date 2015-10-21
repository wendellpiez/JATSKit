<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:include href="jatskit-util.xsl"/>
  
  <xsl:template match="/">
    <xsl:call-template name="make-html-page">
      <xsl:with-param name="attribute-proxies" as="element()?">
        <html>
          <xsl:call-template name="locate-page">
            <xsl:with-param name="page-label"  as="xs:string">toc</xsl:with-param>
            <xsl:with-param name="page-format" as="xs:string">html</xsl:with-param>
          </xsl:call-template>
        </html>        
      </xsl:with-param>      
      <xsl:with-param name="html-contents">
        <xsl:for-each-group select="/book/(book-body | bookback)/book-part" group-by="true()">
          <ul>
            <xsl:apply-templates select="current-group()" mode="directory"/>
          </ul>
        </xsl:for-each-group>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="*" mode="directory">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="book-part" mode="directory">
    <li>
      <xsl:apply-templates select="." mode="title-link"/>
      <xsl:for-each-group select="*/sec | */book-part" group-by="true()">
        <ul>
          <xsl:apply-templates select="current-group()" mode="#current"/>
        </ul>
      </xsl:for-each-group>
    </li>
  </xsl:template>
  
  <xsl:template match="sec" mode="directory">
    <li>
      <xsl:apply-templates select="." mode="title-link"/>
      <xsl:for-each-group select="sec" group-by="true()">
        <ul>
          <xsl:apply-templates select="current-group()" mode="#current"/>
        </ul>
      </xsl:for-each-group>
    </li>
  </xsl:template>
  
  <xsl:template match="book-part | sec" mode="title-link">
    <xsl:variable name="title" select="book-part-meta/title-group/title | title"/>
    <p>
       <xsl:apply-templates select="." mode="target-link">
         <xsl:with-param name="path">contents</xsl:with-param>
         <xsl:with-param name="text">
           <xsl:apply-templates select="$title"/>
           <xsl:if test="empty($title)">[Untitled]</xsl:if>
         </xsl:with-param>
       </xsl:apply-templates>
    </p>
  </xsl:template>
  
  
</xsl:stylesheet>