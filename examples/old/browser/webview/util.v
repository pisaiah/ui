module webview

import iui as ui

fn unescape(text string) string {
	return text.replace('&nbsp;', ' ').replace('&copy;', '©').replace('&raquo;', '»')
}

fn set_status(mut win ui.Window, text string) {
	win.extra_map['browser-status'] = text
}
