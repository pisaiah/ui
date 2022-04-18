module main

import gg
import iui as ui { debug }
import time
import gx

[console]
fn main() {
	// Create Window
	mut window := ui.window_with_config(ui.get_system_theme(), 'Calculator', 270, 325,
		&ui.WindowConfig{
		ui_mode: false
	})

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)

	mut theme_menu := ui.menuitem('Theme')

	mut themes := [ui.get_system_theme(), theme_dark(), ui.theme_black_red()]
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
	// res_box.padding_y = 10
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
			mut num_btn := ui.button(window, el)
			num_btn.set_bounds(0, 0, el_width, el_height)
			// num_btn.set_click_fn(on_click_fn, res_box)
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

fn (mut this Seperator) draw() {
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
			on_click_fn(voidptr(0), this, this.user_data)
		}
	}
}

fn on_click_fn(ptr_win voidptr, ptr_btn voidptr, extra voidptr) {
	mut btn := &ui.Button(ptr_btn)
	mut res_box := &ui.TextField(extra)

	mut txt := btn.text

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

fn on_click(mut win ui.Window, com ui.Button) {
	debug('on_click')
}

fn theme_click(mut win ui.Window, com ui.MenuItem) {
	text := com.text

	mut theme := ui.theme_by_name(text)
	if text == 'Dark' {
		theme = theme_dark()
	}

	win.set_theme(theme)
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'About Calculator')
	modal.in_height = 210
	modal.in_width = 250
	modal.top_off = 20

	mut title := ui.label(win, 'Calculator')
	title.set_pos(20, 4)
	title.set_config(28, true, true)
	title.bold = true
	title.pack()

	mut label := ui.label(win,
		'Small Calculator made in\nthe V Programming Language.\n\nVersion: 0.1\nUI Version: ' +
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

//
//    Slightly better colors
//  for a Calculator.
//
pub fn theme_dark() ui.Theme {
	return ui.Theme{
		name: 'Dark'
		text_color: gx.rgb(245, 245, 245)
		background: gx.rgb(0, 0, 0)
		button_bg_normal: gx.rgb(10, 10, 10)
		button_bg_hover: gx.rgb(70, 70, 70)
		button_bg_click: gx.rgb(50, 50, 50)
		button_border_normal: gx.rgb(72, 72, 72)
		button_border_hover: gx.rgb(0, 120, 215)
		button_border_click: gx.rgb(0, 84, 153)
		menubar_background: gx.rgb(30, 30, 30)
		menubar_border: gx.rgb(30, 30, 30)
		dropdown_background: gx.rgb(10, 10, 10)
		dropdown_border: gx.rgb(0, 0, 0)
		textbox_background: gx.rgb(10, 10, 10)
		textbox_border: gx.rgb(130, 130, 130)
		checkbox_selected: gx.rgb(130, 130, 130)
		checkbox_bg: gx.rgb(5, 5, 5)
		progressbar_fill: gx.rgb(130, 130, 130)
		scroll_track_color: gx.rgb(0, 0, 0)
		scroll_bar_color: gx.rgb(180, 180, 180)
	}
}
