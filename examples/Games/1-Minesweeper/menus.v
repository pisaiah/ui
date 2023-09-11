module main

import iui as ui

fn (mut app App) make_menu_bar() {
	app.win.bar = ui.Menubar.new()

	gi := ui.MenuItem.new(
		text: 'Game'
		children: [
			ui.MenuItem.new(
				text: 'New Game'
				click_fn: app.me_click
			),
		]
	)
	app.win.bar.add_child(gi)

	mut about_calc := ui.MenuItem.new(
		text: 'About vMines'
	)
	about_calc.subscribe_event('mouse_up', app.about_calc)

	mut help := ui.MenuItem.new(
		text: 'Help'
		children: [
			about_calc,
			ui.MenuItem.new(
				text: 'About iUI'
			),
		]
	)
	app.win.bar.add_child(help)
}

fn (mut app App) me_click(mut e ui.MouseEvent) {
	app.reset_mines()
}

// About modal
fn (mut app App) about_calc(mut e ui.MouseEvent) {
	mut modal := ui.Modal.new(title: 'About Mines')
	modal.in_height = 210
	modal.in_width = 220
	modal.top_off = 20

	mut title := ui.Label.new(text: 'Mines')
	title.set_config(28, true, true)
	title.bold = true
	title.pack()

	mut label := ui.Label.new(
		text: 'Minesweeper-clone made in\nthe V Programming Language.\n\nVersion: 0.1, UI: ${ui.version},\n\nBy Isaiah.'
	)

	label.pack()

	mut p := ui.Panel.new(
		layout: ui.BoxLayout.new(ori: 1)
	)
	p.set_pos(5, 0)

	p.add_child(title)
	p.add_child(label)
	modal.add_child(p)

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
