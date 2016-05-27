goog.provide('com.oxygenxml.JatsExtension');

console.log('HERTE');
/**
 * Constructor for the jats Extension.
 *
 * @constructor
 */
com.oxygenxml.JatsExtension = function(){
  sync.ext.Extension.call(this);
};
goog.inherits(com.oxygenxml.JatsExtension, sync.ext.Extension);

/**
 * Editor created callback.
 *
 * @param {sync.Editor} editor The currently created editor.
 */
com.oxygenxml.JatsExtension.prototype.editorCreated = function(editor) {
  goog.events.listen(editor, sync.api.Editor.EventTypes.ACTIONS_LOADED,
    goog.bind(this.editorLoadedHandler, this, editor));
};

/**
 * Handler for the editor loaded event.
 *
 * @param e the editor loaded event.
 */
com.oxygenxml.JatsExtension.prototype.editorLoadedHandler = function(editor, e) {
  var actionsManager = editor.getActionsManager();
  var actionIdInsertImage = 'insert.image';

  var originalInsertImageAction = actionsManager.getActionById(actionIdInsertImage);
  console.log('inset image action :', originalInsertImageAction);
  if (originalInsertImageAction) {
    var insertImageAction = new sync.actions.InsertImage(
      originalInsertImageAction,
      'com.oxygenxml.jats.InsertGraphicOperation',
      editor);
    actionsManager.registerAction(actionIdInsertImage, insertImageAction);
  }
}

// Publish the extension.
sync.ext.Registry.extension = new com.oxygenxml.JatsExtension();