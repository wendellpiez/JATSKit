/*
 *  The Syncro Soft SRL License
 *
 *  Copyright (c) 1998-2009 Syncro Soft SRL, Romania.  All rights
 *  reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  1. Redistribution of source or in binary form is allowed only with
 *  the prior written permission of Syncro Soft SRL.
 *
 *  2. Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 *
 *  3. Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in
 *  the documentation and/or other materials provided with the
 *  distribution.
 *
 *  4. The end-user documentation included with the redistribution,
 *  if any, must include the following acknowledgment:
 *  "This product includes software developed by the
 *  Syncro Soft SRL (http://www.sync.ro/)."
 *  Alternately, this acknowledgment may appear in the software itself,
 *  if and wherever such third-party acknowledgments normally appear.
 *
 *  5. The names "Oxygen" and "Syncro Soft SRL" must
 *  not be used to endorse or promote products derived from this
 *  software without prior written permission. For written
 *  permission, please contact support@oxygenxml.com.
 *
 *  6. Products derived from this software may not be called "Oxygen",
 *  nor may "Oxygen" appear in their name, without prior written
 *  permission of the Syncro Soft SRL.
 *
 *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED.  IN NO EVENT SHALL THE SYNCRO SOFT SRL OR
 *  ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 *  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 *  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 *  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 *  SUCH DAMAGE.
 */
package com.oxygenxml.jats;

import javax.swing.text.BadLocationException;

import ro.sync.annotations.api.API;
import ro.sync.annotations.api.APIType;
import ro.sync.annotations.api.SourceType;
import ro.sync.ecss.extensions.api.ArgumentDescriptor;
import ro.sync.ecss.extensions.api.ArgumentsMap;
import ro.sync.ecss.extensions.api.AuthorAccess;
import ro.sync.ecss.extensions.api.AuthorOperation;
import ro.sync.ecss.extensions.api.AuthorOperationException;
import ro.sync.ecss.extensions.api.AuthorSchemaManager;
import ro.sync.ecss.extensions.api.node.AttrValue;
import ro.sync.ecss.extensions.api.node.AuthorDocumentFragment;
import ro.sync.ecss.extensions.api.node.AuthorElement;
import ro.sync.ecss.extensions.api.node.AuthorNode;
import ro.sync.ecss.extensions.api.schemaaware.SchemaAwareHandlerResult;
import ro.sync.ecss.extensions.commons.ImageFileChooser;

/**
 * Operation used to insert an image in JATS documents.
 */
@API(type=APIType.INTERNAL, src=SourceType.PUBLIC)
public class InsertGraphicOperation implements AuthorOperation {
  
  /**
   * The reference value argument sent by the WebAuthor.
   */
  private static final String ARGUMENT_REFERENCE_VALUE = "imageUrl";
  
  /**
   * @see ro.sync.ecss.extensions.api.AuthorOperation#doOperation(ro.sync.ecss.extensions.api.AuthorAccess, ro.sync.ecss.extensions.api.ArgumentsMap)
   */
  public void doOperation(AuthorAccess authorAccess, ArgumentsMap args)
  throws IllegalArgumentException, AuthorOperationException {
    // the Web Author passes the ref as an argument.
    String ref = (String)args.getArgumentValue(ARGUMENT_REFERENCE_VALUE);
    if (ref == null) {
      ref = ImageFileChooser.chooseImageFile(authorAccess);
    }
    if(ref != null) {
      insertImageRef(authorAccess, ref);
    }
  }

  /**
   * Insert an image reference.
   * 
   * @param authorAccess Author access
   * @param ref The image reference
   * @return The insertion result
   * @throws AuthorOperationException
   */
  public static SchemaAwareHandlerResult insertImageRef(AuthorAccess authorAccess, String ref) throws AuthorOperationException {
    SchemaAwareHandlerResult result = null;
    int caretOffset = authorAccess.getEditorAccess().getCaretOffset();
    boolean insertImageRef = true;
      try {
        AuthorNode nodeAtOffset = authorAccess.getDocumentController().getNodeAtOffset(caretOffset);
        if(nodeAtOffset.getType() == AuthorNode.NODE_TYPE_ELEMENT){
          AuthorElement elementAtOffset = (AuthorElement) nodeAtOffset;
          if("graphic".equals(elementAtOffset.getLocalName())
        		  || "inline-graphic".equals(elementAtOffset.getLocalName())){
            //Replace the fileref
            authorAccess.getDocumentController().setAttribute("xlink:href", new AttrValue(ref), elementAtOffset);
            //We have changed the reference to the image.
            insertImageRef = false;
          }
        }
      } catch (BadLocationException e) {
    	  e.printStackTrace();
      }
      if(insertImageRef) {
    	  //First try to insert an inline-graphic
    	  String inlineGraphFrag = createFragmentToInsert(ref, "inline-graphic");
    	  AuthorDocumentFragment frag = authorAccess.getDocumentController().createNewDocumentFragmentInContext(inlineGraphFrag,  caretOffset);
    	  if(frag != null && authorAccess.getDocumentController().getAuthorSchemaManager().canInsertDocumentFragment(frag, caretOffset, AuthorSchemaManager.VALIDATION_MODE_LAX)){
    		 //Insert inline-graphic 
        	  result = authorAccess.getDocumentController().insertFragmentSchemaAware(
        			  caretOffset, frag);
    	  } else {
    		  String graphicFrag = createFragmentToInsert(ref, "graphic");
    		  // Insert the graphic
    		  result = authorAccess.getDocumentController().insertXMLFragmentSchemaAware(
    				  graphicFrag,
    				  caretOffset);
    	  }
      }
    return result;
  }

  /**
   * Create a fragment to insert.
   * 
   * @param ref The href value.
   * @param elemName The element name.
   */
  private static String createFragmentToInsert(String ref, String elemName) {
	  StringBuffer fragment = new StringBuffer();
	  fragment.append("<" + elemName + " ");
	  fragment.append("xmlns:xlink=\"http://www.w3.org/1999/xlink\" ");
	  fragment.append("xlink:href=\"");
	  fragment.append(ref);
	  fragment.append("\">");
	  fragment.append("</" + elemName + ">");
	  return fragment.toString();
  }

  /**
   * No arguments. The operation will display a dialog for choosing the image fileref.
   * 
   * @see ro.sync.ecss.extensions.api.AuthorOperation#getArguments()
   */
  public ArgumentDescriptor[] getArguments() {
    return null;
  }

  /**
   * @see ro.sync.ecss.extensions.api.Extension#getDescription()
   */
  public String getDescription() {
    return "Insert a JATS image";
  }
}