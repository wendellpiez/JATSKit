<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.idpf.org/2007/opf"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:include href="../web/jatskit-util.xsl"/>
  
  <xsl:variable name="relative-path" select="concat(jatskit:book-code(/),'/','JATSKit-book.opf')"/>
  <xsl:variable name="target-URI" select="resolve-uri($relative-path,document-uri(/))"/>
  
  <xsl:template match="/">
    <xsl:apply-templates mode="opf-metadata"/>
  </xsl:template>
 
  <xsl:template match="/book" mode="opf-metadata">
    <package version="2.0"> <!-- unique-identifier="article-doi" -->
      <xsl:attribute name="xml:base">
        <xsl:value-of select="$target-URI"/>
      </xsl:attribute>
      <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
<!--        <xsl:apply-templates select="/html/body/h2[@class='article-title']" mode="opf-metadata"/>
        <xsl:apply-templates select="/html/body/div[@class='author']/h3[@class='author']" mode="opf-metadata"/>
        <dc:language>en-US</dc:language> 
        <xsl:apply-templates select="/html/body/div[@class='legalnotice-block']" mode="opf-metadata"/>
        <dc:publisher>Balisage Series on Markup Technologies</dc:publisher> 
        <dc:identifier id="article-doi">
          <xsl:text>doi:</xsl:text>
<!-\-          <xsl:value-of select="$doi"/>-\->
        </dc:identifier>
-->      </metadata>
      <manifest>
        <item media-type="application/x-dtbncx+xml" id="ncx" href="{jatskit:book-code(/)}-epub.ncx"/>
        
        <item media-type="text/css" id="style" href="content/balisage-epub.css"/>
        <!-- <item id="pagetemplate" href="page-template.xpgt" media-type="application/vnd.adobe-page-template+xml"/> -->
<!--        <item media-type="application/xhtml+xml" id="titlepage"  href="content/{$titlepage-file}"/>
        <item media-type="application/xhtml+xml" id="article"    href="content/{$article-file}"/>
        <item media-type="application/xhtml+xml" id="colophon"   href="content/{$authorpage-file}"/>
-->        
        <xsl:for-each-group select="/*/body/div[@id='main']/div[@class='article']//img[normalize-space(@src)]"
          group-by="@src/replace(.,'^.*/','')" xpath-default-namespace="http://www.w3.org/1999/xhtml">
          <item/>
          <!--<xsl:variable name="suffix" select="replace(current-grouping-key(),'^.*\.','')"/>-->
<!--          <item media-type="{$image-types[lower-case(@suffix)=$suffix]/@mime-type}"
            id="img-{replace(current-grouping-key(),'\.[^\.]*$','')}" href="content/images/{current-grouping-key()}"/>
-->        </xsl:for-each-group>
        
        <!--<item media-type="image/png" id="Balisage-logo" href="content/images/BalisageSeries-Proceedings.png"/>-->
      </manifest>
      <spine toc="ncx">
        <itemref idref="titlepage"/>
        <!--<itemref idref="article"/>-->
        <!-- Top-level Toc? -->
        <itemref idref="colophon"/>
      </spine>
    </package>
  </xsl:template>
</xsl:stylesheet>