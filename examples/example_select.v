module main

import iui as ui

fn main() {
	mut win := ui.Window.new(
		title:  'Button Demo'
		width:  520
		height: 400
	)

	mut hbox := ui.VBox.new()

	// Set bounds for the button; If `bounds` is not
	// set, then the button will pack to the text size.
	mut sel := ui.select_box(
		text:  'Pick value'
		items: [
			'Apple',
			'Orange',
			'Pear',
		]
	)
	sel.set_bounds(0, 0, 150, 30)

	mut btn := ui.button(
		text:   'Hello world'
		bounds: ui.Bounds{99, 4, 99, 20}
	)

	// btn.set_area_filled(false)
	sel.z_index = 4

	hbox.add_child(sel)
	hbox.add_child(btn)
	hbox.set_pos(20, 20)
	hbox.pack()

	win.add_child(hbox)

	win.run()
}

// Invoked when the user clicks the button
fn right_button_clicked(mut e ui.MouseEvent) {
	e.target.text = 'Clicked'
}
