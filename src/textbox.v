module iui

// Deprecated - Replaced by better TextArea/TextField
[deprecated: 'Replaced with TextArea/TextField']
pub fn textbox(app &Window, text string) &TextArea {
	return textarea(app, [text])
}
