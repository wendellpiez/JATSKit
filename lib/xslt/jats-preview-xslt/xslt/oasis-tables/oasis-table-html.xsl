<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:p="http://www.wendellpiez.com/oasis-tables/util"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.niso.org/standards/z39-96/ns/oasis-exchange/table">
    
  <!-- The imported stylesheet provides table normalization. -->
  <xsl:import href="oasis-table-normalize.xsl"/>
  
  <!-- The included stylesheet splits table cells set with align="char" -->
  <!-- NB: as delivered, this logic assumes table cell content is
        mixed content (text and/or inline elements), not block-level
        content. See the module for necessary adjustments in the latter case. -->
  <xsl:include href="oasis-split-char.xsl"/>
  
  <xsl:strip-space elements="table tgroup thead
    tbody tfoot row"/>

  <!-- Set $hard-styles to false() if you intend to call template 
       name="p:table-css" into the top of your HTML (or provide
       the equivalent CSS by other means) for more flexible and 
       controllable styling of tables with CSS.
       When in force, $hard-styles will include styling using @style
       at the element level for controlling borders.      
  -->
  <xsl:param name="p:hard-styles" select="false()"/>
  
  <!-- You can also override the default here -->
  <xsl:param name="p:default-cell-styling">border-color: black; border-width: thin; padding: 5px</xsl:param>
  <!-- Or tweak the m:table-css template itself -->
  
  <!-- $p:default-border-style sets the style of borders only when set to appear -->
  <xsl:param name="p:default-border-style">solid</xsl:param>
  
  <!-- Key 'entry-by-row' returns all entries appearing in a row, whether
       given in the row element or in an earlier row and spanning. -->
  <xsl:key name="entry-by-row" match="entry" use="p:values(@p:down)"/>
  
  <xsl:key name="colspec-by-no" match="colspec" use="p:colno(.)"/>
  
  <!-- call p:table-css template to generate an HTML 'style' element in the
       header of HTML output when $hard-styles is false() -->
  <xsl:template name="p:table-css">
    <!-- generates a CSS style element with settings for table borders -->
    <style type="text/css">
      <!-- collapsed borders are going to look better anytime borders are missing -->
      <xsl:text>&#xA;table.tgroup { border-collapse: collapse }</xsl:text>
      
      <!-- consecutive tgroups should have no vertical space -->
      <xsl:text>&#xA;table.tgroup.pgwide { width: 100% }</xsl:text>
      <xsl:text>&#xA;table.tgroup.cont { margin-bottom: 0px }</xsl:text>
      <xsl:text>&#xA;table.tgroup.contd { margin-top: 0px }</xsl:text>
      <xsl:text>&#xA;td, th { </xsl:text>
      <xsl:value-of select="$p:default-cell-styling"/>
      <xsl:text> }</xsl:text>
      
      <xsl:for-each select="$p:border-specs">
        <xsl:text>&#xA;.</xsl:text>
        <xsl:value-of select="@class"/>
        <xsl:text> { </xsl:text>
        <xsl:value-of select="@style"/>
        <xsl:text> } </xsl:text>
      </xsl:for-each>
      <xsl:text>&#xA;</xsl:text>
    </style>
  </xsl:template>
  
  <xsl:template name="p:assign-class">
    <xsl:param name="class" select="local-name()"/>
    <xsl:if test="normalize-space($class) and not($p:hard-styles)">
      <xsl:attribute name="class" select="$class"/>
    </xsl:if>
  </xsl:template>
  
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
      <div>
        <xsl:call-template name="p:assign-class"/>
        <xsl:apply-templates/>
      </div>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tgroup">
    <!-- NISO JATS does not include @pgwide, but OASIS permits it.
         According to the spec, any value not 0 means page wide. -->
    <xsl:variable name="pgwide" select="../@pgwide='1'"/>
    <xsl:variable name="continuing" select="exists(following-sibling::tgroup)"/>
    <xsl:variable name="continued" select="exists(following-sibling::tgroup)"/>
    <xsl:variable name="classes"
      select="'tgroup','pgwide'[$pgwide],'cont'[$continuing],'contd'[$continued]"/>
    <table>
      <xsl:call-template name="p:assign-class">
        <xsl:with-param name="class" select="string-join($classes,' ')"/>
      </xsl:call-template>
      <xsl:if test="$p:hard-styles">
        <xsl:attribute name="style">
          <xsl:text>border-collapse: collapse</xsl:text>
          <xsl:if test="$pgwide">; width: 100%</xsl:if>
          <xsl:if test="$continuing">; margin-bottom: 0px</xsl:if>
          <xsl:if test="$continued">; marging-top: 0px</xsl:if>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  
  <xsl:template match="colspec">
    <xsl:variable name="width"
      select="if (exists(p:star-value(.)))
      then p:relative-percentage(.,../colspec) else @colwidth/lower-case(.)"/>
    <col width="{$width}"/>
  </xsl:template>
  
  <xsl:template match="thead">
    <thead>
      <xsl:call-template name="p:assign-class"/>
      <xsl:apply-templates/>
    </thead>
  </xsl:template>
  
  <!-- OASIS spec TR 9901:1999 has no tfoot,
       but earlier versions of the CALS/OASIS table model do -->
  <xsl:template match="tfoot">
    <tfoot>
      <xsl:call-template name="p:assign-class"/>
      <xsl:apply-templates/>
    </tfoot>
  </xsl:template>
  
  <xsl:template match="tbody">
    <tbody>
      <xsl:call-template name="p:assign-class"/>
      <xsl:apply-templates/>
    </tbody>
  </xsl:template>
  
  <xsl:template match="row">
    <tr>
      <xsl:call-template name="p:assign-class"/>
      <xsl:apply-templates select="entry"/>
    </tr>
  </xsl:template>
  
  <xsl:template match="thead/*/entry">
    <th>
      <xsl:call-template name="cell-properties"/>
      <xsl:apply-templates select="." mode="cell-contents"/>
    </th>
  </xsl:template>
 
  <xsl:template match="tfoot/*/entry">
    <th>
      <xsl:call-template name="cell-properties"/>
      <xsl:apply-templates select="." mode="cell-contents"/>
    </th>
  </xsl:template>
  
  <xsl:template match="entry">
    <td>
      <xsl:call-template name="cell-properties"/>
      <xsl:apply-templates select="." mode="cell-contents"/>
    </td>
  </xsl:template>

  <xsl:template name="cell-properties">    
    <!-- get valign from the first available: the entry, its row,
         or its thead, tfoot or tbody ancestor -->
    <!--<xsl:if test="not(p:align(.)='char')">
      
    </xsl:if>
    -->
    <xsl:attribute name="align" select="p:align(.)"/>
    <xsl:apply-templates
      select="(@valign,parent::row/@valign,
      ancestor::*[self::thead|self::tfoot|self::tbody]/@valign)[1]"/>
    <!-- @morerows will determine row span -->
    <xsl:apply-templates select="@morerows[. castable as xs:integer]"/>
    <!-- column span is indicated by values assigned to @p:across
         (in table normalization) -->
    <xsl:if test="count(p:values(@p:across)) > 1">
      <xsl:attribute name="colspan" select="count(p:values(@p:across))"/>
    </xsl:if>

    <!-- p:border-spec(.) returns an p:border element indicating border placement -->
    <xsl:copy-of select="p:border-spec(.)/@class"/>
    <xsl:if test="$p:hard-styles">
      <xsl:attribute name="style"
        select="string-join(($p:default-cell-styling,p:border-spec(.)/@style),'; ')"/>
    </xsl:if>
  </xsl:template>
  
   
  <xsl:template match="entry" mode="cell-contents">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="entry[p:align(.)='char']" mode="cell-contents">
    <!-- Splits the entry into p:left and p:right by calling
         oasis-split-char.xsl; then processes them. -->
    <xsl:variable name="colspec" select="p:colspec-for-entry(.)"/>
    <xsl:variable name="split-cell">
      <xsl:apply-templates select="." mode="p:split-char">
        <xsl:with-param name="char" select="(@char,$colspec/@char,'boo')[1]" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:apply-templates select="$split-cell" mode="split-cell">
      <xsl:with-param name="charoff"
        select="(@charoff,$colspec/@charoff)[1]"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="p:left" mode="split-cell">
    <xsl:param name="charoff" required="yes"/>
    <span style="display: block; float: left; text-align: right; width:{$charoff}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="p:right" mode="split-cell">
    <span style="display: block; float: left; text-align: left">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="entry/@morerows">
    <xsl:if test="xs:integer(.) gt 0">
      <xsl:attribute name="rowspan">
        <xsl:value-of select="xs:integer(.) + 1"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@valign">
    <!-- top|middle|bottom -->
    <xsl:attribute name="valign" select="."/>
  </xsl:template>
  
</xsl:stylesheet>