<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  xmlns:svg="www.w3.org/2000/svg"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <!-- We call in a module from the NLM JATS Preview Stylesheets to cast
       elements in any namespace but MathML into the XHTML
       namespace. But we must also make a few other adjustments, since
       we're going to do our best to deliver valid XHTML ... -->
  
  <xsl:import href="../jats-preview-xslt/xslt/post/xhtml-ns.xsl"/>
  
  <!-- Comes in as 'web' when we are creating a non-EPUB ebook mockup. -->
  <xsl:param name="format" as="xs:string">epub</xsl:param>
  
  <!-- Conditionally overriding the imported template, which adds a PI calling a MathML stylesheet.
       (If we want this, it should probably go into a different pipeline step such as bind-to-URI.) -->
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- We want to keep the jatskit namespace, to head off any confusion.
       These should produce validation errors when found in final results
       (as indications of unaddressed issues). -->
  <xsl:template match="jatskit:*">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="p">
    <xsl:for-each-group select="node()" group-adjacent="jatskit:okay-inline(.)">
      <xsl:choose>
        <xsl:when test="current-grouping-key()">
          <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
            <xsl:copy-of select="parent::p/(@* except @id)"/>
            <xsl:choose>
              <xsl:when test="position() eq 1">
                <xsl:copy-of select="parent::p/@id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="class">
                  <xsl:value-of select="string-join((../@class,'contd'),' ')"/>
                </xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="current-group()"/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="current-group()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>
  
  <!-- Returns true() for elements permitted inside 'p' in (some sort of) XHTML. -->
  <xsl:function name="jatskit:okay-inline" as="xs:boolean">
    <xsl:param name="e" as="node()"/>
    <xsl:sequence select="$e/exists(self::text() | self::comment() | self::processing-instruction() |
      self::br | self::span | self::em | self::strong | self::dfn | self::code |
      self::samp | self::kbd | self::var | self::cite | self::abbr | self::acronym | self::q | self::tt |
      self::i | self::b | self::big | self::small | self::sub | self::sup | self::bdo | self::a | self::img |
      self::map | self::object | self::input | self::select | self::textarea | self::label | self::button |
      self::ruby | self::ins | self::del | self::script | self::noscript | self::math | self::svg:svg | self::mml:math)"/>
  </xsl:function>
</xsl:stylesheet>