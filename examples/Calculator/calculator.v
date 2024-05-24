module main

import iui as ui
import gx

fn main() {
	// Create Window
	mut window := ui.Window.new(
		theme: theme_dark()
		title: 'Calculator'
		width: 280
		height: 360
		ui_mode: true
		font_size: 18
	)

	// Setup Menubar and items
	window.bar = make_menu_bar()

	// Set content panel
	mut cp := ui.panel(
		layout: ui.BoxLayout{
			ori: 1
		}
	)

	mut res_box := ui.text_field(text: '')
	res_box.set_bounds(5, 1, 260, 40)
	res_box.set_id(mut window, 'res_box')
	cp.add_child(res_box)

	mut pp := button_panel()

	cp.set_bounds(5, 35, 0, 0)
	cp.add_child(pp)
	window.add_child(cp)

	window.gg.run()
}

fn button_panel() &ui.Panel {
	rows := [
		[' % ', ' CE ', ' C ', ' ← '],
		[' 1/x ', ' ^2 ', ' √ ', ' / '],
		['7', '8', '9', ' x '],
		['4', '5', '6', ' - '],
		['1', '2', '3', ' + '],
		['Neg', '0', '.', ' = '],
	]

	mut pp := ui.panel(
		layout: ui.GridLayout{
			cols: 4
		}
	)

	pp.set_bounds(0, 10, 260, 250)
	pp.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		ws := e.ctx.gg.window_size()
		e.target.width = ws.width - (e.target.x * 2)
		e.target.height = ws.height - e.target.y - 5
	})

	for row in rows {
		for el in row {
			mut num_btn := ui.button(text: el)

			num_btn.subscribe_event('mouse_up', fn [mut num_btn] (mut e ui.MouseEvent) {
				on_click_fn(num_btn, e.ctx.win)
			})

			if el == ' = ' {
				num_btn.set_background(gx.rgb(30, 75, 145))
			}
			num_btn.border_radius = 4
			pp.add_child(num_btn)
		}
	}
	return pp
}

fn on_click_fn(btn &ui.Button, win &ui.Window) {
	mut txt := btn.text
	mut res_box := win.get[&ui.TextField]('res_box')

	if txt == ' C ' || txt == ' CE ' {
		res_box.text = ''
		return
	}

	if txt == ' √ ' {
		txt = 'sqrt'
	}

	if txt == 'Neg' {
		txt = '-'
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

fn theme_click(mut win ui.Window, com ui.MenuItem) {
	if com.text == 'CalcDark' {
		win.set_theme(theme_dark())
		return
	}
	mut theme := ui.theme_by_name(com.text)
	win.set_theme(theme)
}

// Setup Menubar and items
fn make_menu_bar() &ui.Menubar {
	mut bar := ui.menu_bar()
	mut theme_menu := ui.menu_item(text: 'Theme')

	mut themes := ui.get_all_themes()
	themes.insert(0, theme_dark())
	for theme2 in themes {
		mut item := ui.menu_item(text: theme2.name)
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

	bar.add_child(help_menu)
	bar.add_child(theme_menu)
	return bar
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'About Calculator')
	modal.in_height = 200
	modal.in_width = 240

	mut label := ui.Label.new(
		text: 'Small Calculator made in\nthe V Language.\n\nVersion: 0.1\nUI Version: ${ui.version}'
	)

	label.set_pos(15, 20)
	label.pack()

	mut can := ui.button(
		text: 'OK'
		bounds: ui.Bounds{15, 150, 210, 35}
	)
	can.subscribe_event('mouse_up', fn (mut e ui.MouseEvent) {
		e.ctx.win.components = e.ctx.win.components.filter(mut it !is ui.Modal)
	})

	modal.needs_init = false
	modal.add_child(label)
	modal.add_child(can)
	win.add_child(modal)
}

// Custom Dark Theme that memics Windows Calc colors
pub fn theme_dark() &ui.Theme {
	return &ui.Theme{
		name: 'CalcDark'
		text_color: gx.rgb(230, 230, 230)
		background: gx.rgb(30, 30, 30)
		button_bg_normal: gx.rgb(57, 57, 57)
		button_bg_hover: gx.rgb(75, 75, 75)
		button_bg_click: gx.rgb(30, 30, 30)
		button_border_normal: gx.rgb(38, 38, 38)
		button_border_hover: gx.rgb(0, 140, 250)
		button_border_click: gx.rgb(0, 84, 153)
		menubar_background: gx.rgb(10, 10, 10)
		menubar_border: gx.rgb(30, 30, 30)
		dropdown_background: gx.rgb(10, 10, 10)
		dropdown_border: gx.rgb(0, 0, 0)
		textbox_background: gx.rgb(50, 50, 50)
		textbox_border: gx.rgb(40, 40, 40)
		checkbox_selected: gx.rgb(99, 99, 40)
		checkbox_bg: gx.rgb(0, 0, 0)
		progressbar_fill: gx.rgb(130, 130, 130)
		scroll_track_color: gx.rgb(0, 0, 0)
		scroll_bar_color: gx.rgb(170, 170, 170)
	}
}
