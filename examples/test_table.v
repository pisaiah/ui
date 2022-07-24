import gg
import iui as ui
import iui.extra.dialogs

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.get_system_theme(), 'My Window', 520, 500)

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)
	window.bar.add_child(ui.menuitem(' '))

	mut lbl := ui.label(window, 'Demo of TinyFileDialogs.c')

	// lbl.set_bounds(0, 25, 50, 30)
	lbl.pack()

	mut vbox := ui.vbox(window)

	vbox.add_child(lbl)

	mut color_btn := new_btn(window, 'Show Color Picker')

	color_btn.set_click_fn(fn [mut color_btn] (a voidptr, b voidptr, c voidptr) {
		val := dialogs.color_picker()
		color_btn.text = val
	}, 0)
	vbox.add_child(color_btn)

	mut sad := new_btn(window, 'Save As Dialog')
	sad.set_click_fn(fn (a voidptr, b voidptr, c voidptr) {
		dialogs.save_dialog('Test')
	}, 0)
	vbox.add_child(sad)

	mut pfd := new_btn(window, 'Pick Folder')
	pfd.set_click_fn(fn (a voidptr, b voidptr, c voidptr) {
		dialogs.select_folder_dialog('Test')
	}, 0)
	vbox.add_child(pfd)

	vbox.set_pos(32, 40)
	window.add_child(vbox)

	window.gg.run()
}

fn new_btn(win &ui.Window, text string) &ui.Button {
	mut btn := ui.button(win, text)
	btn.set_bounds(4, 4, 250, 30)
	btn.set_pos(4, 4)

	// btn.pack()
	return &btn
}
