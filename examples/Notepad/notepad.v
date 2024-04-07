module main

// import iui.extra
import gg
import iui as ui
import os
import os.font

@[console]
fn main() {
	// Create Window
	mut window := ui.Window.new(
		title: 'Notepad'
		theme: ui.get_system_theme()
		width: 520
		height: 550
		ui_mode: true
	)

	// Setup Menubar and items
	window.bar = ui.Menubar.new()

	mut theme_menu := ui.MenuItem.new(text: 'Theme')

	themes := ui.get_all_themes()
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
				text: 'Save'
				// click_event_fn: save_as_click
			),
		]
	)

	help_menu := ui.MenuItem.new(
		text: 'Help'
		children: [
			ui.MenuItem.new(
				text: 'About Notepad'
				click_event_fn: about_click
			),
			ui.MenuItem.new(
				text: 'About iUI'
			),
		]
	)

	font_menu := ui.MenuItem.new(
		text: 'Font'
		children: [
			font_type_item('OS Default'),
			font_type_item('scientifica.ttf'),
			font_type_item('VeraMono.ttf'),
			font_type_item('JetBrainsMono-Regular.ttf'),
			font_type_item('AnomalyMono-Regular.otf'),
			font_type_item('System arial.ttf'),
			font_type_item('System segoeui.ttf'),
			font_type_item('System seguiemj.ttf'),
			ui.menu_item(
				text: 'More...'
				// click_event_fn: font_picker
			),
		]
	)

	size_menu := ui.MenuItem.new(
		text: 'Size'
		children: [
			font_size_item('12'),
			font_size_item('14'),
			font_size_item('16'),
			font_size_item('18'),
			font_size_item('24'),
			font_size_item('42'),
		]
	)

	window.bar.add_child(file_menu)
	window.bar.add_child(help_menu)
	window.bar.add_child(theme_menu)
	window.bar.add_child(font_menu)
	window.bar.add_child(size_menu)

	mut res_box := ui.Textbox.new(lines: ['hello'])
	res_box.set_bounds(1, 1, 100, 100)

	mut sv := ui.scroll_view(
		view: res_box
		padding: 0
	)
	sv.noborder = true

	res_box.subscribe_event('after_draw', fn (mut e ui.DrawEvent) {
		size := gg.window_size()

		e.target.width = size.width - 3

		hei := size.height - 31
		if e.target.height < hei {
			e.target.height = hei
		}
	})

	window.add_child(sv)

	window.gg.run()
}

fn font_size_item(size string) &ui.MenuItem {
	return ui.MenuItem.new(text: size, click_event_fn: on_size_click)
}

fn font_type_item(size string) &ui.MenuItem {
	return ui.MenuItem.new(text: size, click_event_fn: font_click)
}

fn font_click(mut win ui.Window, com ui.MenuItem) {
	mut path := os.resource_abs_path(com.text.replace(' ', '-'))
	txt := com.text

	if txt == 'OS Default' {
		println(font.default())
		path = font.default()
	}
	if txt.starts_with('System ') {
		path = 'C:/windows/fonts/' + com.text.split('System ')[1].to_lower()
	}

	//new_font := win.add_font(txt, path)
	// win.graphics_context.font = new_font
	win.set_font(path)
}

fn on_size_click(mut win ui.Window, com ui.MenuItem) {
	win.font_size = com.text.int()
}

fn theme_click(mut win ui.Window, com ui.MenuItem) {
	text := com.text
	theme := ui.theme_by_name(text)
	win.set_theme(theme)
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.Page.new(title: 'About Notepad')

	mut title := ui.Label.new(text: 'Notepad')
	title.set_config(28, true, true)
	title.pack()

	mut label := ui.Label.new(
		text: 'Small Notepad made in the V Programming Language.\n\nVersion: 0.1' +
			'\nUI Version: ${ui.version}'
	)

	label.pack()

	mut p := ui.Panel.new(layout: ui.BoxLayout.new(ori: 1))
	p.set_pos(24, 18)
	p.add_child(title)
	p.add_child(label)

	modal.add_child(p)

	win.add_child(modal)
}

/*
fn save_as_click(mut win ui.Window, com ui.MenuItem) {
	dir := if 'save_path' in win.extra_map {
		win.extra_map['save_path']
	} else {
		os.real_path(os.home_dir())
	}

	path_change_fn := file_picker_path_change

	picker_conf := extra.FilePickerConfig{
		in_modal: true
		path: dir
		path_change_fn: path_change_fn
	}

	mut modal := extra.open_file_picker(mut win, picker_conf, win)
	modal.z_index = 500
}

fn file_picker_path_change(a voidptr, b voidptr) {
	println('FILE PICKED')

	picker := &extra.FilePicker(a)
	mut win := &ui.Window(b)
	mut text_box := &ui.TextArea(win.get_from_id('notepad'))
	path := picker.get_full_path()
	dump(text_box.lines)
	win.extra_map['save_path'] = path
	os.write_file(path, text_box.lines.join('\n')) or {}
}

fn font_picker_path_change(a voidptr, b voidptr) {
	picker := &extra.FilePicker(a)
	mut win := &ui.Window(b)
	path := picker.get_full_path()

	font := win.add_font(picker.get_file_name(), path)
	win.graphics_context.font = font
}
*/
