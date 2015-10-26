<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
  xmlns:sqf="http://www.schematron-quickfix.com/validator/process">

  <sch:ns uri="http://www.w3.org/1999/xlink"       prefix="xlink"/>
  <sch:ns uri="http://www.w3.org/1998/Math/MathML" prefix="mml"/>

  <sch:pattern>
    <sch:rule context="book-part">
      <sch:assert test="matches(@id,'\S')" role="warning">Missing @id on a book-part</sch:assert>
      <sch:assert role="warning" test="exists(book-part-meta/title-group/title)" sqf:fix="add-bookpart-title">Book part has no title; it will appear as "Untitled" in a
      table of contents.</sch:assert>
      <sqf:fix id="add-bookpart-title">
        <sqf:description>
          <sqf:title>Add book part title</sqf:title>
        </sqf:description>
        <sqf:add use-when="exists(book-part-meta/title-group)" match="book-part-meta/title-group">
          <title>[Book part title]</title>
        </sqf:add>
        <sqf:add use-when="exists(book-part-meta) and empty(book-part-meta/title-group)" match="book-part-meta">
          <title-group>
            <title>[Book part title]</title>
          </title-group>
        </sqf:add>
        <sqf:add use-when="empty(book-part-meta)">
          <book-part-meta>
            <title-group>
              <title>[Book part title]</title>
            </title-group>
          </book-part-meta>
        </sqf:add>
      </sqf:fix>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern>
    <sch:rule context="xref">
      <sch:let name="any-id" value="//@id"/>
      <sch:assert role="warning" test="exists(@rid)" sqf:fix="add-rid">Cross-reference has not target. It will be ignored.</sch:assert>
      <sqf:fix id="add-rid">
        <sqf:description>
          <sqf:title>Add xref/@rid</sqf:title>
        </sqf:description>
        <sqf:add target="rid" node-type="attribute"/>
      </sqf:fix>
      <report test="count(tokenize(@rid,'\s+')) gt 1" sqf:fix="repair-rid">Sorry, cross-reference targets must be single.</report>
      <sqf:fix id="repair-rid">
        <sqf:description>
          <sqf:title>Repair xref/@rid</sqf:title>
        </sqf:description>
        <sqf:replace match="@rid" target="rid" node-type="attribute"/>
      </sqf:fix>
    </sch:rule>
    
    <sch:rule context="graphic">
      <sch:assert test="matches(tokenize(@xlink:href,'/')[last()],'^\i\c*$')">
        graphic/@xlink:href has troublesome characters in its filename, causing confusion in EPUB assembly. Please
        rename the file or pick another.</sch:assert>
    </sch:rule>
    
  </sch:pattern>
</sch:schema>