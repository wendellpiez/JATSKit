<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  queryBinding="xslt2">
  
  <ns prefix="o" uri="http://www.niso.org/standards/z39-96/ns/oasis-exchange/table"/>
  
  <title>OASIS/CALS table validation</title>
  <p>Checks whether a table is "square": every row has the same number of cells,
     while no place is claimed by more than one cell.</p>
  
  <ns prefix="p" uri="http://www.wendellpiez.com/oasis-tables/util"/>
  <!--<ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>-->
  
  <!-- the included stylesheet includes key and function declarations required -->
  <xsl:include href="oasis-table-schematron-support.xsl"/>
  
  <!--<let name="default-border-style" value="solid"/>-->
  
  <pattern>
    
    <rule context="o:table">
      
    </rule>
    
    <rule context="o:tgroup">
      <let name="okay-cols" value="@cols[. castable as xs:integer][. > 0]"/>
      <assert test="exists(@cols)">tgroup/@cols is not given</assert>
      <assert test="empty(@cols) or exists($okay-cols)">@cols should be a natural number
      (integer greater than zero).</assert>
      <!--<report test="not(*/ROW/p:actual-cols(.) != */ROW/p:actual-cols(.))
        and ($okay-cols != p:actual-cols((*/ROW)[1]))">TGROUP/@COLS is given as
        <value-of select="$okay-cols"/>, but all rows have <value-of
          select="p:actual-cols((*/ROW)[1])"/> entr<value-of 
          select="if (p:actual-cols((*/ROW)[1]) eq 1) then 'y' else 'ies'"/>.
      </report>-->
      <report test="@align='char'" role="warning">Without assigning @char or @charoff to everything,
        assigning @align='char' to tgroup only aligns contents to right of center.</report>
    </rule>
    
    <rule context="o:colspec">
      <let name="okay-colwidth"
        value="@colwidth[exists(p:colwidth-unit(current()))]"/>
      <assert test="empty(@colwidth) or exists($okay-colwidth)">Malformed @colwidth.</assert>
      <assert test="empty($okay-colwidth) or 
        (count(../o:colspec[p:colwidth-unit(.)=p:colwidth-unit(current())]) &gt;
         count(../o:colspec[not(p:colwidth-unit(.)=p:colwidth-unit(current()))]))">@colwidth unit
        (<value-of select="p:colwidth-unit(.)"/>) is not consistent with the
        units on other colspecs.</assert>
      
      <assert test="empty($okay-colwidth) or matches($okay-colwidth,'^\s*\*\s*$')
        or (xs:double(replace($okay-colwidth,'[\s\p{L}%\*]','')[. castable as xs:double]) &gt; 0)">@colwidth '<value-of select="$okay-colwidth"/>' must be positive</assert>
      <report test="empty(p:colwidth-unit(.))
        and exists(../o:colspec/p:colwidth-unit(.))">The same unit of measure should be used on every 
        colspec/@colwidth.</report>
      
      <!--<assert test="empty(@COLNUM) or (@COLNUM = count(.|preceding-sibling::COLSPEC))" role="warning">@COLNUM 
        '<value-of select="@COLNUM"/>' does not correspond to
        the column's actual number (<value-of select="count(.|preceding-sibling::COLSPEC)"/>)</assert>-->
      <assert test="not(@colnum = preceding-sibling::o:colspec/@colnum)">Duplicate @colnum <value-of select="@colnum"/> is given.</assert>
      
      <report test="@colname = (../o:colspec except .)/@colname">The same @colname is assigned to more than
         one colspec.</report>
      <assert test="not(@align='char') or exists(@char)" role="warning">@align='char', but no @char is given.</assert>
      <report test="normalize-space(@char) and not((@align,../@align)[1]='char')" role="warning">@char is given, but alignment is not 'char'.</report>
      <assert test="empty(@charoff) or ((@align,../@align)[1]='char')" role="warning">@charoff is given, but alignment is not 'char'.</assert>
    </rule>
    
    <rule context="o:row">
      <let name="tgroup" value="ancestor::o:tgroup[1]"/>
      <let name="cols" value="$tgroup/@cols[. castable as xs:integer]/xs:integer(.)"/>
      <let name="rowno" value="p:rowno(.)"/>
      <let name="given-entries" value="key('entry-by-row',$rowno,$tgroup)"/>
      <let name="entry-count" value="max($given-entries/p:across(.))"/>
      <report test="($entry-count &lt; $cols)
        and exists($cols)" role="warning">
        The row doesn't have enough entries (<value-of select="$cols"/> 
        <value-of select="if ($cols = 1) then ' is' else ' are'"/> expected;
        <value-of select="$entry-count"/> <value-of select="if ($entry-count = 1) then ' is' else ' are'"/> given).
      </report>
      
      <!--<report test="true()" role="info">Row no <value-of select="$rowno"/></report>-->
      
      <let name="too-many-entries" value="($entry-count &gt; $cols)
        and exists($cols)"/>
      
      <let name="inherited-columns" value="distinct-values($given-entries[p:down(.) &lt; $rowno]/p:across(.))"/>
      <let name="plural-inherited-columns" value="count($inherited-columns) gt 1"/>
      
      <report test="$too-many-entries and exists($inherited-columns)" role="warning">
        <xsl:value-of select="if ($plural-inherited-columns) then 'Entries' else 'An entry'"/> for this row
        <xsl:value-of select="if ($plural-inherited-columns) then 'span' else 'spans'"/> from above
        (for column<xsl:value-of select="concat(
          ('s'[$plural-inherited-columns]),' ',
          string-join(for $d in ($inherited-columns) return string($d),', '),')' )"/>
      </report>
    </rule>
    
    <rule context="o:entry">
      <let name="tgroup" value="ancestor::o:tgroup[1]"/>
      <let name="cols" value="$tgroup/@cols[. castable as xs:integer]/xs:integer(.)"/>
      
      <assert test="empty(@nameend) or exists(key('colspec-by-name',@nameend,$tgroup))">No colspec is 
        named <value-of select="@nameend"/>.</assert>
      <assert test="empty(@nameend|@namest) or (@nameend = @namest) or
        (key('colspec-by-name',@nameend,$tgroup) >> key('colspec-by-name',@namest,$tgroup))">Entry's end
        column (<value-of select="@nameend"/>) must follow its start column 
        (<value-of select="@namest"/>).</assert>
      <assert test="empty(@namest) or exists(key('colspec-by-name',@namest,$tgroup))">No colspec is 
        named <value-of select="@namest"/>.</assert>
      <assert test="empty(@colname) or exists(key('colspec-by-name',@colname,$tgroup))">No colspec is 
        named <value-of select="@colname"/>.</assert>
      <assert test="empty(@nameend) or exists(@colname|@namest)">Entry is assigned an end
        column (<value-of select="@nameend"/>) but not a start column.</assert>
      <assert test="not(@colname != @namest)">Entry is assigned to column <value-of select="@colname"/>,
        so it can't start at column <value-of select="@namest"/>.
      </assert>

      <!--<report test="true()">Appears in row no <value-of select="string-join(for $d in p:down(.) return string($d),',')"/></report>-->
      
      <assert test="p:across(.)[1] &gt; (preceding-sibling::o:entry[1]/p:across(.)[last()],0)[1]">
        Entry must be assigned to a free column (after its preceding entries). 
      </assert>
      
      <report test="exists(p:overlaps(.))">Entry occupies the same position as another entry.</report>
      
      <report test="p:down(.) &gt; p:rowno(../../o:row[last()])">this entry doesn't fit into
        its <value-of select="local-name(../..)"/>.</report>
      
      <report test="(exists(@morerows) and
        (key('entry-by-row',p:down(.),$tgroup)/p:across(.)[last()] &gt; $cols))
        or empty($cols)" role="warning">
        A row in which this entry appears has too many entries.
      </report>
      <!-- the next rule will never fire for entries spanning columns: they always
           fit by virtue of being assigned a @nameend -->
      <report test="(p:across(.)[last()] &gt; $cols) or empty($cols)">
        Entry does not fit in row. (<value-of select="concat($cols,' ')"/>
        <value-of select="if ($cols = 1) then 'is' else 'are'"/> allowed; entry
        is in column <value-of select="p:across(.)[last()]"/>.)
        <!-- Entry does not fit in row. (# columns are allowed; row ends in column #.)       -->
      </report>
      
      
      <assert test="empty(@char) or p:align(.)='char'" role="warning">@char is given, but alignment is not 'char'.</assert>
      <assert test="empty(@charoff) or p:align(.)='char'" role="warning">@charoff is given, but alignment is not 'char'.</assert>
      <assert test="empty(@charoff) or ((@charoff castable as xs:integer) and
        (@charoff &gt;= 0) and (@charoff &lt;= 100))">@charoff must be a whole number between 0 and 100.</assert>
      <assert test="not(p:align(.)='char') or exists(@char|p:colspec-for-entry(.)/@char)" role="warning">
        Entry is designated for character alignment, but no character (@char) is given on it or its colspec.
      </assert>
      <assert test="empty(@char) or not(@char != p:colspec-for-entry(.)/@char)">
        entry is assigned an alignment character (<value-of select="@char"/>)
        different from its column's (<value-of select="p:colspec-for-entry(.)/@char"/>).</assert>
      <report test="exists(*) and (p:align(.)='char')" role="warning">with @align='char', markup of 
        entry contents (<value-of select="string-join(distinct-values(*/name()),', ')"/>) will be ignored.</report>
    </rule>
  </pattern>
</schema>