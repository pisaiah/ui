module main

import iui as ui

fn main() {
	mut win := ui.Window.new(
		title: 'BoxLayoutDemo'
		width: 450
		height: 295
	)

	// Set Swing theme
	win.set_theme(ui.theme_ocean())

	mut pan := ui.Panel.new(
		layout: ui.BoxLayout{
			ori: 1
		}
	)

	for i in 0 .. 5 {
		mut btn := ui.Button.new(
			text: 'Button ${i}'
		)
		pan.add_child(btn)
	}

	win.add_child(pan)
	win.gg.run()
}
