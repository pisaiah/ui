module main

import iui as ui

fn (mut app App) make_menu_bar() {
	mut bar := ui.Menubar.new()

	gi := ui.MenuItem.new(
		text:     'Game'
		children: [
			ui.MenuItem.new(
				text:           'New Game'
				click_event_fn: app.me_click
			),
		]
	)

	help := ui.MenuItem.new(
		text:     'Help'
		children: [
			ui.MenuItem.new(
				text:           'About vMines'
				click_event_fn: app.about_calc
			),
			ui.MenuItem.new(
				text: 'About iUI'
			),
		]
	)

	bar.add_child(gi)
	bar.add_child(help)
	app.win.bar = bar
}

fn (mut app App) me_click(mut win ui.Window, com ui.MenuItem) {
	app.reset_mines()
}

fn (mut app App) about_calc(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.Modal.new(title: 'About Mines')
	modal.in_height = 210
	modal.in_width = 0
	modal.top_off = 20

	mut title := ui.Label.new(text: 'Mines')
	title.pack()

	mut label := ui.Label.new(
		text: 'Minesweeper-clone made in\nthe V Programming Language.\n\nVersion: 0.1, UI: ${ui.version}'
	)

	label.pack()

	mut p := ui.Panel.new(
		layout: ui.BoxLayout.new(ori: 1)
	)
	p.set_pos(9, 0)

	p.add_child(title)
	p.add_child(label)
	modal.add_child(p)

	modal.pack()

	app.win.add_child(modal)
}

// Game over modal
fn game_over() &ui.Modal {
	mut modal := ui.Modal.new(title: 'You Lost')
	modal.in_height = 155
	modal.in_width = 140
	modal.top_off = 20

	mut title := ui.Label.new(text: 'GAME\nOVER')
	title.set_pos(20, 12)
	title.set_config(34, true, true)
	title.pack()

	modal.add_child(title)

	return modal
}

// Win modal
fn win_modal() &ui.Modal {
	mut modal := ui.Modal.new(title: 'You WIN!')
	modal.in_height = 155
	modal.in_width = 160
	modal.top_off = 20

	mut title := ui.Label.new(text: 'You Win!')
	title.set_pos(15, 12)
	title.set_config(34, true, true)
	title.pack()

	modal.add_child(title)

	return modal
}
