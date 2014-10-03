<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:o="urn:schemas-microsoft-com:office:office"
    xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements">

    <xsl:template match="/">
        <xsl:apply-templates mode="setNamespace"/>
    </xsl:template>
    
    <xsl:template match="@*" mode="setNamespace">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="xhtml:*" mode="setNamespace">
        <xsl:element name="{local-name()}" namespace="http://www.oxygenxml.com/xsl/conversion-elements">
            <xsl:if test="namespace-uri-for-prefix('o', .) = 'urn:schemas-microsoft-com:office:office'">
                <xsl:namespace name="o" select="'urn:schemas-microsoft-com:office:office'"/>
            </xsl:if>
            <xsl:apply-templates select="node() | @*" mode="setNamespace"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Image elements that come from MS Word namespace (o:*) must keep the namespaces. 
        Needed in next stylesheet in pipeline, that handles image element. -->
    <xsl:template match="o:* | e:*" mode="setNamespace">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="setNamespace"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xhtml:span[ancestor::xhtml:p | ancestor::xhtml:div]
                                   [not(contains(@style, 'mso-list:'))]" 
                  mode="setNamespace">
        <xsl:apply-templates mode="setNamespace"/>
    </xsl:template>
    
    <xsl:template match="xhtml:head" mode="setNamespace"/>
</xsl:stylesheet>