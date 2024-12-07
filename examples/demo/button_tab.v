module main

import iui as ui
import gx

fn (mut app App) make_button_tab() &ui.Panel {
	mut hbox := ui.Panel.new()

	mut btn := ui.Button.new(text: 'Button')

	mut btn2 := ui.Button.new(
		text: 'Round Button'
	)
	btn2.border_radius = 100

	mut sq_btn := ui.Button.new(
		text: 'Square Button'
	)
	sq_btn.border_radius = 0

	mut filled_btn := ui.Button.new(
		text: 'Filled Button'
	)

	filled_btn.set_bounds(0, 0, 100, 30)
	filled_btn.is_action = true

	mut sbtn := ui.Button.new(
		text: 'Button'
	)
	sbtn.override_bg_color = gx.rgba(0, 0, 0, 0)
	sbtn.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		draw_custom_themed('ocean-btn', mut e)
	})

	mut btn3 := app.icon_btn(img_file.to_bytes())
	btn3.set_bounds(0, 0, 45, 30)
	btn3.icon_width = 28
	btn3.icon_height = 28

	hbox.add_child(btn)
	hbox.add_child(btn2)
	hbox.add_child(sq_btn)
	hbox.add_child(btn3)
	hbox.add_child(filled_btn)
	hbox.add_child(sbtn)

	// hbox.pack()
	// hbox.set_bounds(0, 0, 400, 500)

	mut p := ui.Panel.new(layout: ui.BorderLayout.new())
	p.add_child(hbox, value: ui.borderlayout_center)
	p.add_child(make_code_box('button_tab.v'), value: ui.borderlayout_east)
	return p
}
