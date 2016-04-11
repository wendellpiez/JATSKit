<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
  xmlns:sqf="http://www.schematron-quickfix.com/validator/process">

  <sch:ns uri="http://www.w3.org/1999/xlink"       prefix="xlink"/>
  <sch:ns uri="http://www.w3.org/1998/Math/MathML" prefix="mml"/>

  <sch:pattern>
    <sch:rule context="book-part">
      
      <!-- @id is constrained by jatskit-QA.sch; we do not have to constrain it here since for EPUB generation,
           a fallback can be provided. -->
      
      <sch:assert role="warning" test="exists(book-part-meta/title-group/title)" sqf:fix="add-bookpart-title">Book part has no title; it will appear as "Untitled" in a
      table of contents.</sch:assert>
      <sqf:fix id="add-bookpart-title">
        <sqf:description>
          <sqf:title>Add book part title</sqf:title>
        </sqf:description>
        <sqf:user-entry name="title">
          <sqf:description>
            <sqf:title>Book part title</sqf:title>
          </sqf:description>
        </sqf:user-entry>
        <sqf:add use-when="exists(book-part-meta/title-group)" match="book-part-meta/title-group">
          <title>
            <sch:value-of select="$title"/>
          </title>
        </sqf:add>
        <sqf:add use-when="exists(book-part-meta) and empty(book-part-meta/title-group)" match="book-part-meta">
          <title-group>
            <title>
              <sch:value-of select="$title"/>
            </title>
          </title-group>
        </sqf:add>
        <sqf:add use-when="empty(book-part-meta)">
          <book-part-meta>
            <title-group>
              <title>
                <sch:value-of select="$title"/>
              </title>
            </title-group>
          </book-part-meta>
        </sqf:add>
      </sqf:fix>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern>
    <sch:rule context="xref">
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
</sch:schema>