module main

import gg
import iui as ui
import gx

[console]
fn main() {
	// Create Window
	mut window := ui.make_window(
		theme: ui.get_system_theme()
		title: 'Calculator'
		width: 280
		height: 342
		ui_mode: true
		font_size: 16
	)

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)

	mut theme_menu := ui.menuitem('Theme')

	themes := ui.get_all_themes()
	for theme2 in themes {
		mut item := ui.menuitem(theme2.name)
		item.set_click(theme_click)
		theme_menu.add_child(item)
	}

	help_menu := ui.menu_item(
		text: 'Help'
		children: [
			ui.menu_item(
				text: 'About Calculator'
				click_event_fn: about_click
			),
			ui.menu_item(
				text: 'About iUI'
			),
		]
	)

	window.bar.add_child(help_menu)
	window.bar.add_child(theme_menu)

	mut vbox := ui.vbox(window)

	mut res_box := ui.textfield(window, '')
	res_box.set_bounds(0, 0, 64 * 4, 35)
	vbox.add_child(res_box)

	vbox.add_child(seperator(4))

	rows := [
		[' % ', ' CE ', ' C ', ' ← '],
		[' 1/x ', ' ^2 ', ' √ ', ' / '],
		['7', '8', '9', ' x '],
		['4', '5', '6', ' - '],
		['1', '2', '3', ' + '],
		['Neg', '0', '.', ' = '],
	]
	el_width := 64
	el_height := 42

	for row in rows {
		mut hbox_br := ui.hbox(window)
		hbox_br.set_bounds(0, 0, el_width * row.len, el_height)
		hbox_br.draw_event_fn = vbtn_draw
		for el in row {
			mut num_btn := ui.button(text: el)
			num_btn.set_bounds(1, 1, el_width, el_height)
			num_btn.user_data = res_box
			num_btn.draw_event_fn = btn_draw
			hbox_br.add_child(num_btn)
		}
		vbox.add_child(hbox_br)
	}

	vbox.set_bounds(5, 30, el_width * 4, el_height * rows.len)
	vbox.draw_event_fn = vbtn_draw
	window.add_child(vbox)

	window.gg.run()
}

struct Seperator {
	ui.Component_A
mut:
	size int
}

fn seperator(size int) &Seperator {
	return &Seperator{
		width: size
		height: size
		size: size
	}
}

fn (mut this Seperator) draw(ctx &ui.GraphicsContext) {
}

fn vbtn_draw(mut win ui.Window, com &ui.Component) {
	size := gg.window_size()

	mut this := *com

	this.width = size.width
	this.height = size.height
}

fn btn_draw(mut win ui.Window, com &ui.Component) {
	size := gg.window_size()
	width := size.width - 10
	height := size.height - 74

	mut this := *com
	this.width = width / 4
	this.height = height / 6

	if mut this is ui.Button {
		if this.is_mouse_rele {
			on_click_fn(unsafe { nil }, mut this, unsafe { nil })
		}
	}
}

fn on_click_fn(ptr_win voidptr, mut btn ui.Button, extra voidptr) {
	mut txt := btn.text
	mut res_box := &ui.TextField(btn.user_data)

	if txt == ' C ' || txt == ' CE ' {
		res_box.text = ''
		return
	}

	if txt == ' √ ' {
		txt = 'sqrt'
	}

	if txt == ' ← ' {
		line := res_box.text.trim_right(' ')
		if res_box.carrot_left > 0 {
			res_box.text = line.substr(0, line.len - 1).trim_right(' ')
		}
		return
	}

	if txt == ' = ' {
		comput := compute_value(res_box.text).str()

		if comput.ends_with('.') {
			res_box.text = comput.substr(0, comput.len - 1)
		} else {
			res_box.text = comput
		}
		return
	}

	res_box.text = res_box.text + txt
	res_box.carrot_left = res_box.text.len
}

fn compute_value(input string) f32 {
	ops := ['x', '+', '/', '-']
	mut has_op := false
	for op in ops {
		if input.contains(op) {
			has_op = true
			break
		}
	}
	if !has_op {
		return input.f32()
	}

	mut res := input.f32()
	if input.contains('x') {
		spl := input.split('x')
		res = spl[0].f32() * spl[1].f32()
	}
	if input.contains('+') {
		spl := input.split('+')
		res = spl[0].f32() + spl[1].f32()
	}
	if input.contains('/') {
		spl := input.split('/')
		res = spl[0].f32() / spl[1].f32()
	}
	if input.contains('-') {
		spl := input.split('-')
		res = spl[0].f32() - spl[1].f32()
	}

	return res
}

fn theme_click(mut win ui.Window, com ui.MenuItem) {
	mut theme := ui.theme_by_name(com.text)
	win.set_theme(theme)
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'About Calculator')
	modal.in_height = 210
	modal.in_width = 250
	modal.top_off = 20

	mut title := ui.label(win, 'Calculator')
	title.set_pos(20, 20)
	title.set_config(28, true, true)
	title.bold = true
	title.pack()

	mut label := ui.label(win,
		'Small Calculator made in\nthe V Programming Language.\n\nVersion: 0.1\nUI Version: ' +
		ui.version)

	label.set_pos(22, 64)
	label.pack()

	mut can := ui.button(
		text: 'OK'
		bounds: ui.Bounds{10, 170, 70, 25}
	)
	can.set_click(fn (mut win ui.Window, btn ui.Button) {
		win.components = win.components.filter(mut it !is ui.Modal)
	})
	modal.needs_init = false
	modal.add_child(can)

	modal.add_child(title)
	modal.add_child(label)

	win.add_child(modal)
}
