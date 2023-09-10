import gg
import iui as ui
import gx

fn main() {
	// Create Window
	mut window := ui.Window.new(title: 'Counter', width: 400, height: 300)

	btn_bounds := ui.Bounds{
		x: 0
		y: 0
		width: 250
		height: 100
	}

	// Button A
	btn_a := ui.Button.new(
		text: 'Button A'
		bounds: btn_bounds
	)

	btn_b := ui.Button.new(
		text: 'Button B'
		bounds: btn_bounds
	)

	split := ui.SplitView.new(
		bounds: ui.Bounds{
			x: 8
			y: 8
			width: 250
			height: 250 + 20
		}
		first: btn_a
		second: btn_b
	)

	// Show Window
	window.add_child(split)
	window.gg.run()
}
