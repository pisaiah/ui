module main

import iui as ui
import rand
import gx

fn (mut app App) make_slider_tab() &ui.Panel {
	// mut p := ui.Panel.new(layout: ui.BorderLayout.new())

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

	mut pb1 := ui.Progressbar.new()
	mut pb2 := ui.Progressbar.new()

	pb1.set_bounds(0, 0, 100, 25)
	pb2.set_bounds(0, 0, 100, 25)

	pb1.bind_to(&slid.cur)
	pb2.bind_to(&slid2.cur)

	// Our bottom Button Panel
	mut bp := ui.Panel.new(
		layout:   ui.BoxLayout.new(vgap: 0)
		children: [
			ui.Button.new(
				text:     '#1: Switch direction'
				on_click: fn [mut slid] (mut e ui.MouseEvent) {
					slid.switch_dir()
				}
			),
			ui.Button.new(
				text:     '#2: Switch direction'
				on_click: fn [mut slid2] (mut e ui.MouseEvent) {
					slid2.switch_dir()
				}
			),
			ui.Button.new(
				text:     'Change thumb color'
				on_click: fn [mut slid2] (mut e ui.MouseEvent) {
					color := gx.rgb(rand.u8(), rand.u8(), rand.u8())
					slid2.set_custom_thumb_color(color)
				}
			),
			ui.Button.new(
				text:     'thumb_width++'
				on_click: fn [mut slid2] (mut e ui.MouseEvent) {
					slid2.thumb_wid += 1
				}
			),
			ui.Button.new(
				text:     'thumb_width--'
				on_click: fn [mut slid2] (mut e ui.MouseEvent) {
					slid2.thumb_wid -= 1
				}
			),
		]
	)

	mut p := ui.Panel.new(
		layout:   ui.BorderLayout.new()
		children: [
			ui.Panel.new(
				children: [slid, slid2, lbl, lbl2]
			),
			ui.Panel.new(
				children: [pb1, pb2]
			),
			bp,
			make_slider_tab_code(),
		]
	)

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
