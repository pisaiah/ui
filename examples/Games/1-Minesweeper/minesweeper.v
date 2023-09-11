module main

import iui as ui
import gx
import rand
import gg

[heap]
struct App {
mut:
	win      &ui.Window
	icons    []int
	btn_size int
	gp       &ui.Panel
	bombs    int
}

fn (mut app App) setup_icons() {
	img_0_file := $embed_file('assets/empty.png')
	app.icons << icon(app.win, img_0_file.to_bytes())

	img_1_file := $embed_file('assets/1.png')
	app.icons << icon(app.win, img_1_file.to_bytes())

	img_2_file := $embed_file('assets/2.png')
	app.icons << icon(app.win, img_2_file.to_bytes())

	img_3_file := $embed_file('assets/3.png')
	app.icons << icon(app.win, img_3_file.to_bytes())

	img_4_file := $embed_file('assets/4.png')
	app.icons << icon(app.win, img_4_file.to_bytes())

	img_5_file := $embed_file('assets/5.png')
	app.icons << icon(app.win, img_5_file.to_bytes())

	img_6_file := $embed_file('assets/6.png')
	app.icons << icon(app.win, img_6_file.to_bytes())

	img_7_file := $embed_file('assets/7.png')
	app.icons << icon(app.win, img_7_file.to_bytes())

	img_8_file := $embed_file('assets/8.png')
	app.icons << icon(app.win, img_8_file.to_bytes())

	img_mine_file := $embed_file('assets/mine.png')
	app.icons << icon(app.win, img_mine_file.to_bytes())

	img_blank_file := $embed_file('assets/blank.png')
	app.icons << icon(app.win, img_blank_file.to_bytes())
}

fn main() {
	btn_size := 28
	width := btn_size * 9

	win_width := width + 2

	mut win := ui.Window.new(
		theme: ui.theme_default()
		title: 'Minesweeper'
		width: win_width
		font_size: 14
		height: width + 54 + 27
	)

	mut gp := ui.Panel.new(
		layout: ui.GridLayout.new(
			rows: 9
			vgap: 0
			hgap: 0
		)
	)

	mut app := &App{
		win: win
		btn_size: btn_size
		gp: gp
	}

	app.setup_icons()
	app.make_menu_bar()

	for yy in 0 .. 9 {
		for xx in 0 .. 9 {
			mut btn := ui.Button.new(
				icon: app.icons[10]
			)

			btn.set_bounds(0, 0, btn_size, btn_size)

			btn.id = '${yy},${xx}'
			btn.subscribe_event('mouse_up', app.square_click)

			gp.add_child(btn)
		}
	}

	mut p := ui.Panel.new(
		layout: ui.BorderLayout.new(
			hgap: 0
			vgap: 0
		)
	)

	p.add_child_with_flag(gp, ui.borderlayout_center)

	p.add_child_with_flag(top_panel(), ui.borderlayout_north)
	p.add_child_with_flag(app.side_panel(), ui.borderlayout_west)
	p.add_child_with_flag(app.side_panel(), ui.borderlayout_east)

	sp := app.side_panel()
	p.add_child_with_flag(sp, ui.borderlayout_south)

	win.add_child(p)
	win.gg.run()
}

fn (mut app App) reset_mines() {
	app.bombs = 0
	for mut btn in app.gp.children {
		if mut btn is ui.Button {
			btn.text = ''
			btn.icon = app.icons[10]

			randi := rand.intn(12) or { -1 }
			if randi == 0 {
				btn.text = '   '
				app.bombs += 1
			}
		}
	}
}

fn icon(win &ui.Window, data []u8) int {
	mut ggg := win.gg
	gg_im := ggg.create_image_from_byte_array(data) or { return -1 }
	cim := ggg.cache_image(gg_im)

	return cim
}

fn (mut app App) square_click(mut e ui.MouseEvent) {
	app.square_click_(mut e.target)
}

fn (mut app App) square_click_(mut target ui.Component) {
	app.check_win()
	if target.text == '  ' {
		return
	}

	mut btn := target
	if target.text == '   ' {
		if mut btn is ui.Button {
			ico := app.icons[9]
			btn.icon = ico
			btn.set_background(gx.red)
			modal := game_over()
			app.win.add_child(modal)
		}
		return
	} else {
		btn.text = '0'
	}

	id := target.id.split(',')
	yy := id[0].int()
	xx := id[1].int()

	idx := (9 * yy) + xx

	mut p := target.parent
	mut possibles := []int{}
	mut around := 0

	possibles << idx - 9 // Above
	possibles << idx + 9 // Below

	if xx > 0 {
		possibles << idx - 1 // Left
		possibles << idx + 8 // Below-left
		possibles << idx - 10 // Above-left
	}

	if xx < 8 {
		possibles << idx + 1 // Right
		possibles << idx - 8 // Below-right
		possibles << idx + 10 // Above-right
	}

	if app.bombs == 0 {
		app.reset_mines()
	}

	// Count around mines
	for i in possibles {
		com := p.children[i] or { continue }
		if com.text == '   ' {
			around += 1
		}
	}

	if around == 0 {
		btn.text = '  '

		for i in possibles {
			mut com := p.children[i] or { continue }
			if com.text == ' ' || com.text.len == 0 {
				app.square_click_(mut com)
			}
		}
	} else {
		btn.text = around.str()
	}

	if mut btn is ui.Button {
		btn.icon = app.icons[around]
	}
	app.check_win()
}

fn (mut app App) check_win() bool {
	for mut btn in app.gp.children {
		if mut btn is ui.Button {
			if btn.text.len == 0 {
				return false
			}
		}
	}

	mut m := win_modal()
	app.win.add_child(m)
	return true
}
