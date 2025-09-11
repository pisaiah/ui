module main

import iui as ui
import gx

fn (mut app App) make_button_tab() &ui.Panel {
	mut btn2 := ui.Button.new(
		text: 'Round Button'
	)
	btn2.border_radius = 100

	mut sq_btn := ui.Button.new(
		text: 'Square Button'
	)
	sq_btn.border_radius = 0

	mut sbtn := ui.Button.new(
		text: 'Button'
	)
	sbtn.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		draw_custom_themed('ocean-btn', mut e)
	})

	mut btn3 := app.icon_btn(img_file.to_bytes())
	btn3.set_bounds(0, 0, 45, 30)
	btn3.icon_width = 28
	btn3.icon_height = 28

	// Button with SVG Icon (see svg_tab.v)
	mut svg_btn := make_svg_button()

	// Create our inner Panel
	mut p := ui.Panel.new(
		children: [
			ui.Button.new(
				text:     'Button'
				on_click: on_btn_click
			),
			btn2,
			sq_btn,
			btn3,
			ui.Button.new(
				text:     'Filled Button'
				on_click: on_btn_click
				accent:   true
				width:    100
				height:   30
			),
			sbtn,
			svg_btn,
		]
	)

	// Create our outer Panel
	mut cp := ui.Panel.new(layout: ui.BorderLayout.new())
	cp.add_child(p, value: ui.borderlayout_center)
	cp.add_child(make_code_box('button_tab.v'), value: ui.borderlayout_east)
	return cp
}

// Button mouse event function
fn on_btn_click(mut e ui.MouseEvent) {
	// For our Demo add/remove "!" from Button text
	mut b := e.target
	if b.text.contains('!') {
		b.text = b.text.replace('!', '')
	} else {
		b.text = b.text + '!'
	}
}
