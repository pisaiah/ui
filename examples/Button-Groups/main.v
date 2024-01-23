module main

import iui as ui

@[heap]
struct App {
mut:
	res_label &ui.Label
}

@[console]
fn main() {
	// Create Window
	mut window := ui.Window.new(
		title: 'My Window'
		width: 520
		height: 400
		theme: ui.theme_default()
	)

	mut app := &App{
		res_label: unsafe { nil }
	}

	mut panel := ui.Panel.new()

	choices := ['A', 'B', 'C']

	mut group := ui.ButtonGroup.new[ui.Checkbox]()
	for choice in choices {
		mut box := ui.Checkbox.new(
			text: choice
		)

		box.set_bounds(0, 0, 70, 30)

		box.subscribe_event('draw', fn (mut e ui.DrawEvent) {
			e.target.height = e.ctx.line_height
		})

		group.add(box)
		panel.add_child(box)
	}
	group.setup()
	group.subscribe_event('mouse_up', app.group_clicked)

	panel.set_bounds(50, 30, 300, 0)

	mut lbl := ui.Label.new(text: 'You selected: ')
	app.res_label = lbl
	lbl.set_bounds(50, 80, 100, 30)

	window.add_child(panel)
	window.add_child(lbl)

	// Start GG / Show Window
	window.run()
}

fn (mut app App) group_clicked(mut e ui.MouseEvent) {
	app.res_label.text = 'You selected: ' + e.target.text
}
