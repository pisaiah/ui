module main

import iui as ui

@[heap]
struct App {
mut:
	res_box &ui.TextField
}

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title:     'Calculator'
		width:     280
		height:    360
		ui_mode:   true
		font_size: 18
		theme:     ui.theme_dark()
	)

	// Setup Menubar and items
	window.bar = make_menu_bar()

	// Set content panel
	mut cp := ui.Panel.new(
		layout: ui.BoxLayout{
			ori:  1
			vgap: 5
		}
	)

	mut app := &App{
		res_box: ui.TextField.new(text: '')
	}

	app.res_box.set_bounds(5, 10, 260, 30)
	app.res_box.set_id(mut window, 'res_box')
	app.res_box.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		e.target.width = e.ctx.win.get_size().width - (e.target.x * 2)
	})
	cp.add_child(app.res_box)

	mut pp := app.button_panel()

	// cp.set_bounds(0, 35, 0, 0)
	cp.add_child(pp)
	window.add_child(cp)

	window.gg.run()
}

fn (mut app App) button_panel() &ui.Panel {
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
			mut num_btn := ui.Button.new(text: el)

			num_btn.subscribe_event('mouse_up', app.on_click_fn)

			if el == ' = ' {
				num_btn.set_accent_filled(true)
			}
			num_btn.border_radius = 4
			pp.add_child(num_btn)
		}
	}
	return pp
}

fn (mut app App) on_click_fn(mut e ui.MouseEvent) {
	mut txt := e.target.text

	if txt == ' C ' || txt == ' CE ' {
		app.res_box.text = ''
		return
	}

	if txt == ' √ ' {
		txt = 'sqrt'
	}

	if txt == 'Neg' {
		txt = '-'
	}

	if txt == ' ← ' {
		line := app.res_box.text.trim_right(' ')
		if app.res_box.carrot_left > 0 {
			app.res_box.text = line.substr(0, line.len - 1).trim_right(' ')
		}
		return
	}

	if txt == ' = ' {
		comput := compute_value(app.res_box.text).str()

		if comput.ends_with('.') {
			app.res_box.text = comput.substr(0, comput.len - 1)
		} else {
			app.res_box.text = comput
		}
		return
	}

	app.res_box.text = app.res_box.text + txt
	app.res_box.carrot_left = app.res_box.text.len
}

fn theme_click(mut win ui.Window, com ui.MenuItem) {
	mut theme := ui.theme_by_name(com.text)
	win.set_theme(theme)
}

// Setup Menubar and items
fn make_menu_bar() &ui.Menubar {
	mut bar := ui.Menubar.new()
	mut theme_menu := ui.MenuItem.new(text: 'Theme')

	mut themes := ui.get_all_themes()
	for theme2 in themes {
		mut item := ui.MenuItem.new(text: theme2.name)
		item.set_click(theme_click)
		theme_menu.add_child(item)
	}

	help_menu := ui.MenuItem.new(
		text:     'Help'
		children: [
			ui.MenuItem.new(
				text:           'About Calculator'
				click_event_fn: about_click
			),
			ui.MenuItem.new(
				text: 'About iUI'
			),
		]
	)

	bar.add_child(help_menu)
	bar.add_child(theme_menu)
	return bar
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.Modal.new(title: 'About Calculator')
	modal.in_height = 200
	modal.in_width = 240

	mut label := ui.Label.new(
		text: 'Small Calculator made in\nthe V Language.\n\nVersion: 0.1\nUI Version: ${ui.version}'
	)

	label.set_pos(15, 20)
	label.pack()

	mut can := ui.Button.new(
		text:   'OK'
		bounds: ui.Bounds{15, 150, 210, 35}
	)
	can.set_accent_filled(true)
	can.subscribe_event('mouse_up', fn (mut e ui.MouseEvent) {
		e.ctx.win.components = e.ctx.win.components.filter(mut it !is ui.Modal)
	})

	modal.needs_init = false
	modal.add_child(label)
	modal.add_child(can)
	win.add_child(modal)
}
