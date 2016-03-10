<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
  
  xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
  
  <sch:ns uri="http://www.w3.org/1999/xlink"       prefix="xlink"/>
  <sch:ns uri="http://www.w3.org/1998/Math/MathML" prefix="mml"/>

  <sch:pattern>
    <sch:rule context="book-part | sec | fig | table-wrap | boxed-text | disp-formula | statement">
      <sch:assert test="matches(@id,'\S')" role="warning">Missing @id</sch:assert>
      <sqf:fix id="add-id">
        <sqf:description>
          <sqf:title>Add ID</sqf:title>
        </sqf:description>
        <sqf:user-entry name="user-id">
          <sqf:description>
            <sqf:title>ID</sqf:title>
          </sqf:description>
        </sqf:user-entry>
        
        <!--<sqf:user-entry name="newName">
          <sqf:description>
            <sqf:title>Enter the new name.</sqf:title>
          </sqf:description>
        </sqf:user-entry>-->
        <!--<sqf:replace target="{$newName}" node-type="pi">
        	<value-of select="."/>
       </sqf:replace>-->
        
        <!--<sqf:replace use-when="exists(@id)" node-type="attribute"  match="id" target="id">
          <sch:value-of select="$id"/>
        </sqf:replace>-->
        <!--<sqf:add use-when="empty(@id)" node-type="attribute" match="id" target="id">
          <sch:value-of select="$id"/>
        </sqf:add>-->
        <sqf:add node-type="attribute" target="id" select="@id">
          <sch:value-of select="$user-id"/>
        </sqf:add>
        
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
</sch:schema>