import gg
import iui as ui
import gx

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.get_system_theme(), 'Counter', 400, 300)

	btn_bounds := ui.Bounds{
		x: 0
		y: 0
		width: 200
		height: 100
	}

	// Button A
	btn_a := ui.button(
		text: 'Button A'
		click_event_fn: on_click
		bounds: btn_bounds
	)

	btn_b := ui.button(
		text: 'Button B'
		click_event_fn: on_click
		bounds: btn_bounds
	)

	split := ui.split_view(
		bounds: ui.Bounds{
			x: 50
			y: 50
			width: 200
			height: 200 + 20
		}
		first: &btn_a
		second: &btn_b
	)

	// Show Window
	window.add_child(split)
	window.gg.run()
}

// on click event function
// The Label we want to update is sent as data.
fn on_click(win &ui.Window, btn voidptr, data voidptr) {
	println('Click!')
}
