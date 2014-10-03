<!-- 
  Copyright 2001-2012 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
    xmlns:f="http://www.oxygenxml.com/xsl/functions"
    exclude-result-prefixes="xs f">
    
    <xsl:template match="/">
        <xsl:apply-templates mode="nestedLists"/>
    </xsl:template>
    
    <xsl:template match="xhtml:head" mode="nestedLists" priority="2"/>
    <xsl:template match="xhtml:span[contains(@style, 'mso-list:Ignore') 
                                 or contains(@style, 'mso-list: Ignore')]" 
                            mode="nestedLists" 
                            priority="2"/>
    
    <xsl:template match="*" mode="nestedLists" priority="1">
            <xsl:copy>
                <xsl:apply-templates select="@*" mode="nestedLists"/>
                <xsl:for-each-group 
                    select="* | text()[string-length(normalize-space()) > 0]" 
                    group-adjacent="if (self::xhtml:p[contains(@style, 'level') 
                                      or contains(@class, 'MsoList')]) then 1 else 0">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key() = 1">
                            <xsl:call-template name="createList">
                                <xsl:with-param name="list" 
                                    select="current-group()"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates 
                                select="current-group()" 
                                mode="nestedLists"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="node() | @*" mode="nestedLists">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="nestedLists"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="createList">
        <xsl:param name="list"/>
        <xsl:choose>
            <xsl:when test="boolean(f:isOrderedList($list[1]))">
                <e:ol xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:call-template name="nestedLists">
                        <xsl:with-param name="list" select="$list"/>
                    </xsl:call-template>
                </e:ol>
            </xsl:when>
            <xsl:otherwise>
                <e:ul xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:call-template name="nestedLists">
                        <xsl:with-param name="list" select="$list"/>
                    </xsl:call-template>
                </e:ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template name="nestedLists">
        <xsl:param name="list"/>
        <xsl:variable name="listIDAndLevelNumber" select="f:getListIdLevelNumber($list[1])"/>
        <!--
        <xsl:message>===== listID: [<xsl:value-of select="$listIDAndLevelNumber[1]"/>]</xsl:message>
        <xsl:message>===== levelNumber: [<xsl:value-of select="$listIDAndLevelNumber[2]"/>]</xsl:message>
        -->
        <xsl:for-each-group select="$list" 
                group-starting-with="xhtml:p[contains(@style, $listIDAndLevelNumber[1]) 
                                       and contains(@style, $listIDAndLevelNumber[2])]">
            <e:li xmlns="http://www.w3.org/1999/xhtml">
                <xsl:apply-templates 
                    select="current-group()[1]/node()" 
                    mode="nestedLists"/>
                <xsl:if test="count(current-group()) > 1">
                    <xsl:call-template name="createList">
                        <xsl:with-param name="list" 
                            select="current-group()[position() > 1]"/>
                    </xsl:call-template>
                </xsl:if>
            </e:li>
        </xsl:for-each-group>
    </xsl:template>
    
    
    <xsl:function name="f:getListIdLevelNumber" as="item()+">
        <xsl:param name="node" as="element()"/>
        <xsl:variable name="styleOfFirstPara" 
            select="$node/@style" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="empty($styleOfFirstPara)">
                <!-- 
                MS Word list items are marked in the clipboard XHTML 
                by only a class attribute, for example:
                    
                    class="MsoListBulletCxSpFirst"
                       or:
                   class="MsoListBulletCxSpMiddle"
                       or:
                   class="MsoListBulletCxSpLast"
                -->
                <xsl:sequence select="()"/>
            </xsl:when>
        </xsl:choose>
        <xsl:variable name="indexOfMsoList" 
            select="string-length(substring-before($styleOfFirstPara, 'mso-list:'))"/>
        <xsl:variable name="substringListID" 
            select="substring($styleOfFirstPara, $indexOfMsoList + 10)"/>
        <xsl:variable name="indexOfListID" 
            select="string-length(substring-before($substringListID, 'l'))"/>
        <xsl:variable name="listID" 
            select="substring($substringListID, $indexOfListID + 1, 2)"/>
        <xsl:variable name="indexOfLevelNumber" 
            select="string-length(substring-before($styleOfFirstPara, 'level'))"/>
        <xsl:variable name="levelNumber" 
            select="substring($styleOfFirstPara, $indexOfLevelNumber + 1, 6)"/>
        <xsl:sequence select="($listID, $levelNumber)"/>
    </xsl:function>
    
    
    <xsl:function name="f:isOrderedList" as="xs:boolean">
        <xsl:param name="node" as="element()"/>
        <!--
        Bullet marker of items of ordered lists ends with '.'  
        (for example 1. or a. or i.)  so the '.' character must be
        ignored. It is ordered list if the content of span with style attribute containing
        'mso-list:Ignore' is alphanumeric characters and the next item from the same list
        has a different marker (that is the next item from the same list has the marker 2.
        or b. or ii.). This condition is for avoiding the case of unordered list with marker
        'o' which is also alphanumeric but all list items have the same marker 'o'..
        -->
        <xsl:variable name="listItemBulletMarker" 
            select="$node/xhtml:span//xhtml:span[contains(@style, 'mso-list:Ignore') 
               or contains(@style, 'mso-list: Ignore')][1]/normalize-space(text())"/>
        <xsl:variable name="listIDAndLevelNumber" 
            select="f:getListIdLevelNumber($node)"/>
        <xsl:variable name="nextSiblingListItemBulletMarker"
            select="$node/following-sibling::xhtml:p[
                  contains(@style, $listIDAndLevelNumber[1]) 
              and contains(@style, $listIDAndLevelNumber[2])
                    ][1]/xhtml:span//xhtml:span[contains(@style, 'mso-list:Ignore')
                or contains(@style, 'mso-list: Ignore')][1]/normalize-space(text())"/>
        <!--
        <xsl:message>++++++++ listItemBulletMarker: [<xsl:value-of select="$listItemBulletMarker"/>]</xsl:message>
        <xsl:message>++++++++ nextSiblingListItemBulletMarker: [<xsl:value-of select="$nextSiblingListItemBulletMarker"/>]</xsl:message>
        -->
        
        <!-- 
                An ordered list is numbered, that is the list item marker starts with an alphanumeric
                character (1, 2, 3, etc or i, ii, iii, etc or a, b, c, etc) with the exception of an
                unordered list where the marker for all list items is 'o' 
        -->
        <xsl:value-of
            select="matches(substring($listItemBulletMarker, 1, 1), '[\c|\d]+') 
                  and 
                  (
                     string-length($nextSiblingListItemBulletMarker) > 0 
                     and matches(substring($nextSiblingListItemBulletMarker, 1, 1), '[\c|\d]+')
                     and ($listItemBulletMarker != $nextSiblingListItemBulletMarker)
                  )"/>
    </xsl:function>
</xsl:stylesheet>