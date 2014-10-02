<!-- 
  Copyright 2001-2012 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet version="2.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
    xmlns:f="http://www.oxygenxml.com/xsl/functions"
    exclude-result-prefixes="xs f">
    
    <xsl:template match="/">
        <xsl:apply-templates mode="nestedSections"/>
    </xsl:template>
    
    <!-- Associates to a heading the lower rank headings after it. -->
    <xsl:key 
        name="kHeadings" 
        match="xhtml:body/*[f:isHeading(.)]"
        use="generate-id(preceding-sibling::*
                        [f:isHeading(.)][substring(name(current()),2) > substring(name(),2)][1])"/>
    
    <!-- Associates to a heading the elements after it.-->
    <xsl:key 
        name="kElements" 
        match="xhtml:body/node()[not(f:isHeading(.))]"
        use="generate-id(preceding-sibling::*[f:isHeading(.)][1])"/>
    
    <!-- Copy template for the not heading nodes. -->
    <xsl:template match="node()|@*" mode="nestedSections">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="nestedSections"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xhtml:html" mode="nestedSections">
        <xsl:copy>
            <xsl:apply-templates mode="nestedSections"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xhtml:body" mode="nestedSections">
        <xsl:copy>
            <!-- Takes all elements from the heading maps that do not have 
               a higher rank heading before them. -->
            <xsl:variable name="masterHeadings" select="key('kHeadings', '')"/>
            <xsl:choose>
                <xsl:when test="empty($masterHeadings)">
                    <xsl:apply-templates mode="nestedSections"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*[. &lt;&lt; $masterHeadings[1]]" mode="nestedSections"/>
                    <xsl:apply-templates select="$masterHeadings" mode="nestedSections"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xhtml:body/*[f:isHeading(.)]" mode="nestedSections">
        <e:section level="{substring(name(),2)}" xmlns="http://www.w3.org/1999/xhtml">
            <!-- Copies the header content. -->
            <e:title>
                <xsl:apply-templates mode="nestedSections"/>
            </e:title>
            <!-- Process all elements from its beginning to the next heading (lower or higher rank.)-->
            <xsl:apply-templates select="key('kElements', generate-id())" mode="nestedSections"/>
            <!-- Processes all the headings (lower rank only) recursively-->
            <xsl:apply-templates select="key('kHeadings', generate-id())" mode="nestedSections"/>
        </e:section>
    </xsl:template>
    
    <xsl:function name="f:isHeading" as="xs:boolean">
        <xsl:param name="n" as="node()"/>
        <xsl:value-of select="
                    local-name($n) = 'h1' or 
                    local-name($n) = 'h2' or 
                    local-name($n) = 'h3' or 
                    local-name($n) = 'h4' or 
                    local-name($n) = 'h5' or 
                    local-name($n) = 'h6'
            "/>
    </xsl:function>
</xsl:stylesheet>
