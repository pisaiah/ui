module main

import iui as ui

fn (mut app App) view_switch(mut e ui.MouseEvent) {
	if e.target.text == 'Details' {
		app.fp.view = .details
	}

	if e.target.text == 'Icons' {
		app.fp.view = .icons
	}

	if e.target.text == 'Tiles' {
		app.fp.view = .tiles
	}
}

fn (mut app App) theme_set(mut e ui.MouseEvent) {
	if app.win.theme.name == 'Dark' {
		app.win.set_theme(theme_default())
	} else {
		app.win.set_theme(ui.theme_dark())
	}
}

fn (mut app App) make_menus() {
	mut bar := ui.Menubar.new(
		children: [
			ui.MenuItem.new(
				text: 'File'
			),
			ui.MenuItem.new(
				text: 'Edit'
			),
			ui.MenuItem.new(
				text:     'View'
				children: [
					ui.MenuItem.new(
						text:     'Icons'
						click_fn: app.view_switch
					),
					ui.MenuItem.new(
						text:     'Details'
						click_fn: app.view_switch
					),
					ui.MenuItem.new(
						text:     'Tiles'
						click_fn: app.view_switch
					),
				]
			),
			ui.MenuItem.new(
				text: 'Favorites'
			),
			ui.MenuItem.new(
				text: 'Tools'
			),
			ui.MenuItem.new(
				text:     'Help'
				children: [
					ui.MenuItem.new(
						text:     'Switch Theme'
						click_fn: app.theme_set
					),
					ui.MenuItem.new(
						text: 'About Simple Files'
					),
					ui.MenuItem.new(
						text: 'About iUI'
					),
				]
			),
		]
	)
	app.win.bar = bar
}
