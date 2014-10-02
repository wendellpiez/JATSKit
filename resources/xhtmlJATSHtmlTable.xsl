<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
  xmlns:f="http://www.oxygenxml.com/xsl/functions" exclude-result-prefixes="xsl e f" version="2.0">

  <!-- HTML table conversion -->

  <xsl:template match="e:table">
    <table>
      <xsl:apply-templates select="@* | * | text()"/>
    </table>
  </xsl:template>

  <xsl:template match="e:colgroup">
    <colgroup>
      <xsl:if test="@span">
        <xsl:attribute name="span" select="@span"/>
      </xsl:if>
      <xsl:if test="@align">
        <xsl:attribute name="align"
          select="translate(@align, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:if>
      <xsl:if test="@width">
        <xsl:attribute name="width" select="@width"/>
      </xsl:if>
      <xsl:apply-templates select="@* | node()"/>
    </colgroup>
  </xsl:template>


  <xsl:template match="e:col">
    <col>
      <xsl:if test="@align">
        <xsl:attribute name="align"
          select="translate(@align, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:if>
      <xsl:if test="@width">
        <xsl:attribute name="width" select="@width"/>
      </xsl:if>
    </col>
  </xsl:template>

  <xsl:template
    match="e:caption 
                                | e:thead
                                | e:tfoot
                                | e:tbody
                                | e:tr
                                | e:th
                                | e:td">
    <xsl:element name="{local-name()}">
      <xsl:if test="number(@rowspan)">
        <xsl:attribute name="rowspan" select="@rowspan"/>
      </xsl:if>
      <xsl:if test="number(@colspan)">
        <xsl:attribute name="colspan" select="@colspan"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@align">
          <xsl:attribute name="align"
            select="translate(@align, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
        </xsl:when>
        <xsl:when test="e:p/@align">
          <xsl:attribute name="align"
            select="translate((e:p/@align)[1], 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"
          />
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@valign">
          <xsl:attribute name="valign"
            select="translate(@valign, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"
          />
        </xsl:when>
        <xsl:when test="e:p/@valign">
          <xsl:attribute name="valign"
            select="translate((e:p/@valign)[1], 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"
          />
        </xsl:when>
      </xsl:choose>
      <xsl:call-template name="keepDirection"/>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
