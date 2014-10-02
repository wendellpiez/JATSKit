<!-- 
  Copyright 2001-2012 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:f="http://www.oxygenxml.com/xsl/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    exclude-result-prefixes="f xs">

    
    <xsl:template match="/" mode="breakLines">
        <xsl:variable name="removeSpans">
            <xsl:apply-templates select="." mode="removeSpans"/>
        </xsl:variable>
        <xsl:apply-templates select="$removeSpans/*" mode="breakLines"/>
    </xsl:template>

    <xsl:template match="node() | @*" mode="removeSpans">
        <xsl:copy>
            <xsl:variable name="childDirAttributes" 
                select="for $e in xhtml:span return ($e/@DIR|$e/@dir)"/>
            <xsl:if test="not(@DIR) and not(@dir) 
                     and count($childDirAttributes) = 1 
                     and count(xhtml:span) = 1">
                <xsl:attribute name="dir" select="$childDirAttributes"/>
            </xsl:if>
            <xsl:apply-templates select="node() | @*" mode="removeSpans"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xhtml:span[f:ignorableElement(.)]" 
                  mode="removeSpans">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="removeSpans"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xhtml:span" mode="removeSpans">
        <xsl:apply-templates mode="removeSpans"/>
    </xsl:template>
    
    <xsl:function name="f:ignorableElement" as="xs:boolean">
        <xsl:param name="element" as="node()"/>
        <xsl:value-of select="exists(
              $element/self::xhtml:span[contains(string-join(descendant-or-self::*/@style, ' '), 'mso-list:Ignore')]
            | $element/self::xhtml:span[contains(string-join(descendant-or-self::*/@style, ' '), 'mso-list: Ignore')]
            | $element/self::xhtml:span[contains(string-join(ancestor-or-self::*/@style, ' '), 'mso-list:Ignore')]
            | $element/self::xhtml:span[contains(string-join(ancestor-or-self::*/@style, ' '), 'mso-list: Ignore')]
            )"></xsl:value-of>
    </xsl:function>
    
    <xsl:template match="node() | @*" mode="breakLines">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="breakLines"/>
        </xsl:copy>
    </xsl:template>

    <!-- Replace <br/> element with a space. -->
    <xsl:template match="xhtml:br[parent::xhtml:code | parent::xhtml:pre | parent::xhtml:blockquote]" 
                  mode="breakLines">
        <xsl:text>&#xA;</xsl:text>
    </xsl:template>
    
    <xsl:template match="xhtml:li[xhtml:br]" mode="breakLines">
        <xhtml:li>
            <xsl:call-template name="brContent"/>
        </xhtml:li>
    </xsl:template>
    
    <!-- 
        Split a sequence of nodes that contains at least one <br/> element
        in adjacent sequences separated by <br/>, filter the <br/> and wrap
        each sequence as a para.
    -->
    <xsl:template match="xhtml:div[descendant::xhtml:br] 
                       | xhtml:p[descendant::xhtml:br]" 
                  mode="breakLines">
        <xsl:call-template name="brContent"/>
    </xsl:template>
    
    <xsl:template name="brContent">
        <!--<xsl:param name="content" as="node()*"/>-->
        <xsl:variable name="preceding-text">
            <xsl:apply-templates 
                select="node()[not(preceding-sibling::xhtml:br)]
                              [local-name() != 'br']" 
                mode="breakLines"/>
        </xsl:variable>
        <xsl:if test="string-length(normalize-space($preceding-text)) > 0">
            <xhtml:p><xsl:copy-of select="$preceding-text"/></xhtml:p>
        </xsl:if>
        <xsl:for-each select="xhtml:br">
            <xsl:variable name="following-text">
                <xsl:apply-templates 
                    select="parent::*[1]/node()
                             [current() is preceding-sibling::xhtml:br[1]]
                             [local-name() != 'br']" 
                    mode="breakLines"/>
            </xsl:variable>
            <xsl:if test="string-length(normalize-space($following-text)) > 0">
                <xhtml:p><xsl:copy-of select="$following-text"/></xhtml:p>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
