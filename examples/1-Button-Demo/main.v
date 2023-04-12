module main

import iui as ui

fn main() {
	mut win := ui.make_window(
		title: 'Button Demo'
		width: 520
		height: 400
	)

	mut hbox := ui.hbox(win)

	// Set bounds for the button; If `bounds` is not
	// set, then the button will pack to the text size.
	button_bounds := ui.Bounds{5, 5, 100, 30}

	mut left_button := ui.button(
		text: 'Left Button'
		bounds: button_bounds
	)

	mut mid_button := ui.button(
		text: 'Middle Button'
		bounds: button_bounds
	)

	mut right_button := ui.button(
		text: 'Right Button'
		bounds: button_bounds
	)

	right_button.subscribe_event('mouse_up', right_button_clicked)

	hbox.add_child(left_button)
	hbox.add_child(mid_button)
	hbox.add_child(right_button)

	hbox.pack()

	win.add_child(hbox)

	win.run()
}

// Invoked when the user clicks the button
fn right_button_clicked(mut e ui.MouseEvent) {
	e.target.text = 'Clicked'
}
