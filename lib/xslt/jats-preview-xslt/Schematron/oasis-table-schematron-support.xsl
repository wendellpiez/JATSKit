<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:p="http://www.wendellpiez.com/oasis-tables/util"
  xmlns="http://docbook.org/ns/docbook"
  xpath-default-namespace="http://www.niso.org/standards/z39-96/ns/oasis-exchange/table"
  exclude-result-prefixes="xs"
  version="2.0">
  
<!-- XSLT in support of Schematron validation for OASIS tables
     (provided in oasis-table.sch) -->
  
  <xsl:import href="../xslt/oasis-tables/oasis-table-normalize.xsl"/>
  
  <!-- for debugging 
  <xsl:template match="/">
    <normalized-tables>
      <xsl:copy-of select="$all-normalized"/>
    </normalized-tables>
  </xsl:template>-->
  
  <!-- For retrieving information from elements in tables
       after normalization -->
  <xsl:variable name="all-normalized">
    <xsl:apply-templates select="//table" mode="p:normalize-table"/>
  </xsl:variable>
  
<!-- Functions called by Schematron:
p:rowno
p:actual-cols
p:across
p:down
p:align
p:colspec-for-entry
p:colwidth-unit

  -->
  
  <xsl:key name="normalized" match="*[exists(@p:gen-id)]" use="@p:gen-id"/>
  
  <xsl:key name="entry-by-row" match="entry" use="p:down(.)"/>
  
  <xsl:key name="colspec-by-no" match="colspec" use="p:colno(.)"/>
  
  <xsl:function name="p:normalized">
    <!-- Returns any table element's normalized counterpart -->
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="key('normalized',generate-id($e),$all-normalized)"/>
  </xsl:function>
  
  <xsl:function name="p:rowno" as="xs:integer">
    <xsl:param name="r" as="element(row)"/>
    <xsl:sequence select="p:normalized($r)/@p:rowno[. castable as xs:integer]/xs:integer(.)"/>  
  </xsl:function>
  
  <xsl:function name="p:actual-cols">
    <!-- Returns the actual number of columns claimed by cells in a row. -->
    <xsl:param name="r" as="element(row)"/>
    <xsl:sequence select="max(key('entry-by-row',p:normalized($r)/@p:rowno,$r/ancestor::TGROUP[1])/p:across(.))"/>
  </xsl:function>
  
  <xsl:function name="p:colwidth-unit" as="xs:string?">
    <!-- for a colspec, returns the unit, defaulting to 'pt' if a value
         is given without a unit, and nothing if the unit is not
         recognized -->
    <xsl:param name="colspec" as="element(colspec)"/>
    <!-- the unit is the width stripped of spaces and numbers -->
    <!--<xsl:variable name="unit" select="$colspec/@colwidth/replace(.,'[^\p{L}%\*]','')[normalize-space(.)]"/>-->
    <xsl:variable name="unit" select="$colspec/@colwidth/replace(.,'\d','')[normalize-space(.)]"/>
    <xsl:choose>
      <xsl:when test="false()"/>
      <!-- a colspec with a numeric width gets its unit, 'pt' if no unit
           is given, nothing if an unrecognized unit is given -->
      <xsl:when test="matches($colspec/@colwidth,'\d')">
        <xsl:sequence select="(lower-case($unit),'pt')[1][matches(.,'^(\*|in|pc|pt|cm|mm|px|%)$')]"/>
      </xsl:when>
      <!-- a colspec whose width is '*', or that has no width given, is assumed to be '*' -->
      <!--<xsl:when test="matches($colspec/@colwidth,'^\s*\*\s*$') or empty($colspec/@colwidth)">
        <xsl:sequence select="'*'"/>
      </xsl:when>-->
      <!-- otherwise nothing -->
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="p:align" as="xs:string">
    <!-- returns an alignment value for an entry -->
    <xsl:param name="entry" as="element(entry)"/>
    <!-- disabling alignment of 'char' specified on tgroup; this is valid,
         but without a @char or @charoff on tgroup it is unclear how it
         should work -->
    <xsl:variable name="t" select="$entry/ancestor::tgroup[1]"/>
    <xsl:variable name="colspec" select="p:colspec-for-entry($entry)"/>
    <!-- taking first available: entry's align, colspec's align, tgroup's align, 'left' -->
    <xsl:sequence select="lower-case(($entry/@align,$colspec/@align,$t/@align,'left')[1])"/>
  </xsl:function>
  
  <xsl:function name="p:colspec-for-entry" as="element(colspec)?"><!-- saxon:memo-function="yes" -->
    <!-- Returns the normalized COLSPEC element for a given ENTRY -->
    <xsl:param name="entry" as="element(entry)"/>
    <xsl:variable name="t" select="$entry/ancestor::tgroup[1]"/>
    <!-- $nominal COLSPEC is one actually named by the entry. -->
    <xsl:variable name="nominal-colspec" select="$entry/(@namest,@colname)[1]/key('colspec-by-name',.,$t)"/>
    <!-- $positioned-colspec is indicated by the entry's horizontal position -->
    <xsl:variable name="positioned-colspec" select="$entry/key('colspec-by-no',p:across(.)[1],$t)[1]"/>
    <!-- under certain error conditions there might be more than one of either nominal or
         positioned colspecs, so we only return the first -->
    <xsl:sequence select="($nominal-colspec,$positioned-colspec)[1]"/>
  </xsl:function>
  
  <xsl:function name="p:overlaps" as="element(entry)*">
    <!-- Returns any entries occupying the same position (across and down)
         as a given entry. -->
    <xsl:param name="e" as="element(entry)"/>
    <xsl:sequence
      select="key('entry-by-row',$e/p:down(.),$e/ancestor::tgroup)[p:across(.) = p:across($e)]
              except $e"/>
  </xsl:function>
  
  <xsl:function name="p:across">
    <!-- Returns the 'across' index values of an entry -->
    <xsl:param name="e" as="element(entry)"/>
    <xsl:sequence select="p:values(p:normalized($e)/@p:across)"/>
  </xsl:function>

  <xsl:function name="p:down">
    <!-- Returns the 'across' index values of an entry -->
    <xsl:param name="e" as="element(entry)"/>
    <xsl:sequence select="p:values(p:normalized($e)/@p:down)"/>
  </xsl:function>
</xsl:stylesheet>