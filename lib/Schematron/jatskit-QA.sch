<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
  
  xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
  
  <sch:ns uri="http://www.w3.org/1999/xlink"       prefix="xlink"/>
  <sch:ns uri="http://www.w3.org/1998/Math/MathML" prefix="mml"/>
  <sch:ns uri="http://www.niso.org/standards/z39-96/ns/oasis-exchange/table" prefix="oasis"/>
  
  <sch:pattern>
    <sch:rule context="book-part | sec | fig | table-wrap | boxed-text | disp-formula | statement | app">
      <sch:assert test="matches(@id,'\S')" role="warning" sqf:fix="add-composed-id add-named-id">Missing @id on <sch:name/></sch:assert>
      <sqf:fix id="add-composed-id">
        <sch:let name="name" value="name()"/>
        <sch:let name="element-id" value="concat($name,'-',count(.|preceding::*[name()=$name]))"/>
        <sqf:description>
          <sqf:title>Add @id '<sch:value-of select="$element-id"/>'</sqf:title>
        </sqf:description>
        <sqf:add node-type="attribute" target="id" select="$element-id"/>
      </sqf:fix>
      <sch:let name="title" value="(title | book-part-meta/title-group/title | caption/title)[1]/normalize-space(.)"/>
      <sqf:fix id="add-named-id"            use-when="matches($title,'\c')"><!-- Using if the title has any name character. -->
        <sch:let name="space-spliced"       value="replace(normalize-space($title),' ','_')"/>
        <sch:let name="trimmed-to-namechar" value="replace($space-spliced,'\C','')"/>
        <sqf:description>
          <sqf:title>Add @id '<sch:value-of select="$trimmed-to-namechar"/>'</sqf:title>
        </sqf:description>
        <!--<sqf:user-entry name="user-id">
          <sqf:description>
            <sqf:title>ID</sqf:title>
          </sqf:description>
        </sqf:user-entry>-->
        <sqf:add node-type="attribute" target="id" select="$trimmed-to-namechar"/>
      </sqf:fix>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern>
    <!--(book-count*, book-fig-count?, book-table-count?, book-equation-count?, book-ref-count?, book-page-count?, book-word-count?)
    (count*, fig-count?, table-count?, equation-count?, ref-count?, page-count?, word-count?)-->
<!-- book-equation-count, equation-count - disp-formula | inline-formula?
       book-count and count -->
    <sch:rule context="book-fig-count | fig-count">
      <sch:let name="owner" value="ancestor::*[self::book | self::book-part | self::article][1]"/>
      <sch:let name="counted" value="count($owner//fig)"/>
      <sch:let name="is-a-number" value="@count castable as xs:integer and (@count/number(.) ge 0)"/>
      <sch:assert sqf:fix="correct-fig-count" test="$is-a-number">Count should be a whole number (non-negative integer).</sch:assert>
      <sch:assert sqf:fix="correct-fig-count" test="not($is-a-number) or @count = $counted" role="warning">A figure count is given as
        <sch:value-of select="@count"/>; we count <sch:value-of select="$counted"/> 'fig'
        element<sch:value-of select="if ($counted eq 1) then '' else 's'"/> in this <sch:value-of select="$owner/name()"/>.</sch:assert>
      <sqf:fix id="correct-fig-count">
        <sqf:description>
          <sqf:title>Set count to '<sch:value-of select="$counted"/>'</sqf:title>
        </sqf:description>
        <sqf:call-fix ref="correct-count">
          <sqf:with-param name="correction" select="$counted"/>
        </sqf:call-fix>
      </sqf:fix>
    </sch:rule>

    <sch:rule context="book-table-count | table-count">
      <sch:let name="owner" value="ancestor::*[self::book | self::book-part | self::article][1]"/>
      <sch:let name="counted" value="count($owner//table-wrap)"/>
      <sch:let name="is-a-number" value="@count castable as xs:integer and (@count/number(.) ge 0)"/>
      <sch:assert sqf:fix="correct-table-count" test="$is-a-number">Count should be a whole number (non-negative integer).</sch:assert>
      <sch:assert sqf:fix="correct-table-count" test="not($is-a-number) or @count = $counted" role="warning">A table count is given as
        <sch:value-of select="@count"/>; we count <sch:value-of select="$counted"/> 'table-wrap'
        element<sch:value-of select="if ($counted eq 1) then '' else 's'"/> in this <sch:value-of select="$owner/name()"/>.</sch:assert>
      <sqf:fix id="correct-table-count">
        <sqf:description>
          <sqf:title>Set count to '<sch:value-of select="$counted"/>'</sqf:title>
        </sqf:description>
        <sqf:call-fix ref="correct-count">
          <sqf:with-param name="correction" select="$counted"/>
        </sqf:call-fix>
      </sqf:fix>
    </sch:rule>
    
    <sch:rule context="book-ref-count | ref-count">
      <sch:let name="owner" value="ancestor::*[self::book | self::book-part | self::article][1]"/>
      <sch:let name="counted" value="count($owner//ref)"/>
      <sch:let name="is-a-number" value="@count castable as xs:integer and (@count/number(.) ge 0)"/>
      <sch:assert sqf:fix="correct-ref-count" test="$is-a-number">Count should be a whole number (non-negative integer).</sch:assert>
      <sch:assert sqf:fix="correct-ref-count" test="not($is-a-number) or @count = $counted" role="warning">A reference count is given as
        <sch:value-of select="@count"/>; we count <sch:value-of select="$counted"/> 'ref'
        element<sch:value-of select="if ($counted eq 1) then '' else 's'"/> in this <sch:value-of select="$owner/name()"/>.</sch:assert>
      <sqf:fix id="correct-ref-count">
        <sqf:description>
          <sqf:title>Set count to '<sch:value-of select="$counted"/>'</sqf:title>
        </sqf:description>
        <sqf:call-fix ref="correct-count">
          <sqf:with-param name="correction" select="$counted"/>
        </sqf:call-fix>
      </sqf:fix>
    </sch:rule>
    
  </sch:pattern> 
  
  <sch:pattern>
  <!--    <sch:rule context="xref">
      <sch:assert role="warning" test="exists(@rid)" sqf:fix="add-rid">Cross-reference has not target. It will be ignored.</sch:assert>
      <sqf:fix id="add-rid">
        <sqf:description>
          <sqf:title>Add xref/@rid ('rid' attribute on 'xref' element)</sqf:title>
        </sqf:description>
        <sqf:add target="rid" node-type="attribute"/>
      </sqf:fix>
      <sch:report test="count(tokenize(@rid,'\s+')) gt 1" sqf:fix="repair-rid">Sorry, cross-reference targets must be single.</sch:report>
      <sqf:fix id="repair-rid">
        <sch:let name="first-given" value="tokenize(@rid,'\s+')[1]"/>
        <sqf:description>
          <sqf:title>Repair xref/@rid ('rid' attribute on 'xref' element) - pick the first one given
            (<sch:value-of select="$first-given"/>)</sqf:title>
        </sqf:description>
        <sqf:replace match="@rid" target="rid" node-type="attribute" select="$first-given"/>
      </sqf:fix>
    </sch:rule>
    -->
    <sch:let name="known-imagefile-suffixes" value="('jpg','jpeg','png','svg')"/>

    <sch:rule context="graphic">
      <sch:let name="filename" value="tokenize(@xlink:href,'/')[last()]"/>
      <sch:assert test="matches($filename,'^\i\c*$')">
        A graphic/@xlink:href has troublesome characters in its filename, which will cause confusion in EPUB assembly. Please
        rename the file or pick another.</sch:assert>
      <sch:assert test="replace($filename,'^.+\.','') = $known-imagefile-suffixes">
        A graphic appears to point to an unknown image type, given its file suffix. The EPUB wants jpegs,
        PNG or SVG images, indicated by common file suffixes for each.
      </sch:assert>
    </sch:rule>
    
  </sch:pattern>
  
  <sch:pattern>
    <sch:let name="alert" value="true()"/>
    <sch:rule context="abstract//p//p">
      <sch:report role="warning" test="$alert">Paragraph structures nested inside paragraph structures inside abstract ... is a bad idea ...</sch:report>
    </sch:rule>
    <sch:rule context="fn//fn">
      <sch:report role="warning" test="$alert">Footnote nested inside footnote (fn) ...</sch:report>
    </sch:rule>
  </sch:pattern>
  
  <sqf:fixes>
    <sqf:fix id="correct-count">
      <sqf:param name="correction"/>  
      <sqf:description>
        <sqf:title>Set count to '<sch:value-of select="$correction"/>'</sqf:title>
      </sqf:description>
      <sqf:add node-type="attribute" target="count" select="$correction"/>
    </sqf:fix>
    
  </sqf:fixes>
</sch:schema>