import gg
import iui as ui
import gx

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.get_system_theme(), 'Counter', 300, 99)

	// Create an HBox
	mut hbox := ui.hbox(window)
	hbox.set_pos(24, 24)

	// Create the Label
	mut lbl := ui.label(window, '0')
	lbl.pack()

	// Create Count Button
	btn := ui.button(
		text: 'Count'
		click_event_fn: on_click
		should_pack: true
		user_data: &lbl
	)

	// Add to HBox
	hbox.add_child(lbl)
	hbox.add_child(btn)
	hbox.draw_event_fn = fn (mut win ui.Window, com &ui.Component) {
		println('draw')
		win.gg.draw_rect_empty(com.x, com.y, com.width, com.height, gx.rgb(255, 0, 255))
	}
	hbox.pack()

	// Show Window
	window.add_child(hbox)
	window.gg.run()
}

// on click event function
// The Label we want to update is sent as data.
fn on_click(win &ui.Window, btn voidptr, data voidptr) {
	mut lbl := &ui.Label(data)
	current_value := lbl.text.int()
	lbl.text = (current_value + 1).str()
	lbl.pack()
}
