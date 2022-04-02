module main

import gg
import iui as ui
import os

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.get_system_theme(), 'Files', 550, 510)

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
	mut modal := ui.modal(win, 'About vFiles')
	modal.in_height = 210
	modal.in_width = 250

	mut title := ui.label(win, 'vFiles')
	title.set_pos(20, 4)
	title.set_config(28, true, true)
	title.pack()

	mut label := ui.label(win,
		'Small File Picker made in\nthe V Programming Language.\n\nVersion: 0.1' +
		'\nUI Version: ' + ui.version)

	label.set_pos(22, 14)
	label.pack()

	mut can := ui.button(win, 'OK')
	can.set_bounds(10, 170, 70, 25)
	can.set_click(fn (mut win ui.Window, btn ui.Button) {
		open_file_picker(mut win, 'D:/')
		win.components = win.components.filter(mut it !is ui.Modal)
	})
	modal.needs_init = false
	modal.add_child(can)

	modal.add_child(title)
	modal.add_child(label)

	win.add_child(modal)
}

fn modal_test(mut win ui.Window, com ui.MenuItem) {
	open_file_picker(mut win, 'D:/')
}

struct FilePickerModalData {
	picker &FilePicker
	modal  &ui.Modal
}

fn open_file_picker(mut win ui.Window, dir string) {
	mut modal := ui.modal(win, 'Choose Folder & File')
	modal.top_off = 20
	modal.in_width = 500
	modal.in_height = 450

	modal.draw_event_fn = fn (mut win ui.Window, com &ui.Component) {
		mut vbox := &ui.VBox(win.get_from_id('edit'))
		vbox.scroll_i = com.scroll_i
	}

	mut picker := create_file_picker(mut win, true, dir)
	modal.add_child(picker.dir_input)
	modal.add_child(picker.file_list)
	modal.add_child(picker.file_name)

	mut can := ui.button(win, 'OK')
	can.set_bounds(10, 410, 70, 25)
	can.set_click_fn(fn (a voidptr, b voidptr, c voidptr) {
		mut win := &ui.Window(a)
		data := &FilePickerModalData(c)
		modal := data.modal

		win.components = win.components.filter(mut it !is ui.Modal)
	}, &FilePickerModalData{picker, modal})
	modal.needs_init = false
	modal.add_child(can)

	load_directory(dir, picker.file_list)
	win.add_child(modal)
}
