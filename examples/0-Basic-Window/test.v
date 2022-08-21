module main

import iui as ui

[console]
fn main() {
	// Create Window
	mut window := ui.make_window(
		title: 'My Window'
		width: 520
		height: 400
		theme: ui.theme_default()
	)

	// Start GG / Show Window
	window.run()
}
