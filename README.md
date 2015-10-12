oXygenJATSframework
===================

oXygen XML Editor framework for NISO JATS 1.0 / NLM BITS

NISO JATS Z39.96-2012 defines an XML-based format for the authoring,
publication and archiving of journal articles and related information.
Its design is based on the NLM Journal Archiving and Publishing DTDs
through version 3.0.

This oXygen framework supports editing JATS articles along with books
conformant to the specifications of BITS, the JATS-based NLM book
tag set (being finalized as of late 2015). Included are DTDs, CSS files
for authoring, document templates, and XSLT stylesheets for production
of HTML and PDF (preview) outputs.

See the project wiki at https://github.com/wendellpiez/oXygenJATSframework/wiki
for installation instructions.

Wendell Piez (http://www.wendellpiez.com), November 2012, 2015

In this directory find the following:

css
  CSS files used for Authoring
i18n
  oXygen UI configuration
img
  support for oXygen UI
jats-preview-xslt
  A copy of the public JATS Preview stylesheet distribution as of Sep 2015
  See https://github.com/ncbi/JATSPreviewStylesheets
lib
  BITS/JATS DTDs, schemas and what have you
  including Schematron, XSLTs and more
resources
  mainly XSLT for oXygen import into JATS (smart paste)
src
  Source code for java extensions to oXygen
templates
  Document templates for JATS and BITS

build.xml
jats-framework-docs.html (HTML version via XSLT)
jats-framework-docs.xml (source JATS article)
jats.framework (oXygen settings)
jats.jar (oXygen Java support)
LICENSE.TXT
oXygenJATSframework.xml - more configuration for oXygen
README.md

