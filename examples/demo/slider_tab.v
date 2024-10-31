module main

import iui as ui
import rand
import gx

fn (mut app App) make_slider_tab() &ui.Panel {
	mut p := ui.Panel.new(layout: ui.BorderLayout.new())
	mut cp := ui.Panel.new()

	// Slider #1
	mut slid := ui.Slider.new(
		min: 0
		max: 100
		dir: .vert
	)
	slid.pack()

	mut lbl := ui.Label.new(text: '#1 value: 0')
	lbl.pack()
	slid.subscribe_event('value_change', fn [mut lbl] (mut e ui.FloatValueChangeEvent) {
		lbl.text = '#1 value: ${e.value}'
		lbl.pack()
	})

	// Slider #2
	mut slid2 := ui.Slider.new(
		min: 0
		max: 100
		dir: .hor
	)
	slid2.pack()

	mut lbl2 := ui.Label.new(text: '#2 value: 0')
	lbl2.pack()
	slid2.subscribe_event('value_change', fn [mut lbl2] (mut e ui.FloatValueChangeEvent) {
		lbl2.text = '#2 value: ${e.value}'
		lbl2.pack()
	})

	cp.add_child(slid)
	cp.add_child(slid2)

	mut btn1 := ui.Button.new(text: '#1: Switch direction')
	btn1.subscribe_event('mouse_up', fn [mut slid] (mut e ui.MouseEvent) {
		slid.switch_dir()
	})

	mut btn2 := ui.Button.new(text: '#2: Switch direction')
	btn2.subscribe_event('mouse_up', fn [mut slid2] (mut e ui.MouseEvent) {
		slid2.switch_dir()
	})

	mut btn3 := ui.Button.new(text: 'Change thumb color')
	btn3.subscribe_event('mouse_up', fn [mut slid2] (mut e ui.MouseEvent) {
		color := gx.rgb(rand.u8(), rand.u8(), rand.u8())
		slid2.set_custom_thumb_color(color)
	})

	mut btn4 := ui.Button.new(text: 'thumb_width++')
	btn4.subscribe_event('mouse_up', fn [mut slid2] (mut e ui.MouseEvent) {
		slid2.thumb_wid += 1
	})

	mut btn5 := ui.Button.new(text: 'thumb_width--')
	btn5.subscribe_event('mouse_up', fn [mut slid2] (mut e ui.MouseEvent) {
		slid2.thumb_wid -= 1
	})

	mut pb1 := ui.Progressbar.new()
	mut pb2 := ui.Progressbar.new()

	pb1.set_bounds(0, 0, 100, 25)
	pb2.set_bounds(0, 0, 100, 25)

	pb1.bind_to(&slid.cur)
	pb2.bind_to(&slid2.cur)

	mut bp := ui.Panel.new(layout: ui.BoxLayout.new(vgap: 0))

	bp.add_child(btn1)
	bp.add_child(btn2)
	bp.add_child(btn3)
	bp.add_child(btn4)
	bp.add_child(btn5)

	mut north := ui.Panel.new()
	north.add_child(pb1)
	north.add_child(pb2)

	cp.add_child(lbl)
	cp.add_child(lbl2)

	p.add_child_with_flag(north, ui.borderlayout_north)
	p.add_child_with_flag(cp, ui.borderlayout_center)
	p.add_child_with_flag(bp, ui.borderlayout_south)
	p.add_child_with_flag(make_slider_tab_code(), ui.borderlayout_east)

	return p
}

fn make_slider_tab_code() &ui.Panel {
	mut p := ui.Panel.new()

	lines := "// Basic Slider
mut slid := ui.Slider.new(
	min: 0
	max: 100
	dir: .hor // or .vert
	scroll: true // Mouse scroll
)
slid.pack()
slid.subscribe_event('value_change', event_fn)

fn event_fn(mut e ui.FloatValueChangeEvent) {
	// on change stuff here
}

mut pb := ui.Progressbar.new() // example.
pb.bind_to(&slid.cur) // Able to bind value".split('\n')

	mut box := ui.Textbox.new(
		lines: lines
	)

	box.set_bounds(0, 0, 250, 200)
	box.not_editable = true
	box.no_line_numbers = true

	p.add_child(box)

	return p
}
