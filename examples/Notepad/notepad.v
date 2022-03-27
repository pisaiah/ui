module main

import gg
import iui as ui { debug }
import os

[console]
fn main() {
	// Create Window
	mut window := ui.window_with_config(ui.get_system_theme(), 'Notepad', 464, 500, &ui.WindowConfig{
        font_path: os.resource_abs_path('scientifica.ttf')
    })

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)

	mut help := ui.menuitem('Help')
	mut theme_menu := ui.menuitem('Theme')
	mut about := ui.menuitem('About Notepad')

	mut themes := [ui.get_system_theme(), ui.theme_dark(), ui.theme_black_red()]
	for theme2 in themes {
		mut item := ui.menuitem(theme2.name)
		item.set_click(theme_click)
		theme_menu.add_child(item)
	}

	mut file := ui.menuitem('File')
	mut save := ui.menuitem('Save')
	save.set_click(save_as_click)
	file.add_child(save)
	window.bar.add_child(file)

	about.set_click(about_click)
	help.add_child(about)
	help.add_child(ui.menuitem('About iUI'))
	window.bar.add_child(help)
	window.bar.add_child(theme_menu)

	mut res_box := ui.textedit(window, '')
	res_box.set_id(mut window, 'edit')
	res_box.set_bounds(4, 28, 0, 0)
	res_box.draw_event_fn = vbtn_draw
	window.add_child(res_box)

	window.gg.run()
}

fn vbtn_draw(mut win ui.Window, com &ui.Component) {
	size := gg.window_size()

	mut this := *com

	this.width = size.width - 8
	this.height = size.height - 31
}

fn on_click(mut win ui.Window, com ui.Button) {
	debug('on_click')
}

fn theme_click(mut win ui.Window, com ui.MenuItem) {
	text := com.text
	theme := ui.theme_by_name(text)
	win.set_theme(theme)
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'About Notepad')
	modal.in_height = 210
	modal.in_width = 250
	modal.top_off = 20

	mut title := ui.label(win, 'Notepad')
	title.set_pos(20, 4)
	title.set_config(28, true, true)
	title.pack()

	mut label := ui.label(win,
		'Small Notepad made in\nthe V Programming Language.\n\nVersion: 0.1' + '\nUI Version: ' +
		ui.version)

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

fn save_as_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'Save As')
	modal.in_width -= 40

	mut l1 := ui.label(win, 'File path:')
	l1.pack()
	l1.set_pos(30, 70)
	modal.add_child(l1)

	mut path := ui.textbox(win, '')
	path.set_bounds(140, 70, 300, 25)
	path.multiline = false

	if 'save_path' in win.extra_map {
		path.text = win.extra_map['save_path']
	}
	modal.add_child(path)

	mut l2 := ui.label(win, 'Save as type: ')
	l2.pack()
	l2.set_pos(30, 100)
	modal.add_child(l2)

	mut typeb := ui.selector(win, 'Text (*.txt)')
	typeb.items << 'Text (*.txt)'
	typeb.set_bounds(140, 100, 200, 25)
	modal.add_child(typeb)

	modal.needs_init = false

	mut save := ui.button(win, 'Save')
	save.set_bounds(150, 250, 100, 25)
	save.set_click_fn(fn (win_ptr voidptr, btn_ptr voidptr, extra_ptr voidptr) {
		mut win := &ui.Window(win_ptr)
		mut path := &ui.Textbox(extra_ptr)
		mut text_box := &ui.TextEdit(win.get_from_id('edit'))

		win.extra_map['save_path'] = path.text
		os.write_file(path.text, text_box.lines.join('\n')) or {}

		win.components = win.components.filter(mut it !is ui.Modal)
	}, path)
	modal.add_child(save)

	win.add_child(modal)
}
