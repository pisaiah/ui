module main

import iui as ui

fn (mut app App) setup_menus() &ui.Menubar {
	mut bar := ui.Menubar.new()

	mut help := ui.MenuItem.new(
		text: 'Help'
		children: [
			ui.MenuItem.new(
				text: 'How to Play'
				click_fn: app.about_rules
			),
			ui.MenuItem.new(
				text: 'About (TicTacToe)^2'
				click_fn: app.about_game
			),
			ui.MenuItem.new(
				text: 'About iUI'
			),
		]
	)
	bar.add_child(help)

	return bar
}

// About modal
fn (mut app App) about_game(mut e ui.MouseEvent) {
	mut modal := ui.Modal.new(title: 'About (Tic-Tac-Toe)^2')
	modal.in_height = 250
	modal.in_width = 260
	modal.top_off = 20

	mut label := ui.Label.new(
		text: 'Ultimate Tic-Tac-Toe game.\nMade in the V Language.\n\nVersion: 0.1, UI: ${ui.version}\n© 2023 Isaiah.\n'
	)
	label.pack()

	mut p := ui.Panel.new(
		layout: ui.BoxLayout.new(ori: 1)
	)
	p.set_pos(15, 10)
	p.add_child(label)
	modal.add_child(p)

	app.win.add_child(modal)
}

// Rules modal
fn (mut app App) about_rules(mut e ui.MouseEvent) {
	mut modal := ui.Modal.new(title: 'Rules')
	modal.in_height = 250
	modal.in_width = 360
	modal.top_off = 20

	mut p := ui.Panel.new(
		layout: ui.BoxLayout.new(
			ori: 1
			vgap: 0
			hgap: 0
		)
	)
	p.set_pos(10, 10)

	lines := [
		'The game starts with X playing in any empty spot.',
		'Next the opponent plays, however they have to play',
		'in the small board indicated by the last move. For',
		'example, if X plays in the top right square of a small',
		'(3×3) board, then O has to play in the small board',
		'located top right of large board. The chosen spot',
		'decides in which small board the next player plays.',
	]

	for s in lines {
		mut label := ui.Label.new(
			text: s
		)
		label.pack()
		p.add_child(label)
	}

	modal.add_child(p)

	app.win.add_child(modal)
}

// Win modal
fn win_modal(s string) &ui.Modal {
	mut modal := ui.Modal.new(title: '${s} WINS')
	modal.in_height = 160
	modal.in_width = 160
	modal.top_off = 20

	mut title := ui.Label.new(text: '${s} WINS')
	title.set_pos(15, 12)
	title.set_config(34, true, true)
	title.pack()

	modal.add_child(title)

	return modal
}
