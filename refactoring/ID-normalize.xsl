<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all">
  
<!-- Assigns (and rewrites) IDs on certain elements in JATS/BITS, according to a certain logic.
     Please extend or replace to meet local requirements! You could:
     
     Change where IDs are assigned (to a different set of elements or not overriding @id values
       already present, for example)
     
     Change how ID strings are generated
     
     
  -->
  
  <xsl:template match="node() | @*">
    <xsl:copy>
       <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>

  <!-- Any IDREFS attributes must also mapped. -->
  <xsl:template match="@rid | @headers | @glyph-data">
    <xsl:attribute name="rid" separator=" ">
      <xsl:apply-templates mode="id" select="key('element-by-id',tokenize(.,'\s+'))"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- It should go without saying that we need to be able to retrieve elements by their
       old IDs if we are going to rewrite references to them! -->
  <xsl:key name="element-by-id" match="*[exists(@id)]" use="@id"/>
  
  <!-- Match any element for which IDs should be auto-assigned.
       Existing IDs are overwritten. -->
  <xsl:template match="*[exists(@id)] |
    book-part | sec | fig | table-wrap | boxed-text | chem-struct-wrap | fig | disp-formula">
    <!-- No op inside 'refactoring' <xsl:message>
      <xsl:value-of select="name()"/>
      <xsl:for-each select="@id">[@id='<xsl:value-of select="."/>']</xsl:for-each>
      <xsl:text> now has @id '</xsl:text>
      <xsl:value-of select="jatskit:id(.)"/>
      <xsl:text>'</xsl:text>
    </xsl:message>-->
    <xsl:copy>
      <xsl:apply-templates select="@* except @id"/>
      <xsl:attribute name="id">
        <xsl:apply-templates mode="id" select="."/>
      </xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Mode 'id' is where IDs are generated. Templates here should return strings. -->

  <!-- Default rule: construct an ID for an element numbering it among elements of the same type,
       within the same article or book-part. (Or book if we are outside a book-part entirely, which
       is possible in some corners of 'book' e.g. 'book-meta'.) -->
  <!-- By this rule, in general, an ID will have up to three components:
         - document id (i.e. /article/@id or /book/@id)
         - book-part id (when there is a book-part)
         - element id (component within the book-part, article or book scope)
       Whichever of these are given will be combined with '_'.      
  -->

  <xsl:template match="*" mode="id" as="xs:string">
    <!-- By splicing together text bits with a separator, we account for the conditionality of all the bits
         that make up an ID. -->
    <xsl:value-of separator="_">
      <xsl:apply-templates select="ancestor::*[self::book-part | self::book | self::article][1]" mode="id"/>
      <xsl:value-of>
        <xsl:value-of select="translate(name(), ':', '')"/>
        <xsl:number level="any" from="article | book | book-part"/>
      </xsl:value-of>
    </xsl:value-of>
  </xsl:template>

  <xsl:template match="sec" mode="id" as="xs:string">
    <xsl:value-of separator="_">
      <xsl:apply-templates select="ancestor::*[self::book-part | self::book | self::article][1]" mode="id"/>
      <xsl:value-of>
        <xsl:text>sec</xsl:text>
        <xsl:number level="multiple" from="article | book | book-part" format="1-1"/>
      </xsl:value-of>
    </xsl:value-of>
  </xsl:template>

  <!-- Top-level book-parts are numbered flat across the document
       including everything (in front-matter, body and back) in a single sequence. -->
  <xsl:template match="book-part" mode="id" as="xs:string">
    <xsl:value-of separator="_">
      <xsl:apply-templates select="ancestor::book" mode="id"/>
      <xsl:value-of>
        <xsl:text>part</xsl:text>
        <xsl:number level="any" count="book-part[empty(ancestor::book-part)]" from="book"/>
      </xsl:value-of>
    </xsl:value-of>
  </xsl:template>
  
  <!-- Nested book-parts descend hierarchically from their book-part or equivalent container. -->
  <xsl:template match="book-part//book-part" mode="id" as="xs:string">
    <xsl:value-of separator="_">
      <xsl:value-of>
        <!-- First the ancestor book-part whose number is assigned in document scope -->
        <xsl:apply-templates select="ancestor::book-part[last()]" mode="id"/>
        <xsl:text>-</xsl:text>
        <xsl:number level="multiple" count="book-part//book-part" from="book-part[empty(ancestor::book-part)]" format="1-1"/>
      </xsl:value-of>
    </xsl:value-of>
  </xsl:template>
  
  <!-- At the top, the new ID (component) echoes the old ID. -->
  <xsl:template match="book | article" mode="id" as="xs:string">
    <xsl:value-of select="@id"/>
  </xsl:template>
  
</xsl:stylesheet> 