module main

import iui as ui

struct FileChooserApp {
mut:
	win     &ui.Window
	look_in string
	cp      &ui.Panel
}

fn main() {
	mut win := ui.Window.new(
		title:  'Open'
		width:  630
		height: 330
	)

	// Set Swing theme
	win.set_theme(ui.theme_ocean())

	mut pan := ui.panel(
		layout: ui.BoxLayout{
			ori: 1
		}
	)

	mut app := &FileChooserApp{
		win: win
		cp:  pan
	}

	app.make_top_panel()

	win.add_child(app.cp)
	win.gg.run()
}

fn (mut app FileChooserApp) make_top_panel() {
	mut p := ui.panel()

	p.set_bounds(0, 0, 630, 30)

	mut lbl := ui.Label.new(
		text: 'Look In:'
	)
	lbl.pack()

	p.add_child(lbl)

	mut cb := ui.select_box(
		items: [
			'Desktop',
			'Documents',
			'Downloads',
		]
		bounds: ui.Bounds{0, 0, 400, 30}
	)

	p.add_child_with_flag(cb, ui.borderlayout_center)

	app.cp.add_child(p)
}
