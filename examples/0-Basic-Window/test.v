module main

import iui as ui

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title: 'My Window'
		width: 520
		height: 400
		theme: ui.theme_default()
	)

	// Start GG / Show Window
	window.run()
}
