<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Copyright 2001-2012 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet version="2.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
                xmlns:f="http://www.oxygenxml.com/xsl/functions"
                exclude-result-prefixes="xsl e f">

    <xsl:template match="e:h1[ancestor::e:dl] 
                                      | e:h2[ancestor::e:dl] 
                                      | e:h3[ancestor::e:dl] 
                                      | e:h4[ancestor::e:dl] 
                                      | e:h5[ancestor::e:dl]
                                      | e:h6[ancestor::e:dl]">
    <bold>
       <xsl:apply-templates select="@* | node()"/>
    </bold>
  </xsl:template>
     
  <xsl:template match="e:p">
     <xsl:choose>
         <xsl:when test="((parent::e:td | parent::e:th) and (count(parent::*[1]/*) = 1)) or parent::e:p">
             <xsl:apply-templates select="@* | node()"/>
         </xsl:when>
         <xsl:when test="parent::e:ul | parent::e:ol">
             <!-- EXM-27834  Workaround for bug in OpenOffice/LibreOffice -->
             <list-item>
                 <p>
                     <xsl:call-template name="keepDirection"/>
                     <xsl:apply-templates select="@* | node()"/>
                 </p>
             </list-item>
         </xsl:when>
         <xsl:otherwise>
              <p>
                 <xsl:call-template name="keepDirection"/>
                 <xsl:apply-templates select="@* | node()"/>
              </p>
         </xsl:otherwise>
     </xsl:choose>
  </xsl:template>

  <xsl:template match="e:span[preceding-sibling::e:p and not(following-sibling::*)]">
     <p>
         <xsl:call-template name="keepDirection"/>
         <xsl:apply-templates select="@* | node()"/>
     </p>
  </xsl:template>
   
    <xsl:template match="e:pre">
        <xsl:choose>
            <xsl:when test="$context.path.last.name = 'preformat' or $context.path.last.name = 'code' or $context.path.last.name = 'disp-quote'">
                 <xsl:apply-templates select="@* | node()"/>
             </xsl:when>
             <xsl:otherwise>
                 <preformat>
                     <xsl:call-template name="keepDirection"/>
                     <xsl:apply-templates select="@* | node()"/>
                 </preformat>
             </xsl:otherwise>
         </xsl:choose>
     </xsl:template>
     
  <xsl:template match="e:code">
    <xsl:choose>
        <xsl:when test="$context.path.last.name = 'preformat' or $context.path.last.name = 'code' or $context.path.last.name = 'disp-quote'">
        <xsl:apply-templates select="@* | node()"/>
      </xsl:when>
      <xsl:otherwise>
        <code>
             <xsl:call-template name="keepDirection"/>
             <xsl:apply-templates select="@* | node()"/>
         </code>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="e:blockquote">
    <xsl:choose>
        <xsl:when test="$context.path.last.name = 'preformat' or $context.path.last.name = 'code' or $context.path.last.name = 'disp-quote'">
          <xsl:apply-templates select="@* | node()"/>
      </xsl:when>
      <xsl:otherwise>
          <disp-quote>
           <xsl:call-template name="keepDirection"/>
           <xsl:apply-templates select="@* | node()"/>
        </disp-quote>
      </xsl:otherwise>
    </xsl:choose>
   </xsl:template>
   
  
     <!-- Hyperlinks -->
  <xsl:template match="e:a[contains(@href, ':')]"
                          priority="1.5">
      <!-- Links of type: http:// ..., ftp://..., mailto: ... -->
      <xsl:variable name="ulink">
          <ext-link xmlns:xlink="http://www.w3.org/1999/xlink">
             <xsl:attribute name="xlink:href">
                 <xsl:value-of select="normalize-space(@href)"/>
             </xsl:attribute>
             <xsl:call-template name="keepDirection"/>
             <xsl:apply-templates select="@* | * | text()"/>
         </ext-link>
      </xsl:variable>
      <xsl:call-template name="insertParaInSection">
          <xsl:with-param name="childOfPara" select="$ulink"/>
      </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="e:a[contains(@href,'#')]" priority="0.6">
      <xsl:variable name="xref">
          <xref xmlns:xlink="http://www.w3.org/1999/xlink">
               <xsl:attribute name="xlink:href">
                   <xsl:value-of select="normalize-space(@href)"/>
               </xsl:attribute>
               <xsl:call-template name="keepDirection"/>
               <xsl:apply-templates select="@* | * | text()"/>
           </xref>
          <xsl:apply-templates select="* | text()"/>
      </xsl:variable>
      <xsl:call-template name="insertParaInSection">
          <xsl:with-param name="childOfPara" select="$xref"/>
      </xsl:call-template>
  </xsl:template>
    
    
    <xsl:template match="e:a[@name != '']" priority="0.6">
        <xref xmlns:xlink="http://www.w3.org/1999/xlink">
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="normalize-space(@href)"/>
            </xsl:attribute>
            <xsl:call-template name="keepDirection"/>
            <xsl:apply-templates select="@* | * | text()"/>
        </xref>
        <xsl:apply-templates select="* | text()"/>
    </xsl:template>
  
    <xsl:template match="e:a[@href != '']">
        <xsl:variable name="xref">
            <xref xmlns:xlink="http://www.w3.org/1999/xlink">
                <xsl:attribute name="xlink:href">
                    <xsl:value-of select="normalize-space(@href)"/>
                </xsl:attribute>
                <xsl:call-template name="keepDirection"/>
                <xsl:apply-templates select="@* | * | text()"/>
            </xref>
        </xsl:variable>
        <xsl:call-template name="insertParaInSection">
            <xsl:with-param name="childOfPara" select="$xref"/>
        </xsl:call-template>
    </xsl:template>
  
  <xsl:template name="string.subst">
   <xsl:param name="string" select="''"/>
   <xsl:param name="substitute" select="''"/>
   <xsl:param name="with" select="''"/>
   <xsl:choose>
    <xsl:when test="contains($string,$substitute)">
     <xsl:variable name="pre" select="substring-before($string,$substitute)"/>
     <xsl:variable name="post" select="substring-after($string,$substitute)"/>
     <xsl:call-template name="string.subst">
      <xsl:with-param name="string" select="concat($pre,$with,$post)"/>
      <xsl:with-param name="substitute" select="$substitute"/>
      <xsl:with-param name="with" select="$with"/>
     </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="$string"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
  
  <!-- Images -->
  <xsl:template match="e:img">
    <xsl:variable name="pastedImageURL" 
      xmlns:URL="java:java.net.URL"
      xmlns:URLUtil="java:ro.sync.util.URLUtil"
      xmlns:UUID="java:java.util.UUID">
      <xsl:choose>
        <xsl:when test="namespace-uri-for-prefix('o', .) = 'urn:schemas-microsoft-com:office:office'">
          <!-- Copy from MS Office. Copy the image from user temp folder to folder of XML document
            that is the paste target. -->
          <xsl:variable name="imageFilename">
            <xsl:variable name="fullPath" select="URL:getPath(URL:new(translate(@src, '\', '/')))"/>
            <xsl:variable name="srcFile">
              <xsl:choose>
                <xsl:when test="contains($fullPath, ':')">
                  <xsl:value-of select="substring($fullPath, 2)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$fullPath"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="getFilename">
              <xsl:with-param name="path" select="string($srcFile)"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="stringImageFilename" select="string($imageFilename)"/>
          <xsl:variable name="uid" select="UUID:hashCode(UUID:randomUUID())"/>
          <xsl:variable name="uniqueTargetFilename" select="concat(substring-before($stringImageFilename, '.'), '_', $uid, '.', substring-after($stringImageFilename, '.'))"/>
          <xsl:variable name="sourceURL" select="URL:new(translate(@src, '\', '/'))"/>
          <xsl:variable name="correctedSourceFile">
            <xsl:choose>
              <xsl:when test="contains(URL:getPath($sourceURL), ':')">
                <xsl:value-of select="substring-after(URL:getPath($sourceURL), '/')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="URL:getPath($sourceURL)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="sourceFile" select="URLUtil:uncorrect($correctedSourceFile)"/>
          <xsl:variable name="targetURL" select="URL:new(concat($folderOfPasteTargetXml, '/', $uniqueTargetFilename))"/>
          <xsl:value-of select="substring-after(string($targetURL),
                substring-before(string(URLUtil:copyURL($sourceURL, $targetURL)), $uniqueTargetFilename))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@src"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="tagName">
        <xsl:choose>
             <xsl:when test="boolean(parent::e:p) and 
                                        boolean(normalize-space(string-join(parent::e:p/text(), ' ')))">
                <xsl:text>inline-graphic</xsl:text>
             </xsl:when>
             <xsl:otherwise>graphic</xsl:otherwise>
        </xsl:choose>
   </xsl:variable>
   <xsl:element name="{$tagName}">
       <xsl:attribute name="xlink:href"  xmlns:xlink="http://www.w3.org/1999/xlink" select="$pastedImageURL"/>
      <!--  
          TODO, does a JATS graphic have image height and width attributes?
          <xsl:if test="@height != ''">
          <xsl:attribute name="depth">
            <xsl:value-of select="@height"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="@width != ''">
          <xsl:attribute name="width">
            <xsl:value-of select="@width"/>
          </xsl:attribute>
        </xsl:if>-->
   </xsl:element>
  </xsl:template>
  
  <xsl:template name="getFilename">
   <xsl:param name="path"/>
   <xsl:choose>
    <xsl:when test="contains($path,'/')">
     <xsl:call-template name="getFilename">
      <xsl:with-param name="path" select="substring-after($path,'/')"/>
     </xsl:call-template>
    </xsl:when>
     <xsl:when test="contains($path,'\')">
       <xsl:call-template name="getFilename">
         <xsl:with-param name="path" select="substring-after($path,'\')"/>
       </xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
         <xsl:choose>
             <xsl:when test="starts-with($path, '#')">
                 <xsl:value-of select="substring-after($path, '#')"/>
             </xsl:when>
             <xsl:otherwise>
                 <xsl:value-of select="$path"/>
             </xsl:otherwise>
         </xsl:choose>
     </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
  
  <!-- List elements -->
  <xsl:template match="e:ul">
      <list list-type="bullet">
        <xsl:apply-templates select="@* | node()"/>
    </list>
  </xsl:template>
  
  <xsl:template match="e:ol">
      <list list-type="order">
        <xsl:apply-templates select="@* | node()"/>
    </list>
  </xsl:template>
  
  
<!-- TODO Radu C, which are the JATS equivalent of "kbd" and "samp" XHTML element?
        
        
        <xsl:template match="e:kbd">
    <userinput xmlns="http://docbook.org/ns/docbook">
       <xsl:call-template name="keepDirection"/>
       <xsl:apply-templates select="@* | node()"/>
    </userinput>
  </xsl:template>
  
  <xsl:template match="e:samp">
    <screen xmlns="http://docbook.org/ns/docbook">
       <xsl:call-template name="keepDirection"/>
       <xsl:apply-templates select="@* | node()"/>
    </screen>
  </xsl:template>-->
  
  <xsl:template match="e:blockquote">
      <disp-quote>
       <xsl:call-template name="keepDirection"/>
       <xsl:apply-templates select="@* | node()"/>
    </disp-quote>
  </xsl:template>
  
  <xsl:template match="e:q">
      <disp-quote>
       <xsl:call-template name="keepDirection"/>
       <xsl:apply-templates select="@* | node()"/>
    </disp-quote>
  </xsl:template>
  
  <xsl:template match="e:dl">
      <def-list>
    	<xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="."/>
    </def-list>
  </xsl:template>
  
  <xsl:template match="e:dt">
    <term>
       <xsl:call-template name="keepDirection"/>
       <xsl:apply-templates select="@* | node()"/>
    </term>
  </xsl:template>
  
  <xsl:template match="e:dd">
      <def>
          <xsl:call-template name="keepDirection"/>
          <xsl:apply-templates select="node()" mode="preprocess"/>
      </def>
  </xsl:template>
  
  <xsl:template match="e:li">
      <xsl:choose>
          <xsl:when test="parent::e:ul | parent::e:ol">
              <list-item>
                    <xsl:call-template name="keepDirection"/>
                    <xsl:apply-templates/>
               </list-item>
          </xsl:when>
          <xsl:otherwise>
              <p>
                  <xsl:call-template name="keepDirection"/>
                  <xsl:apply-templates/>
              </p>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
          
  <xsl:template match="@id"> 
    <xsl:attribute name="id">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@dir">
      
<!--  Radu C:
          No direction attribute in JATS AFAK
          <xsl:attribute name="dir">
          <xsl:value-of select="lower-case(.)"/>
      </xsl:attribute>
-->  </xsl:template>
    
  <xsl:template match="@class[parent::e:table] 
                                | @title[parent::e:table]
                                | @style[parent::e:table]
                                | @width[parent::e:table]
                                | @border[parent::e:table]"> 
    <xsl:attribute name="{local-name()}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="@*">
   <!--<xsl:message>No template for attribute <xsl:value-of select="name()"/></xsl:message>-->
  </xsl:template>
  
  
  <!-- Inline formatting -->
  <xsl:template match="e:b | e:strong">
      <xsl:variable name="emphasis">
          <bold>
              <xsl:apply-templates select="@* | node()"/>
          </bold>
      </xsl:variable>
      <xsl:if test="string-length(normalize-space($emphasis)) > 0">
          <xsl:call-template name="insertParaInSection">
              <xsl:with-param name="childOfPara" select="$emphasis"/>
          </xsl:call-template>
      </xsl:if>
  </xsl:template>
  
  <xsl:template match="e:i | e:em">
      <xsl:variable name="emphasis">
          <italic>
              <xsl:apply-templates select="@* | node()"/>
          </italic>
      </xsl:variable>
      <xsl:if test="string-length(normalize-space($emphasis)) > 0">
          <xsl:call-template name="insertParaInSection">
              <xsl:with-param name="childOfPara" select="$emphasis"/>
          </xsl:call-template>
      </xsl:if>
  </xsl:template>

  <xsl:template match="e:u">
      <xsl:variable name="emphasis">
          <underline>
              <xsl:apply-templates select="@* | node()"/>
          </underline>
      </xsl:variable>
      <xsl:if test="string-length(normalize-space($emphasis)) > 0">
          <xsl:call-template name="insertParaInSection">
              <xsl:with-param name="childOfPara" select="$emphasis"/>
          </xsl:call-template>
      </xsl:if>
  </xsl:template>
          
  <!-- Ignored elements -->
  <xsl:template match="e:hr"/>
  <xsl:template match="e:meta"/>
  <xsl:template match="e:style"/>
  <xsl:template match="e:script"/>
  <xsl:template match="e:p[normalize-space() = '' and count(*) = 0]" priority="0.6"/>
  <xsl:template match="text()">
   <xsl:choose>
    <xsl:when test="normalize-space() = ''"><xsl:text> </xsl:text></xsl:when>
    <xsl:otherwise>
        <xsl:choose>
            <xsl:when test="(parent::e:section or parent::e:span/parent::e:section)
                              and not(parent::e:i or parent::e:em or
                              parent::e:b or parent::e:strong or parent::e:u)
                              or parent::e:li[parent::e:ul or parent::e:ol]">
                <p><xsl:value-of select="translate(., '&#xA0;', ' ')"/></p>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="translate(., '&#xA0;', ' ')"/></xsl:otherwise>
        </xsl:choose>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
  
  
    <xsl:template match="e:section">
        <sec>
            <title>
                <xsl:apply-templates select="e:title"/>
            </title>
            <xsl:apply-templates 
                select="node()[local-name() != 'title' and local-name() != 'sec']"/>
            <xsl:apply-templates select="e:section"/>
        </sec>
    </xsl:template>
    
    
    <xsl:template name="insertParaInSection">
        <xsl:param name="childOfPara"/>
        <xsl:choose>
            <xsl:when test="parent::e:section">
                <p><xsl:copy-of select="$childOfPara"/></p>
            </xsl:when>
            <xsl:otherwise><xsl:copy-of select="$childOfPara"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="keepDirection">
        <xsl:choose>
            <xsl:when test="@dir">
                <xsl:attribute name="dir">
                    <xsl:value-of select="lower-case(@dir)"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="@DIR">
                <xsl:attribute name="dir">
                    <xsl:value-of select="lower-case(@DIR)"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="count(e:span[@dir]|e:span[@DIR]) = 1">
                <xsl:attribute name="dir">
                    <xsl:value-of select="lower-case((e:span/@dir|e:span/@DIR)[1])"/>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>