module main

import iui as ui

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title: 'My Window'
		width: 520
		height: 400
		theme: ui.theme_default()
	)

	mut dp := ui.DesktopPane.new()

	mut f1 := ui.InternalFrame.new()
	mut f2 := ui.InternalFrame.new()
	mut f3 := ui.InternalFrame.new()

	dp.add_child(f1)
	dp.add_child(f2)
	dp.add_child(f3)

	for i, mut kid in dp.children {
		kid.set_x(i * 30)
		kid.set_y(i * 30)
		kid.z_index = i
	}

	mut p := ui.Panel.new(
		layout: ui.BorderLayout.new()
	)

	p.add_child_with_flag(dp, ui.borderlayout_center)

	window.add_child(p)

	// Start GG / Show Window
	window.run()
}
