<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  xmlns:epub="http://www.idpf.org/2007/ops" exclude-result-prefixes="xs jatskit" version="2.0">

  <xsl:import href="jatskit-ebook-html.xsl"/>

  <xsl:template match="/">
    <xsl:apply-templates select="book"/>
  </xsl:template>

  <xsl:template match="book">
    <xsl:call-template name="make-html-page">
      <xsl:with-param name="attribute-proxies" as="element()?">
        <html class="apparatus">
          <xsl:call-template name="locate-page">
            <xsl:with-param name="page-label" as="xs:string">colophon</xsl:with-param>
            <xsl:with-param name="page-format" as="xs:string">xhtml</xsl:with-param>
          </xsl:call-template>
        </html>
      </xsl:with-param>
      <xsl:with-param name="html-contents">
        <xsl:variable name="rendered-title">
          <i class="title">
            <xsl:apply-templates select="book-meta/book-title-group/book-title"/>
          </i>
        </xsl:variable>
        <div class="colophon-body">
          <ul class="pagelinks">
            <xsl:call-template name="toc-component-links">
              <xsl:with-param name="pages" as="element()*">
                <jatskit:titlepage/>
                <jatskit:halftitle/>
                <jatskit:toc/>
              </xsl:with-param>
            </xsl:call-template>
          </ul>
          <div class="boxed-text panel">
          <p>This presentation of <xsl:sequence select="$rendered-title"/>
            <xsl:text> is a production from XML source data encoded in NISO/NLM JATS 
              or BITS format, using (at least in part) stylesheets and tools distributed
              as </xsl:text><cite>JATSKit</cite><xsl:text>.</xsl:text>
          </p>
            <p><a href="https://github.com/wendellpiez/JATSKit"><cite>JATSKit</cite> (see its Github page)</a> is a
            project of Wendell Piez, 2015-. <cite>JATSKit</cite> is built to be open and extensible, so much of what 
            you see might be due to alterations and extensions for local use. This is part of the idea: its system
            components, defined using publicly-specified open technologies such as XSLT and XProc, are made to
            be hacked. Developers who make improvements and extensions to <cite>JATSKit</cite>, or reuse or adapt
              parts of it, are invited to edit the XSLT that generates this text to give themselves notice.</p>
            <p>Acknowledgement for contributions to <cite>JATSKit</cite> in present or earlier versions is owed
            (among others) to <a href="http://www.ncbi.nlm.nih.gov/">NLM/NCBI</a> (including for <a
              href="https://github.com/ncbi/JATSPreviewStylesheets">JATS Preview XSLTs)</a>, to
            <a href="http://www.mulberrytech.com">Mulberry Technologies, Inc.</a>, and to the 
            <a href="http://www.oxygenxml.com">oXygen XML Editor</a> team.</p>
          </div>
          <ul class="pagelinks">
            <xsl:call-template name="toc-component-links">
              <xsl:with-param name="pages" as="element()*">
                <jatskit:titlepage/>
                <jatskit:halftitle/>
                <jatskit:toc/>
              </xsl:with-param>
            </xsl:call-template>
          </ul>
        </div>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>



</xsl:stylesheet>
