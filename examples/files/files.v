module main

import gg
import iui as ui
import os
import iui.extra

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.get_system_theme(), 'File Picker Test', 550, 510)

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)

	mut theme_menu := ui.menuitem('Theme')

	mut themes := ui.get_all_themes()
	for theme2 in themes {
		item := ui.menu_item(
			text: theme2.name
			click_event_fn: theme_click
		)

		theme_menu.add_child(item)
	}

	file_menu := ui.menu_item(
		text: 'File'
		children: [
			ui.menu_item(
				text: 'New'
				click_event_fn: modal_test
			),
		]
	)

	help_menu := ui.menu_item(
		text: 'Help'
		children: [
			ui.menu_item(
				text: 'About vFiles'
				click_event_fn: about_click
			),
			ui.menu_item(
				text: 'About iUI'
			),
		]
	)

	window.bar.add_child(file_menu)
	window.bar.add_child(help_menu)
	window.bar.add_child(theme_menu)

	mut v_img := window.gg.create_image(os.resource_abs_path('folder.png'))
	window.id_map['img_folder'] = &v_img

	mut v_img2 := window.gg.create_image(os.resource_abs_path('blankfile.png'))
	window.id_map['img_blank'] = &v_img2

	window.gg.run()
}

fn theme_click(mut win ui.Window, com ui.MenuItem) {
	text := com.text
	theme := ui.theme_by_name(text)
	win.set_theme(theme)
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'About')
	modal.in_height = 210
	modal.in_width = 250

	mut title := ui.label(win, 'About')
	title.set_pos(20, 4)
	title.set_config(28, true, true)
	title.pack()

	mut label := ui.label(win, 'Test of the File Picker\nUI Version: ' + ui.version)

	label.set_pos(22, 14)
	label.pack()

	mut can := ui.button(win, 'OK')
	can.set_bounds(10, 170, 70, 25)
	can.set_click(fn (mut win ui.Window, btn ui.Button) {
		win.components = win.components.filter(mut it !is ui.Modal)
	})
	modal.needs_init = false
	modal.add_child(can)

	modal.add_child(title)
	modal.add_child(label)

	win.add_child(modal)
}

fn modal_test(mut win ui.Window, com ui.MenuItem) {
	extra.open_file_picker(mut win, extra.FilePickerConfig{true, 'D:/gc.dll', fn (a voidptr, b voidptr) {
		picker := &extra.FilePicker(a)
		println(picker.get_full_path())
	}}, voidptr(0))
}
