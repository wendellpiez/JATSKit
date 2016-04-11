<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:p="http://www.wendellpiez.com/oasis-tables/util"
  xpath-default-namespace="http://www.niso.org/standards/z39-96/ns/oasis-exchange/table"
  exclude-result-prefixes="#all">
    
  <!-- The imported stylesheet provides table normalization. -->
  <xsl:import href="oasis-table-normalize.xsl"/>

  <xsl:strip-space elements="table tgroup thead
    tbody tfoot row"/>

  <xsl:attribute-set name="default-cell-styling">
    <xsl:attribute name="border-color">black</xsl:attribute>
    <xsl:attribute name="border-width">thin</xsl:attribute>
    <xsl:attribute name="padding">4pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="table-block-styling">
    <xsl:attribute name="space-before">16pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="table-head-styling">
    <xsl:attribute name="background-color">inherit<!--lightgrey--></xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="table-foot-styling">
    <xsl:attribute name="background-color">inherit<!--lightgrey--></xsl:attribute>
  </xsl:attribute-set>
  
  
  <!-- $default-border-style sets the style of borders only when set to appear -->
  <xsl:param name="default-border-style">solid</xsl:param>
  
  <!--<xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>-->
  
  <!-- Key 'entry-by-row' returns all entries appearing in a row, whether
       given in the row element or in an earlier row and spanning. -->
  <xsl:key name="entry-by-row" match="entry" use="p:values(@p:down)"/>
  
  <xsl:key name="colspec-by-no" match="colspec" use="p:colno(.)"/>
  
  <xsl:template match="table">
    <!-- We have to bind the normalized table to a temporary tree so
         we can key into it. -->
    <xsl:variable name="normalized-table" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="." mode="p:normalize-table"/>
      </xsl:document>
    </xsl:variable>


    <!-- Now having done so, we need to process the contents of the (normalized) table
         (i.e. its table element) not the tree itself. -->
    <xsl:for-each select="$normalized-table/table">
      <fo:block xsl:use-attribute-sets="table-block-styling">
        <xsl:apply-templates/>
      </fo:block>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tgroup">
    <!-- NISO JATS does not include @pgwide, but OASIS permits it.
         According to the spec, any value not 0 means page wide. -->
    <xsl:variable name="pgwide" select="../@pgwide = '1'"/>
    <!--<xsl:variable name="continuing" select="exists(following-sibling::tgroup)"/>
    <xsl:variable name="continued" select="exists(following-sibling::tgroup)"/>-->
    <!--<xsl:variable name="classes"
      select="'tgroup','pgwide'[$pgwide],'cont'[$continuing],'contd'[$continued]"/>-->
    <fo:table>
      <xsl:if test="$pgwide">
        <xsl:attribute name="width">100%</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </fo:table>
  </xsl:template>
  
  <xsl:template match="colspec">
    <xsl:variable name="width"
      select="if (exists(p:star-value(.)))
      then p:relative-percentage(.,../colspec) else @colwidth/lower-case(.)"/>
    <fo:table-column column-width="{$width}" p:star-value="{p:star-value(.)}"/>
  </xsl:template>
  
  <xsl:template match="thead">
    <fo:table-header>
      <xsl:apply-templates/>
    </fo:table-header>
  </xsl:template>
  
  <!-- Following the OASIS spec TR 9901:1999, NISO 1.0 has no tfoot,
       but earlier versions of the CALS/OASIS table model do -->
  <xsl:template match="tfoot">
    <fo:table-footer>
      <xsl:apply-templates/>
    </fo:table-footer>
  </xsl:template>
  
  <xsl:template match="tbody">
    <fo:table-body>
      <xsl:apply-templates/>
    </fo:table-body>
  </xsl:template>
  
  <xsl:template match="row">
    <!--<xsl:message>
      <xsl:text> row </xsl:text>
      <xsl:value-of select="@p:rowno"/>
      <xsl:text> inside </xsl:text>
      <xsl:value-of select="name(..)"/>
    </xsl:message>-->
    
    <fo:table-row>
      <xsl:apply-templates select="entry"/>
    </fo:table-row>
  </xsl:template>
  
  <xsl:template match="thead/*/entry">
    <fo:table-cell xsl:use-attribute-sets="default-cell-styling table-head-styling">
      <xsl:call-template name="cell-properties"/>
      <xsl:apply-templates select="." mode="cell-contents"/>
    </fo:table-cell>
  </xsl:template>
 
  <xsl:template match="tfoot/*/entry">
    <fo:table-cell xsl:use-attribute-sets="default-cell-styling table-foot-styling">
      <xsl:call-template name="cell-properties"/>
      <xsl:apply-templates select="." mode="cell-contents"/>
    </fo:table-cell>
  </xsl:template>
  
  <xsl:template match="entry">
    <fo:table-cell xsl:use-attribute-sets="default-cell-styling">
      <xsl:call-template name="cell-properties"/>
      <xsl:apply-templates select="." mode="cell-contents"/>
    </fo:table-cell>
  </xsl:template>

  <xsl:template name="cell-properties">    
    <!-- get valign from the first available: the entry, its row,
         or its thead, tfoot or tbody ancestor -->
    <xsl:apply-templates
      select="(@valign,parent::row/@valign,
      ancestor::*[self::thead|self::tfoot|self::tbody]/@valign)[1]"/>
    <!-- @morerows will determine row span -->
    <xsl:apply-templates select="@morerows[. castable as xs:integer]"/>
    <!-- column span is indicated by values assigned to @p:across
         (in table normalization) -->
    <xsl:if test="count(p:values(@p:across)) > 1">
      <xsl:attribute name="number-columns-spanned" select="count(p:values(@p:across))"/>
    </xsl:if>

    <!-- p:border-spec(.) returns an p:border element indicating border placement -->
    <xsl:apply-templates select="p:border-spec(.)"/>
    

  </xsl:template>
  
   
  <xsl:template match="entry" mode="cell-contents">
    <fo:block>
      <xsl:if test="not(p:align(.)='char')">
        <xsl:attribute name="text-align" select="p:align(.)"/>
      </xsl:if>
      <xsl:apply-templates/>
      <!-- FOR DEBUGGING: <xsl:text> (</xsl:text>
      <xsl:value-of select="a:across(.)" separator=","/>
      <xsl:text> / </xsl:text>
      <xsl:value-of select="a:down(.)" separator=","/>
      <xsl:text>)</xsl:text>-->
    </fo:block>
  </xsl:template>
  
  <!--<xsl:template match="entry[a:align(.)='char']" mode="cell-contents">
    <!-\- treats contents as a string, ignoring any inline markup -\->
    <!-\- character aligns at @charoff if given, or 50% -\-> 
    <xsl:variable name="colspec" select="a:colspec-for-entry(.)"/>
    <xsl:variable name="char" select="(@char/string(.),$colspec/@char/string(.),'')[1]"/>
    <xsl:variable name="charoff"
      select="(((@charoff,$colspec/@charoff))[. castable as xs:integer]/xs:integer(.),50)[1]"/>
    <fo:inline style="float:left; text-align: right; width:{$charoff}%">
      <xsl:value-of select=".[not(contains(.,$char)) or not($char)]"/>
      <xsl:value-of select="substring-before(.,$char)"/>
      <xsl:value-of select="$char[contains(current(),$char)]"/>
    </fo:inline>
    <fo:inline style="float: left; text-align: left; width:{100 - $charoff}%">
      <xsl:value-of select="substring-after(.,$char)[$char]"/>
      <xsl:value-of select="'&#xA0;'[not(contains(current(),$char)) or not($char)]"/>
    </fo:inline>
  </xsl:template>-->

  <xsl:template match="entry/@morerows">
    <xsl:if test="xs:integer(.) gt 0">
      <xsl:attribute name="number-rows-spanned">
        <xsl:value-of select="xs:integer(.) + 1"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@valign">
    <!-- top|middle|bottom -->
    <xsl:attribute name="display-align">
      <xsl:apply-templates select="." mode="valign-value"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template mode="valign-value" match="@valign[.='top']">before</xsl:template>
  <xsl:template mode="valign-value" match="@valign[.='middle']">center</xsl:template>
  <xsl:template mode="valign-value" match="@valign[.='bottom']">after</xsl:template>
  
  <!-- Mapping border classes to FO borders -->
  
  <!-- matching p:border[@class='xxxx-borders'] plus any that fall through by accident -->
  <xsl:template match="p:border"/>
  
  <xsl:template match="p:border[@class='txxx-borders']">
    <xsl:attribute name="border-top-style" select="$default-border-style"/>
  </xsl:template>
  
  <xsl:template match="p:border[@class='xbxx-borders']">
    <xsl:attribute name="border-bottom-style" select="$default-border-style"/>
  </xsl:template>
  
  <xsl:template match="p:border[@class='xxlx-borders']">
    <xsl:attribute name="border-left-style" select="$default-border-style"/>
  </xsl:template>
  
  <xsl:template match="p:border[@class='xxxr-borders']">
    <xsl:attribute name="border-right-style" select="$default-border-style"/>
  </xsl:template>
  
  <xsl:template match="p:border[@class='tbxx-borders']">
    <xsl:attribute name="border-top-style" select="$default-border-style"/>
    <xsl:attribute name="border-bottom-style" select="$default-border-style"/>
  </xsl:template>
  
  <xsl:template match="p:border[@class='txlx-borders']">
    <xsl:attribute name="border-top-style" select="$default-border-style"/>
    <xsl:attribute name="border-left-style" select="$default-border-style"/>
  </xsl:template>
  
  <xsl:template match="p:border[@class='txxr-borders']">
    <xsl:attribute name="border-top-style" select="$default-border-style"/>
    <xsl:attribute name="border-right-style" select="$default-border-style"/>
  </xsl:template>
  
  <xsl:template match="p:border[@class='xblx-borders']">
    <xsl:attribute name="border-bottom-style" select="$default-border-style"/>
    <xsl:attribute name="border-left-style" select="$default-border-style"/>
  </xsl:template>
  
  <xsl:template match="p:border[@class='xbxr-borders']">
    <xsl:attribute name="border-bottom-style" select="$default-border-style"/>
    <xsl:attribute name="border-right-style" select="$default-border-style"/>
  </xsl:template>
  
  <xsl:template match="p:border[@class='xxlr-borders']">
    <xsl:attribute name="border-left-style" select="$default-border-style"/>
    <xsl:attribute name="border-right-style" select="$default-border-style"/>
  </xsl:template>
  
  <xsl:template match="p:border[@class='tblx-borders']">
    <xsl:attribute name="border-top-style" select="$default-border-style"/>
    <xsl:attribute name="border-bottom-style" select="$default-border-style"/>
    <xsl:attribute name="border-left-style" select="$default-border-style"/>
  </xsl:template>
  
  <xsl:template match="p:border[@class='tbxr-borders']">
    <xsl:attribute name="border-top-style" select="$default-border-style"/>
    <xsl:attribute name="border-bottom-style" select="$default-border-style"/>
    <xsl:attribute name="border-right-style" select="$default-border-style"/>
  </xsl:template>
  
  <xsl:template match="p:border[@class='txlr-borders']">
    <xsl:attribute name="border-top-style" select="$default-border-style"/>
    <xsl:attribute name="border-left-style" select="$default-border-style"/>
    <xsl:attribute name="border-right-style" select="$default-border-style"/>
  </xsl:template>
  
  <xsl:template match="p:border[@class='xblr-borders']">
    <xsl:attribute name="border-bottom-style" select="$default-border-style"/>
    <xsl:attribute name="border-left-style" select="$default-border-style"/>
    <xsl:attribute name="border-right-style" select="$default-border-style"/>
  </xsl:template>
  
  <xsl:template match="p:border[@class='tblr-borders']">
    <xsl:attribute name="border-top-style" select="$default-border-style"/>
    <xsl:attribute name="border-bottom-style" select="$default-border-style"/>
    <xsl:attribute name="border-left-style" select="$default-border-style"/>
    <xsl:attribute name="border-right-style" select="$default-border-style"/>
  </xsl:template>

  
</xsl:stylesheet>