module main

import iui as ui

fn main() {
	mut win := ui.window(
		title:  'Button Demo'
		width:  520
		height: 400
	)

	mut p := ui.Panel.new()

	// Set bounds for the button; If `bounds` is not
	// set, then the button will pack to the text size.
	button_bounds := ui.Bounds{0, 0, 150, 30}

	mut left_button := ui.Button.new(
		text: 'Left Button'
	)

	mut mid_button := ui.Button.new(
		text: 'Middle Button'
	)

	mut right_button := ui.Button.new(
		text:   'Right Button'
		bounds: button_bounds
	)

	right_button.subscribe_event('mouse_up', right_button_clicked)

	p.add_child(left_button)
	p.add_child(mid_button)
	p.add_child(right_button)

	win.add_child(p)

	win.run()
}

// Invoked when the user clicks the button
fn right_button_clicked(mut e ui.MouseEvent) {
	e.target.text = 'Clicked'
}
