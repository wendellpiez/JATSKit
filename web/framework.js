goog.provide('com.oxygenxml.JatsExtension');

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
 * @param editor the editor loaded event.
 */
com.oxygenxml.JatsExtension.prototype.editorLoadedHandler = function(editor) {
  var actionsManager = editor.getActionsManager();
  var actionIdInsertImage = 'insert.image';

  var originalInsertImageAction = actionsManager.getActionById(actionIdInsertImage);
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