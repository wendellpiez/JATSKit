<!-- 
  Copyright 2001-2012 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
    xmlns:f="http://www.oxygenxml.com/xsl/functions"
    exclude-result-prefixes="xs e f">
    
    <xsl:template match="/">
        <xsl:apply-templates mode="wrapGlobalText"/>
    </xsl:template>
    
    
    <xsl:template match="node() | @*" mode="wrapGlobalText">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="wrapGlobalText"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- Wrap in a <p> element an entire sequence of text nodes + elements like <a>, <b>, <i>, <u>  -->
  <xsl:template match="xhtml:body" mode="wrapGlobalText">
    <xsl:copy>
      <xsl:for-each-group select="node()"
             group-starting-with="node() 
               [(f:shouldWrapInParagraph(.) cast as xs:boolean)
                and (not(exists(preceding-sibling::node()[1])) 
                     or not((f:shouldWrapInParagraph(preceding-sibling::node()[1]) cast as xs:boolean)))
               ]
         | node() 
               [not(f:shouldWrapInParagraph(.) cast as xs:boolean)
           and ((not(exists(preceding-sibling::node()[1]))
                or (f:shouldWrapInParagraph(preceding-sibling::node()[1]) cast as xs:boolean)))
               ]">
          <xsl:choose>
            <xsl:when test="f:shouldWrapInParagraph(.) cast as xs:boolean">
              <xhtml:p>
                <xsl:copy-of select="current-group()"/>
              </xhtml:p>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="current-group()"/>
            </xsl:otherwise>
          </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
    
    
    <xsl:function name="f:shouldWrapInParagraph" as="item()">
        <xsl:param name="currentNode" as="node()"/>
        <xsl:value-of 
            select="boolean(
                ($currentNode[self::text()][string-length(normalize-space()) > 0]
                or $currentNode[local-name() = 'a'
                or local-name() = 'i' or local-name() = 'em'
                or local-name() = 'b' or local-name() = 'strong'
                or local-name() = 'u'])
            and empty(index-of($context.path.names.sequence, 'p'))
            and empty(index-of($context.path.names.sequence, 'para'))
            and empty(index-of($context.path.names.sequence, 'title'))
            and empty(index-of($context.path.names.sequence, 'codeblock'))
            and empty(index-of($context.path.names.sequence, 'code'))
            and empty(index-of($context.path.names.sequence, 'lq'))
            and empty(index-of($context.path.names.sequence, 'blockquote'))
            and empty(index-of($context.path.names.sequence, 'programlisting'))
            and empty(index-of($context.path.names.sequence, 'programlistingco'))
            and empty(index-of($context.path.names.sequence, 'quote'))
            and empty(index-of($context.path.names.sequence, 'q'))
            and empty(index-of($context.path.names.sequence, 'li'))
            and empty(index-of($context.path.names.sequence, 'listitem'))
            and empty(index-of($context.path.names.sequence, 'item'))
            and empty(index-of($context.path.names.sequence, 'table'))
            and empty(index-of($context.path.names.sequence, 'informaltable')))"/>
    </xsl:function>

</xsl:stylesheet>