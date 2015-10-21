<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.idpf.org/2007/opf"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="jatskit xs"
  version="2.0">
  
  <xsl:output indent="yes"/>
  
  <xsl:include href="../web/jatskit-util.xsl"/>
  
  <xsl:variable name="book" select="/jatskit:kit/book"/>
  
  <!-- Since the transformation source has been aggregated on the fly, we
       need to accept the source filename as a runtime parameter. -->
  
  <xsl:param name="source-filename" required="yes"/>
  
  <!--<xsl:variable name="relative-path" select="concat(replace($source-filename,'|',''),'JATSKit-opf.opf')"/>-->
  <xsl:variable name="relative-path" select="concat(jatskit:uri-basename($source-filename),'/JATSKit-opf.opf')"/>
  <xsl:variable name="target-URI" select="resolve-uri($relative-path,$source-filename)"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="$book" mode="opf-metadata"/>
  </xsl:template>
 
  <!--
    OPF package contains (EPUB3 spec):
    In this order: metadata [required], manifest [required], spine [required], guide [optional/deprecated], bindings [optional] -->
  <xsl:template match="book" mode="opf-metadata">
    <!-- For JATSKit, a process ID marks the result with a timestamp, which makes it likely to be
         unique among documents produced even from the same source file. For production use of this
         framework, a better identifier should be assigned. Depends on the EPUB. -->
    <package version="3.0" unique-identifier="jatskit-process-id">
      <xsl:attribute name="xml:base" select="$target-URI"/>
      <metadata>
        <!-- EPUB3: In any order: dc:identifier [1 or more], dc:title [1 or more], dc:language [1 or more],
             DCMES Optional Elements [0 or more], meta [1 or more], OPF2 meta [0 or more], link [0 or more] -->
        <dc:identifier id="jatskit-process-id">
          <xsl:value-of select="jatskit:uri-basename($source-filename)"/>
          <xsl:text>-jatskit-</xsl:text>
          <xsl:value-of select="format-dateTime(current-dateTime(),'[Y][M,2][D,2][H,2][m,2][s,2]')"/>
        </dc:identifier>
        <xsl:apply-templates select="book-meta/book-id" mode="#current"/>
        <!-- issn and isbn values given in book metadata, that identify other related resources e.g.
             published versions, should become dc:relation elements not dc:identifier elements.
             These can't be mapped in the general case, so they are left out here. -->
        <xsl:apply-templates select="book-meta/book-title-group/(book-title,subtitle)" mode="#current"/>
        <xsl:apply-templates select="book-meta/book-title-group/(trans-title-group,alt-title)" mode="#current"/>
        <dc:language>
          <xsl:value-of select="(@xml:lang,'en')[1]"/>
        </dc:language>
        <!--
        DCMES Optional Elements in namespace http://purl.org/dc/elements/1.1/:
          contributor | coverage | creator | date | description | format | publisher | relation | rights | source | subject | type
        -->
        
        <!-- Everyone in contrib-group is mapped to 'creator', even though not necessarily a 'creator' in the DC sense. -->
        <xsl:apply-templates mode="#current" select="book-meta/contrib-group/contrib"/>
        <!-- Only a date explicitly marked as 'published' produces a date, as per EPUB3 3.4.6 -->
        <xsl:apply-templates mode="#current" select="book-meta/pub-history/date[@date-type='published']"/>
        <!-- Publisher -->
        <xsl:apply-templates mode="#current" select="book-meta/publisher/publisher-name"/>
        <xsl:apply-templates mode="#current" select="book-meta[1]/permissions"/>
        
        
        
<!--        <xsl:apply-templates select="/html/body/h2[@class='article-title']" mode="opf-metadata"/>
        <xsl:apply-templates select="/html/body/div[@class='author']/h3[@class='author']" mode="opf-metadata"/>
        <dc:language>en-US</dc:language> 
        <xsl:apply-templates select="/html/body/div[@class='legalnotice-block']" mode="opf-metadata"/>
        <dc:publisher>Balisage Series on Markup Technologies</dc:publisher> 
        <dc:identifier id="article-doi">
          <xsl:text>doi:</xsl:text>
<!-\-          <xsl:value-of select="$doi"/>-\->
        </dc:identifier>
        
-->     
        <meta property="dcterms:modified">
          <xsl:value-of select="format-dateTime(current-dateTime(),'[Y]-[M,2]-[D,2]T[H,2]:[m,2]:[s,2]Z')"/>
        </meta>
      </metadata>
      <manifest>
        <!--<item media-type="application/x-dtbncx+xml" id="ncx" href="{jatskit:book-code(/)}-epub.ncx"/>-->
        
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
  
  <xsl:template mode="opf-metadata" match="book-id">
    <dc:identifier>
      <xsl:apply-templates select="@book-id-type" mode="#current"/>
      <xsl:apply-templates/>
    </dc:identifier>
  </xsl:template>

  <xsl:template mode="opf-metadata" match="book-id/@book-id-type">
    <!-- This will not generate valid results in sources where the values of @book-id-type are not unique. -->
    <xsl:attribute name="id" select="."/>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="book-title">
    <dc:title>
      <xsl:apply-templates/>
    </dc:title>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="subtitle">
    <xsl:variable name="local-id" select="concat('metadata-subtitle-',generate-id(.))"/>
    <dc:title id="{$local-id}" xml:lang="{jatskit:current-lang(.)}">
      <xsl:apply-templates/>
    </dc:title>
    <meta refines="#{$local-id}" property="title-type">subtitle</meta>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="trans-title-group">
    <xsl:apply-templates mode="#current" select="trans-title, trans-subtitle"/>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="trans-title">
    <xsl:variable name="local-id" select="concat('metadata-transtitle-',generate-id(.))"/>
    <dc:title id="{$local-id}" xml:lang="{jatskit:current-lang(.)}">
      <xsl:apply-templates/>
    </dc:title>
    <meta refines="#{$local-id}" property="title-type">translated title</meta>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="trans-subtitle">
    <xsl:variable name="local-id" select="concat('metadata-trans-subtitle-',generate-id(.))"/>
    <dc:title id="{$local-id}" xml:lang="{jatskit:current-lang(.)}">
      <xsl:apply-templates/>
    </dc:title>
    <meta refines="#{$local-id}" property="title-type">translated subtitle</meta>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="alt-title">
    <xsl:variable name="local-id" select="concat('metadata-alt-title-',generate-id(.))"/>
    <dc:title id="{$local-id}" xml:lang="{jatskit:current-lang(.)}">
      <xsl:apply-templates/>
    </dc:title>
    <meta refines="#{$local-id}" property="title-type">alternative title</meta>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="contrib-group/contrib">
    <dc:creator> 
      <xsl:apply-templates mode="#current" select="anonymous | collab | name | string-name"/>
    </dc:creator>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="contrib/anonymous">Anonymous</xsl:template>
  
  <xsl:template mode="opf-metadata" match="contrib/collab | contrib/string-name">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="contrib/name">
    <xsl:apply-templates mode="#current" select="given-names, surname"/>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="contrib/name[@name-style='eastern']" priority="2">
    <xsl:apply-templates mode="#current" select="surname, given-names"/>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="contrib/name/*">
    <xsl:if test="not(position() eq 1)">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="pub-history/date">
    <dc:date> 
      <xsl:value-of select="jatskit:iso-date(.)"/>
    </dc:date>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="publisher">
    <xsl:apply-templates mode="#current" select="publisher-name"/>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="publisher/publisher-name">
    <dc:publisher> 
      <xsl:apply-templates mode="#current"/>
      <xsl:for-each select="../publisher-place">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>)</xsl:text>
      </xsl:for-each>
    </dc:publisher>
  </xsl:template>
  
  <xsl:template mode="opf-metadata" match="permissions/copyright-statement | permissions/license">
    <dc:rights> 
      <xsl:apply-templates mode="#current"/>
    </dc:rights>
  </xsl:template>

  <xsl:template mode="opf-metadata" match="permissions/copyright-year"/>
  
  <xsl:template mode="opf-metadata" match="permissions/copyright-holder">
    <dc:rights>
      <xsl:text>Copyright © </xsl:text>
      <xsl:for-each select="../copyright-year">
        <xsl:value-of select="."/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
      <xsl:apply-templates mode="#current"/>
    </dc:rights>
  </xsl:template>
  
  
  
</xsl:stylesheet>