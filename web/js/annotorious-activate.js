annotorious.plugin.DenichePlugin = function(opt_config_options) { 
	/** @private **/
	this._tags = [];
}
annotorious.plugin.DenichePlugin.prototype.initPlugin = function(anno) { }

annotorious.plugin.DenichePlugin.prototype.onInitAnnotator = function(annotator) {
	// this._extendPopup(annotator);
	this._extendEditor(annotator); 
  // var fEl = document.getElementById('fields');
  //  annotator.editor.addField(fEl);
}

anno.addPlugin('DenichePlugin', {});
