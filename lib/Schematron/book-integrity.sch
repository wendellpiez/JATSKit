<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
  xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
  
  <pattern>
    <rule context="book-part">
      <assert test="matches(@id,'\S')" role="warning">Missing @id on a book-part</assert>
    </rule>
  </pattern>
  
</schema>