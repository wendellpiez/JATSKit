package com.oxygenxml.jats;

import java.net.URL;
import java.util.List;

import javax.swing.text.BadLocationException;

import ro.sync.ecss.extensions.api.AuthorAccess;
import ro.sync.ecss.extensions.api.AuthorExternalObjectInsertionHandler;
import ro.sync.ecss.extensions.api.AuthorOperationException;
import ro.sync.ecss.extensions.api.schemaaware.SchemaAwareHandlerResult;
import ro.sync.ecss.extensions.api.schemaaware.SchemaAwareHandlerResultInsertConstants;

public class JATSExternalObjectInsertionHandler  extends AuthorExternalObjectInsertionHandler {


	/**
	 * @throws AuthorOperationException 
	 * @see ro.sync.ecss.extensions.api.AuthorExternalObjectInsertionHandler#insertURLs(ro.sync.ecss.extensions.api.AuthorAccess, java.util.List, int)
	 */
	@Override
	public void insertURLs(AuthorAccess authorAccess, List<URL> urls, int source) throws AuthorOperationException {
		if(! urls.isEmpty()) {
			URL base = getBaseURLAtCaretPosition(authorAccess);
			for (int i = 0; i < urls.size(); i++) {
				URL url = urls.get(i);
				String refAttrName = "xlink:href";
				SchemaAwareHandlerResult result = null;

				//Compute relative location
				String refAttrValue = authorAccess.getUtilAccess().makeRelative(base, url);

				int cp = authorAccess.getEditorAccess().getCaretOffset();
				if(authorAccess.getUtilAccess().isSupportedImageURL(url)) {
					boolean inInlineContext = false;
			        try {
						inInlineContext = authorAccess.getDocumentController().inInlineContext(
						        authorAccess.getEditorAccess().getCaretOffset());
					} catch (BadLocationException e) {
						e.printStackTrace();
					}
			        String tagName = "graphic"; 
			        if(inInlineContext){
			        	tagName = "inline-graphic";
			        }
					//We have to make an image reference to it.
					result =
							authorAccess.getDocumentController().insertXMLFragmentSchemaAware(
									"<" + tagName +  " " + refAttrName + "=\"" + refAttrValue + "\"/>", cp, true);
				} else {
					// <ext-link xlink:href="http://www.google.com"></ext-link>
					result =
							authorAccess.getDocumentController().insertXMLFragmentSchemaAware(
									"<ext-link " + refAttrName + "=\"" + refAttrValue + "\"/>", cp, true);
				}
				if(result != null && i < urls.size() - 1) {
					//Move after the inserted element to insert the next one.
					Integer off =
							(Integer) result.getResult(
									SchemaAwareHandlerResultInsertConstants.RESULT_ID_HANDLE_INSERT_FRAGMENT_OFFSET);
					if(off != null) {
						authorAccess.getEditorAccess().setCaretPosition(off.intValue() + 2);
					}
				}
			}
		}
	}

	/**
	 * @see ro.sync.ecss.extensions.api.AuthorExternalObjectInsertionHandler#getImporterStylesheetFileName(ro.sync.ecss.extensions.api.AuthorAccess)
	 */
	@Override
	protected String getImporterStylesheetFileName(AuthorAccess authorAccess) {
		return "xhtml2JATSDriver.xsl";
	}

	/**
	 * @see ro.sync.ecss.extensions.api.AuthorExternalObjectInsertionHandler#checkImportedXHTMLContentIsPreservedEntirely()
	 */
	@Override
	protected boolean checkImportedXHTMLContentIsPreservedEntirely() {
		return true;
	}
}