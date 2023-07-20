module main

import iui as ui

fn main() {
	mut win := ui.Window.new(
		title: 'BorderLayoutDemo'
		width: 450
		height: 295
	)

	// Set Swing theme
	win.set_theme(ui.theme_ocean())

	mut pan := ui.panel(
		layout: ui.BorderLayout{}
	)

	make_button(mut pan, '1 (NORTH)', ui.borderlayout_north)

	// make_button(mut pan, '2 (WEST)', ui.borderlayout_west)
	make_button(mut pan, '3 (EAST)', ui.borderlayout_east)

	// make_button(mut pan, '4 (SOUTH)', ui.borderlayout_south)
	make_button(mut pan, '5 (CENTER)', ui.borderlayout_center)

	win.add_child(pan)
	win.gg.run()
}

fn make_button(mut pan ui.Panel, id string, constrain int) &ui.Button {
	mut btn := ui.button(
		text: 'Button ${id}'
	)
	btn.set_bounds(0, 0, 150, 50)
	pan.add_child_with_flag(btn, constrain)
	return btn
}
