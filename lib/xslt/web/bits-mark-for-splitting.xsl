<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ojf="https://github.com/wendellpiez/oXygenJATSframework/ns"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!--
   
    This stylesheet conditionally marks 'book-part' or 'sec' elements in the source for splitting.
    
    As presently set, -all- book-parts (including when they are nested) but -no- sec elements are so marked.
    This is easily adjusted by tweaking templates in this stylesheet.
    
    For example, maybe only book-part elements at the top level should be split out; or all book-parts and all secs;
    or any of these marked for splitting (in an earlier phases) in an earlier workflow step, or something else
    entirely.
  
    Also adds IDs when they are missing.
    -->

  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="book-part | sec">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="not(matches(@id,'^\i\c*$'))">
        <xsl:attribute name="id" select="string-join((local-name(),generate-id(.)),'-')"/>
      </xsl:if>
      <xsl:apply-templates select="." mode="mark-for-split"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*" mode="mark-for-split"/>

  <!-- Match any element, where splits should be made, in this mode.
       Splits can be made at multiple levels.
       
       E.g. match="book-part[empty(ancestor::book-part)]" - top-level book-parts only
            match="book-part | sec" - any book-part *or* sec element
            match="book-part[tokenize(@specific-use,'\s+')='split']" - any book-part that includes 'split' in its @specific-use value -->
  
  <!-- By default, splits at any book-part at any level (recursive) -->
  <xsl:template match="book-part" mode="mark-for-split">
    <xsl:attribute name="ojf:split" select="local-name(.)"/>
  </xsl:template>

</xsl:stylesheet>