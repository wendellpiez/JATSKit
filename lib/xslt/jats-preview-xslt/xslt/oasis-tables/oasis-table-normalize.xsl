<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:p="http://www.wendellpiez.com/oasis-tables/util"
  xpath-default-namespace="http://www.niso.org/standards/z39-96/ns/oasis-exchange/table"
  exclude-result-prefixes="#all">

  <!-- OASIS table normalization:
   1. Assigns @p:across and @p:down values to table cells (entry elements);
   2. Generates ghost cells where cells are expected but not given;
   3. Assigns @p:full-width to tgroup whose colspec/@colwidth all have values in star notation
   -->

  <!-- Emit debugging messages? -->
  <xsl:param name="p:debug" select="false()"/>
  
  <xsl:key name="colspec-by-name" match="colspec" use="@colname"/>

  <!-- $default-border-style sets the style of borders only when set to appear -->
  <xsl:param name="default-border-style">solid</xsl:param>
  
  <xsl:template name="p:assign-gen-id">
    <xsl:attribute name="p:gen-id" select="generate-id()"/>
  </xsl:template>
  
  <xsl:template mode="p:normalize-table" match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="p:assign-gen-id"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="p:normalize-table" match="@*">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template mode="p:normalize-table" match="entry//*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="p:normalize-table" match="tgroup">
    <xsl:copy>
      <xsl:call-template name="p:assign-gen-id"/>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="#current" select="colspec"/>
      <!-- OASIS 1999 tables contain only thead?, tbody, but earlier
           models have tfoot, and not always last.
           This logic supports one each of thead, tfoot and tbody in any order;
           the output always comes thead, tbody, tfoot.
         (A calling stylesheet may rearrange them.) -->
      <xsl:for-each select="thead">
        <xsl:copy>
          <xsl:call-template name="p:assign-gen-id"/>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="#current" select="row[1]">
            <xsl:with-param name="rowno" select="1"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:for-each>
      <xsl:for-each select="tfoot">
        <xsl:copy>
          <xsl:call-template name="p:assign-gen-id"/>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="#current" select="row[1]">
            <xsl:with-param name="rowno" select="count(../(thead|tbody)/row) + 1"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:for-each>
      <xsl:for-each select="tbody">
        <xsl:copy>
          <xsl:call-template name="p:assign-gen-id"/>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="#current" select="row[1]">
            <xsl:with-param name="rowno" select="count(../thead/row) + 1"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:for-each>
      
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="p:normalize-table" match="row">
    <!-- Sibling recursion through the rows carries forward any cells with @morerows
         (as long as they stick within their tgroup|tfront|tbody)
         "remembering" them for purposes of placing cells around them. -->
    <xsl:param name="rowno" required="yes" as="xs:integer"/>
    <xsl:param name="carried-entries" as="element(entry)*" select="()"/>
    
    <!-- $entries-here contains the results of processing this row's entries. -->
    <xsl:variable name="entries-here" as="element(entry)*">
      <xsl:apply-templates mode="#current" select="entry[1]">
        <xsl:with-param name="rowno" select="$rowno" tunnel="yes"/>
        <!-- Note that $carried-entries does not tunnel through the rows, but it
             does through the cells in the row. -->
        <xsl:with-param name="carried-entries" select="$carried-entries" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <!-- We emit the new row. -->
    <xsl:copy>
      <xsl:call-template name="p:assign-gen-id"/>
      <xsl:apply-templates mode="#current" select="@*"/>
      <xsl:attribute name="p:rowno" select="$rowno"/>
      <xsl:sequence select="$entries-here"/>
    </xsl:copy>
    
    <xsl:if test="$p:debug">
      <!-- For confirming we are catching down values (row positions) correctly
           in the new entries. -->
      <xsl:message>
        <xsl:text>Row </xsl:text>
        <xsl:value-of select="$rowno"/>
        <xsl:text>, $entries-here/p:values(@p:down): </xsl:text>
        <xsl:for-each select="$entries-here">
          <xsl:if test="position() gt 1"> | </xsl:if>
          <xsl:value-of select="p:values(@p:down)" separator=","/>
        </xsl:for-each>
      </xsl:message>
    </xsl:if>
    
    <!-- Now we process the next sibling, incrementing rowno and carrying
         any cells inside $entries-here that are marked to span rows to come. -->
    <xsl:apply-templates mode="#current" select="following-sibling::row[1]">
      <xsl:with-param name="rowno" select="$rowno + 1"/>
      <!-- Carry forward entries from earlier rows and from this one whose
           @p:down values (rows) are not all done yet. -->
      <xsl:with-param name="carried-entries"
        select="($carried-entries | $entries-here)[p:values(@p:down) > $rowno]"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="p:normalize-table" match="entry">
    <!-- Moving across the row, one entry at a time. -->
    <xsl:param name="pos" select="1"/>
    <xsl:param name="rowno" required="yes" as="xs:integer" tunnel="yes"/>
    <!-- $carried-entries contains cells from earlier rows that span into this one. -->      
    <xsl:param name="carried-entries" select="()" as="element(entry)*" tunnel="yes"/>
    <xsl:variable name="here" select="."/>
    
    <xsl:if test="$p:debug">
      <!-- Report which cell we are processing, with the number of entries
           carried from earlier rows. -->
      <xsl:message>
        <xsl:text>In row </xsl:text>
        <xsl:value-of select="$rowno"/>
        <xsl:text>, processing cell $pos='</xsl:text>
        <xsl:value-of select="$pos"/>
        <xsl:text>' with </xsl:text>
        <xsl:value-of select="count($carried-entries)"/>
        <xsl:text> carried entr</xsl:text>
        <xsl:sequence select="if (count($carried-entries) eq 1) then 'y' else 'ies'"/>
      </xsl:message>
    </xsl:if>
    
    <xsl:variable name="t" select="ancestor::tgroup[1]"/>
    <xsl:variable name="start-colspec" select="(@namest,@colname)[1]/key('colspec-by-name',.,$t)[1]"/>
    <xsl:variable name="end-colspec" select="@nameend/key('colspec-by-name',.,$t)[1]"/>
    <!-- $assigned-position is the column number explicitly assigned (or an empty sequence). -->
    <xsl:variable name="assigned-position" select="$start-colspec/p:colno(.)"/>
    <!-- $inferred-position is the position we take after any carried entries. -->
    <xsl:variable name="inferred-position" select="p:first-available($pos,$carried-entries/p:values(@p:across))"/>
    <!-- $given-position is the best available of the positions assigned or inferred. -->
    <!-- Note an error condition will result for a cell assigned to a position (using @namest or @colname) 
         that is already taken (by virtue of spanned rows or columns elsewhere), since its @p:across
         value takes its assigned position on faith. This can (should) be trapped downstream. -->
    <xsl:variable name="given-position" select="($assigned-position,$inferred-position)[1]"/>
    
    <!-- We first generate ghost entries to fill spots behind us. -->
    <xsl:if test="$given-position &gt; $inferred-position">
      <xsl:for-each select="$inferred-position to ($assigned-position - 1)">
        <!-- Making a ghost entry for any spot not occupied by $carried-entries. -->
        <xsl:if test="not(. = $carried-entries/@p:across/p:values(.))">
          <entry p:down="{$rowno}" p:across="{.}" xmlns="http://www.niso.org/standards/z39-96/ns/oasis-exchange/table">
            <xsl:copy-of select="$here/(@colsep|@rowsep)"/>
          </entry>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
    
    <!-- Now we are in position, we copy the entry. -->
    <xsl:copy>
      <xsl:call-template name="p:assign-gen-id"/>
      <xsl:apply-templates mode="#current" select="@*"/>
      <!-- p:down values account for $rowno and @morerows -->
      <xsl:attribute name="p:down"
        select="$rowno to xs:integer($rowno + (@morerows[. castable as xs:integer],0)[1])"/>
      
      <!-- p:across values start from the given position; they end with the position of the 
           column given by @nameend, or the given position. -->
      <xsl:attribute name="p:across" select="($given-position)[1] to ($end-colspec/p:colno(.),$given-position)[1]"/>
      
      <xsl:if test="$p:debug and exists($carried-entries)">
        <xsl:message>
          <xsl:for-each select="$carried-entries">
            <xsl:if test="position() gt 1">&#xA;</xsl:if>
            <xsl:text>Carried entry across(</xsl:text>
            <xsl:value-of select="@p:across"/>
            <xsl:text>)/down(</xsl:text>
            <xsl:value-of select="@p:down"/>
            <xsl:text>)</xsl:text>
          </xsl:for-each>
        </xsl:message>
      </xsl:if>
      
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
    
    <!-- Next we do the next entry in its position. -->
    <xsl:apply-templates mode="#current" select="following-sibling::entry[1]">
      <!-- Parameters $rowno and $carried-entries are tunneled. -->
      <xsl:with-param name="pos" select="($end-colspec/p:colno(.),$given-position)[1] + 1"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:function name="p:colno" as="xs:integer"><!-- saxon:memo-function="yes" -->
    <!-- Returns a column number for a column. -->
    <xsl:param name="col" as="element(colspec)"/>
    <!-- We have to account for possible error conditions, falling back
         gracefully if colspecs are assigned explicit numbers -->
    <!-- Note that this means if the data is bad, more than one colspec
         can get the same number. -->
    <!-- The best way of avoiding this is to validate the input: either
         all colspecs are given with correct colnums, or none are. -->
    <xsl:variable name="actual-colno" select="count($col|$col/preceding-sibling::colspec)"/>
    <xsl:choose>
      <xsl:when test="exists($col/@colnum[. castable as xs:integer][number(.) gt 0])">
        <!-- If a colno is given as a natural number, we use it. -->
        <xsl:sequence select="xs:integer($col/@colnum)"/>
      </xsl:when>
      <!-- If a preceding colspec is assigned a number, we count from it. -->
      <xsl:when test="exists($col/preceding-sibling::*/@colnum[. castable as xs:integer][number(.) gt 0])">
        <xsl:variable name="numbered-sibling"
          select="$col/preceding-sibling::*[exists(@colnum[. castable as xs:integer][number(.) gt 0])][1]"/>
        <!-- The number is the preceding colspec's number, plus the number of colspecs between. -->
        <xsl:sequence select="xs:integer($numbered-sibling/@colnum +
          ($actual-colno - count($numbered-sibling/(.|preceding-sibling::*))))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$actual-colno"/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:function>
  
  <xsl:function name="p:values" as="xs:integer*">
    <!-- Given an attribute containing a space-delimited run of numerals,
         returns its tokenized values as a sequence of integers.
         (Used to derive values of p:across and p:down attributes.) -->
    <xsl:param name="v" as="attribute()"/>
    <xsl:if test="matches($v,'^\s*(\d+\s+)*\d+\s*$')">
      <xsl:for-each select="tokenize($v,'\s+')">
        <xsl:sequence select="xs:integer(.)"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:function>
  
  <xsl:function name="p:first-available" as="xs:integer">
    <!-- Given an integer $i and a sequence of integers $s, returns
         the first integer at or after $i that does not appear in $s. -->
    <xsl:param name="i" as="xs:integer"/>
    <xsl:param name="s" as="xs:integer*"/>
    <xsl:sequence select="if ($i = $s) then p:first-available($i + 1,$s) else $i"/>
  </xsl:function>
  
  <xsl:function name="p:star-value" as="xs:double?">
    <!-- if string input is in "star" notation, returns its value as
         a double; the value "*" is read as "1*" -->
    <xsl:param name="colspec" as="element(colspec)"/>
    <xsl:for-each select="$colspec">
      <!-- per OASIS spec 3.3.2.3 -->
      <xsl:if test="empty(@colwidth) or
        matches(normalize-space(@colwidth),'^(\d+(\.\d+)?\s*\*|\*?)$')">
        <xsl:choose>
          <!-- Absent @colwidth or @colwidth='' or @colwidth='*' all become @colwidth='1*' -->
          <xsl:when test="not(normalize-space(@colwidth)) or
            normalize-space(@colwidth)='*'">
            <xsl:sequence select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence
              select="xs:double(replace(@colwidth,'[\s\*]','')[. castable as xs:double])"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>
  
  <xsl:function name="p:relative-percentage" as="xs:string">
    <!-- returns percentage value for colspec using * notation among its siblings
         using * notation
         colspec with no @colwidth are assumed to have @colwidth='1*' -->
    <xsl:param name="colspec" as="element(colspec)"/>
    <xsl:param name="family" as="element(colspec)+"/>
    <xsl:variable name="this-value"
      select="p:star-value($colspec)"/>
    <xsl:variable name="total" select="sum($family/p:star-value(.))"/>
    <xsl:variable name="proportion" select="round(($this-value div $total) * 10000) div 100"/>
    <xsl:sequence select="concat(string($proportion),'%')"/>
  </xsl:function>
  
  <xsl:function name="p:align" as="xs:string">
    <!-- returns an alignment value for an entry -->
    <xsl:param name="entry" as="element(entry)"/>
    <xsl:variable name="t" select="$entry/ancestor::tgroup[1]"/>
    <xsl:variable name="colspec" select="p:colspec-for-entry($entry)"/>
    <!-- taking first available: entry's align, colspec's align, tgroup's align, 'left' -->
    <xsl:sequence select="lower-case(($entry/@align,$colspec/@align,$t/@align,'left')[1])"/>
  </xsl:function>
  
  <xsl:function name="p:colspec-for-entry" as="element(colspec)?"><!-- saxon:memo-function="yes" -->
    <!-- Returns a colspec element for a given entry; works dependably only on normalized tables. -->
    <xsl:param name="entry" as="element(entry)"/>
    <xsl:variable name="t" select="$entry/ancestor::tgroup[1]"/>
    <!-- $nominal colspec is one actually named by the entry. -->
    <xsl:variable name="nominal-colspec" select="$entry/(@namest,@colname)[1]/key('colspec-by-name',.,$t)"/>
    <!-- $positioned-colspec is indicated by the entry's horizontal position -->
    <xsl:variable name="positioned-colspec" select="$entry/key('colspec-by-no',p:values(@p:across)[1],$t)[1]"/>
    <!-- under certain error conditions there might be more than one of either nominal or
         positioned colspecs, so we only return the first -->
    <xsl:sequence select="($nominal-colspec,$positioned-colspec)[1]"/>
  </xsl:function>
  
  <xsl:function name="p:border-spec" as="element(p:border)?"><!-- saxon:memo-function="yes" -->
    <!-- returns an element from inside $a:border-specs for
         applying borders to an entry -->
    <xsl:param name="entry" as="element(entry)"/>
    <xsl:variable name="frame-spec" select="$entry/ancestor::table/@frame"/>
    <xsl:variable name="t" select="$entry/ancestor::tgroup[1]"/>
    <xsl:variable name="across" select="p:values($entry/@p:across)"/>
    <xsl:variable name="down" select="p:values($entry/@p:down)"/>
    
    <xsl:variable name="top-edge" select="empty($entry/ancestor::tgroup/preceding-sibling::tgroup) and ($down = 1)"/>
    <xsl:variable name="bottom-edge" select="empty($entry/ancestor::tgroup/following-sibling::tgroup) and $down = count($t//row)"/>
    <xsl:variable name="left-edge" select="$across = 1"/>
    <xsl:variable name="right-edge" select="$across = $t/@cols"/>
    
    <xsl:variable name="across-index" select="$across[1]"/>
    <xsl:variable name="neighbor-up"
      select="$entry/key('entry-by-row',(($down[1]) - 1),$t)[p:values(@p:across) = $across-index]"/>
    <xsl:variable name="neighbor-left"
      select="$entry/key('entry-by-row',($down[1]),$t)[p:values(@p:across) = ($across-index - 1)]"/>
    
    <!-- $top is set if the closest available @rowsep is '1'
         (from among the neighbor entry's @rowsep, its colspec's @rowsep, its row's @rowsep,
          a @rowsep on the entry's tgroup or table) -->
    <xsl:variable name="top" select="(($neighbor-up/@rowsep, $neighbor-up/p:colspec-for-entry(.)/@rowsep,
      $neighbor-up/parent::row/@rowsep, $entry/ancestor::tgroup[1]/@rowsep, $entry/ancestor::table[1]/@rowsep)[1] = '1')
      or ($top-edge and $frame-spec=('top','topbot','all'))"/>
    <!-- checking the entry likewise for $bottom -->
    <xsl:variable name="bottom" select="(($entry/@rowsep, $entry/p:colspec-for-entry(.)/@rowsep,
      $entry/parent::row/@rowsep, $entry/ancestor::tgroup[1]/@rowsep, $entry/ancestor::table[1]/@rowsep)[1] = '1')
      or ($bottom-edge and $frame-spec=('bottom','topbot','all'))"/>
    <!-- $left is set if the closest available @colsep is 1
         (from among the neighbor entry's @colsep, its colspec's @colsep,
          or a @colsep on the entry's tgroup or table) -->
    <xsl:variable name="left" select="(($neighbor-left/@colsep, $neighbor-left/p:colspec-for-entry(.)/@colsep,
      $entry/ancestor::tgroup[1]/@colsep, $entry/ancestor::table[1]/@colsep)[1] = '1')
      or ($left-edge and $frame-spec=('left','sides','all'))"/>
    <!-- checking the entry likewise for $right -->
    <xsl:variable name="right" select="(($entry/@colsep, $entry/p:colspec-for-entry(.)/@colsep,
      $entry/ancestor::tgroup[1]/@colsep, $entry/ancestor::table[1]/@colsep)[1] = '1')
      or ($right-edge and $frame-spec=('right','sides','all'))"/>
    
    <!-- border-off strings together any of 'tblr' that will be turned off -->
    <xsl:variable name="border-off" select="string-join(
      ('t'[not($top)],'b'[not($bottom)],'l'[not($left)],'r'[not($right)]),'')"/>
    
    <xsl:variable name="code" select="translate('tblr',$border-off,'xxxx')"/>
    
    <xsl:sequence select="$p:border-specs[@class=string-join(($code,'borders'),'-')]"/>
  </xsl:function>
  
  <xsl:variable name="p:border-specs" as="element(p:border)+">
    <!-- Elements specifying CSS styles for borders; map these to other formats by processing with templates. -->
    <p:border class="xxxx-borders" style="border-top-style: none; border-bottom-style: none; border-left-style: none; border-right-style: none"/>
    <p:border class="txxx-borders" style="border-top-style: {$default-border-style}; border-bottom-style: none; border-left-style: none; border-right-style: none"/>
    <p:border class="xbxx-borders" style="border-top-style: none; border-bottom-style: {$default-border-style}; border-left-style: none; border-right-style: none"/>
    <p:border class="xxlx-borders" style="border-top-style: none; border-bottom-style: none; border-left-style: {$default-border-style}; border-right-style: none"/>
    <p:border class="xxxr-borders" style="border-top-style: none; border-bottom-style: none; border-left-style: none; border-right-style: {$default-border-style}"/>
    <p:border class="tbxx-borders" style="border-top-style: {$default-border-style}; border-bottom-style: {$default-border-style}; border-left-style: none; border-right-style: none"/>
    <p:border class="txlx-borders" style="border-top-style: {$default-border-style}; border-bottom-style: none; border-left-style: {$default-border-style}; border-right-style: none"/>
    <p:border class="txxr-borders" style="border-top-style: {$default-border-style}; border-bottom-style: none; border-left-style: none; border-right-style: {$default-border-style}"/>
    <p:border class="xblx-borders" style="border-top-style: none; border-bottom-style: {$default-border-style}; border-left-style: {$default-border-style}; border-right-style: none"/>
    <p:border class="xbxr-borders" style="border-top-style: none; border-bottom-style: {$default-border-style}; border-left-style: none; border-right-style: {$default-border-style}"/>
    <p:border class="xxlr-borders" style="border-top-style: none; border-bottom-style: none; border-left-style: {$default-border-style}; border-right-style: {$default-border-style}"/>
    <p:border class="tblx-borders" style="border-top-style: {$default-border-style}; border-bottom-style: {$default-border-style}; border-left-style: {$default-border-style}; border-right-style: none"/>
    <p:border class="tbxr-borders" style="border-top-style: {$default-border-style}; border-bottom-style: {$default-border-style}; border-left-style: none; border-right-style: {$default-border-style}"/>
    <p:border class="txlr-borders" style="border-top-style: {$default-border-style}; border-bottom-style: none; border-left-style: {$default-border-style}; border-right-style: {$default-border-style}"/>
    <p:border class="xblr-borders" style="border-top-style: none; border-bottom-style: {$default-border-style}; border-left-style: {$default-border-style}; border-right-style: {$default-border-style}"/>
    <p:border class="tblr-borders" style="border-top-style: {$default-border-style}; border-bottom-style: {$default-border-style}; border-left-style: {$default-border-style}; border-right-style: {$default-border-style}"/>
  </xsl:variable>
  
</xsl:stylesheet>
