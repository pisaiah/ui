module main

import iui as ui
import gg
import gx

struct App {
mut:
	txt string
}

[console]
fn main() {
	// Create Window
	mut window := ui.make_window(
		title: 'My Window'
		width: 520
		height: 400
		theme: ui.theme_dark()
	)

	mut lbl := ui.label(window, 'TEST')

	mut stra := 'AA'
	mut app := &App{
		txt: &stra
	}

	lbl.draw_event_fn = fn (win &ui.Window, mut com ui.Component) {
		e := &gg.Event(win.id_map['cggevent'])
		com.text = e.str() //.split('touches')[0]
		if mut com is ui.Label {
			com.pack()
		}

		win.gg.draw_rect_empty(win.mouse_x, win.mouse_y, 32, 32, gx.blue)
	}

	lbl.set_bounds(16, 16, 300, 300)

	mut vbox := ui.vbox(window)

	mut sv := ui.scroll_view(
		view: vbox
	)

	mut btn := ui.button(window, 'TEST')
	btn.set_bounds(16, 16, 300, 60)
	// btn.pack()

	vbox.add_child(btn)
	vbox.add_child(lbl)

	vbox.pack()

	sv.set_bounds(0, 0, 400, 400)
	window.add_child(sv)

	// Start GG / Show Window
	window.run()
}
