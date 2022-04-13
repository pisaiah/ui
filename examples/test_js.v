import gg
import iui as ui { debug }
import time
import os

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.get_system_theme(), 'My Window', 520, 500)

	// Setup Menubar and items
	// window.bar = voidptr(0)
	/*
	mut btn := ui.button(window, 'A Button')
	btn.set_click(btn_click)
	btn.set_bounds(30, 40, 100, 25)
	btn.set_click(on_click)

	window.add_child(btn)

	mut btn2 := ui.button(window, 'This is a Button')
	btn2.set_pos(30, 70)
	btn2.pack() // Auto set width & height

	window.add_child(btn2)*/

	mut cbox := ui.checkbox(window, 'Check me!')
	cbox.set_bounds(170, 40, 90, 25)

	window.add_child(cbox)

	// mut code_box := ui.textarea(window, ['module main', '', 'fn main() {', '\tmut val := 0', '}'])
	// code_box.set_bounds(30, 270, 320, 120)

	// window.add_child(code_box)
	window.gg.run()
}

fn on_click(mut win ui.Window, com ui.Button) {
	debug('on_click')
}

fn btn_click(mut win ui.Window, com ui.Button) {
	debug('btn click')
}
