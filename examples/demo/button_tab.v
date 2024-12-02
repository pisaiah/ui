module main

import iui as ui
import gx

fn (mut app App) make_button_tab() &ui.Panel {
	mut hbox := ui.Panel.new()
	hbox.set_pos(12, 12)

	mut btn := ui.Button.new(text: 'Button')

	mut btn2 := ui.Button.new(
		text: 'Round Button'
	)
	btn2.border_radius = 100

	mut sq_btn := ui.Button.new(
		text: 'Square Button'
	)
	sq_btn.border_radius = 0

	mut tbtn := ui.Button.new(
		text: 'Button'
	)
	tbtn.override_bg_color = gx.rgba(0, 0, 0, 0)
	tbtn.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		draw_custom_themed('ocean-btn', mut e)
	})

	mut sbtn := ui.Button.new(
		text: 'Button'
	)
	sbtn.override_bg_color = gx.rgba(0, 0, 0, 0)
	sbtn.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		draw_custom_themed('seven-btn', mut e)
	})

	mut btn3 := app.icon_btn(img_file.to_bytes())
	btn3.set_bounds(0, 0, 45, 32)
	btn3.icon_width = 28
	btn3.icon_height = 28

	hbox.add_child(btn)
	hbox.add_child(btn2)
	hbox.add_child(sq_btn)
	hbox.add_child(btn3)
	hbox.add_child(tbtn)
	hbox.add_child(sbtn)

	// hbox.pack()
	hbox.set_bounds(12, 12, 400, 500)

	mut p := ui.Panel.new(layout: ui.BorderLayout.new())
	p.add_child_with_flag(hbox, ui.borderlayout_center)
	p.add_child_with_flag(make_code_box('button_tab.v'), ui.borderlayout_east)
	return p
}
