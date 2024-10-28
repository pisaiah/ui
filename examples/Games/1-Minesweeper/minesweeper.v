module main

import iui as ui
import gx
import rand

const text_colors = [gx.blue, gx.rgb(0, 128, 0), gx.red, gx.rgb(0, 0, 128),
	gx.rgb(128, 0, 0), gx.rgb(0, 128, 128), gx.black, gx.gray]

const dark_gray = gx.rgb(192, 192, 192)

// Top border Panel
fn top_panel() &ui.Panel {
	mut p := ui.Panel.new()
	p.set_bounds(0, 0, 100, 55)
	p.set_background(gx.rgb(192, 192, 192))

	return p
}

// Side border Panel
fn (app &App) side_panel() &ui.Panel {
	mut p := ui.Panel.new()
	s := app.btn_size / 2
	p.set_bounds(0, 0, s, s)
	p.set_background(gx.rgb(192, 192, 192))

	return p
}

@[heap]
struct App {
mut:
	win      &ui.Window
	btn_size int
	gp       &ui.Panel
	bombs    int
}

fn main() {
	btn_size := 28
	width := btn_size * 9

	win_width := width + 2

	mut win := ui.Window.new(
		title:     'Minesweeper'
		width:     win_width
		font_size: 14
		height:    width + 54 + 27
	)

	mut gp := ui.Panel.new(
		layout: ui.GridLayout.new(
			rows: 9
			vgap: 0
			hgap: 0
		)
	)

	mut app := &App{
		win:      win
		btn_size: btn_size
		gp:       gp
	}

	app.make_menu_bar()

	for yy in 0 .. 9 {
		for xx in 0 .. 9 {
			mut btn := ui.Button.new()

			btn.set_bounds(0, 0, btn_size, btn_size)

			btn.id = '${yy},${xx}'
			btn.subscribe_event('mouse_up', app.square_click)
			btn.subscribe_event('after_draw', app.button_draw_fn)

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

			randi := rand.intn(12) or { -1 }
			if randi == 0 {
				btn.text = '   '
				app.bombs += 1
			}
		}
	}
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
			btn.text = 'B'
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
		btn.text = '${around}'
		btn.icon = -1
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

// Draw button icon
fn (mut app App) button_draw_fn(mut e ui.DrawEvent) {
	mut btn := e.target
	x2 := btn.x + 2

	if btn.text.len == 0 || btn.text.len == 3 {
		// Draw untouched square
		e.ctx.gg.draw_rect_filled(btn.x, btn.y, btn.width, btn.height, gx.white)
		e.ctx.gg.draw_rect_filled(x2, btn.y + 2, btn.width - 2, btn.height - 2, gx.gray)
		e.ctx.gg.draw_rect_filled(x2, btn.y + 2, btn.width - 4, btn.height - 4, dark_gray)
		return
	}

	val := btn.text.int()

	if btn.text == '0' || val > 0 {
		// Draw Empty background
		e.ctx.gg.draw_rect_filled(btn.x, btn.y, btn.width, btn.height, gx.gray)
		e.ctx.gg.draw_rect_filled(x2, btn.y + 2, btn.width - 2, btn.height - 2, dark_gray)
	}

	if val < 1 {
		return
	}

	size := e.ctx.text_width(btn.text)
	sizh := e.ctx.line_height

	// Draw Colored Number
	e.ctx.draw_text((btn.x + (btn.width / 2)) - size, btn.y + (btn.height / 2) - sizh,
		btn.text, e.ctx.font, gx.TextCfg{
		size:  e.ctx.win.font_size * 2
		color: text_colors[btn.text.int() - 1]
		bold:  true
	})
}
