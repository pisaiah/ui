module main

import iui as ui

struct App {
mut:
	p &ui.Panel
}

fn main() {
	mut win := ui.Window.new(
		title:  'BorderLayoutDemo'
		width:  450
		height: 295
	)

	mut pan := ui.Panel.new(layout: ui.BorderLayout.new())

	mut app := &App{
		p: pan
	}

	app.make_button('1 (NORTH)', ui.borderlayout_north)
	app.make_button('2 (WEST)', ui.borderlayout_west)
	app.make_button('3 (EAST)', ui.borderlayout_east)
	app.make_button('4 (SOUTH)', ui.borderlayout_south)
	app.make_button('5 (CENTER)', ui.borderlayout_center)

	win.add_child(pan)
	win.gg.run()
}

fn (mut app App) make_button(id string, constrain int) &ui.Button {
	mut btn := ui.Button.new(
		text: 'Button ${id}'
	)
	app.p.add_child_with_flag(btn, constrain)
	return btn
}
