module main

import iui as ui
import gx
import rand

[heap]
struct App {
	win &ui.Window
mut:
	sq     int = -1
	turn   bool
	winner string
	comput bool = false
	// TODO: improve computer ai
}

fn main() {
	mut win := ui.Window.new(
		width: 640
		height: 480
		title: '(Tic Tac Toe)^2'
	)

	mut app := &App{
		win: win
	}

	win.bar = app.setup_menus()

	mut p := ui.Panel.new(
		layout: ui.BorderLayout.new()
	)

	mut b := app.make_board()
	p.add_child_with_flag(b, ui.borderlayout_center)

	win.add_child(p)

	win.gg.run()
}

struct Board {
	ui.Component_A
mut:
	x int
}

fn (mut app App) make_board() &ui.Panel {
	mut b := ui.Panel.new(
		layout: ui.GridLayout.new(
			rows: 3
		)
	)

	for aa in 0 .. 3 {
		for bb in 0 .. 3 {
			mut p := ui.Panel.new(
				layout: ui.GridLayout.new(
					rows: 3
				)
			)

			for i in 0 .. 9 {
				mut btn := ui.Button.new(text: '')
				av := (aa * 3) + bb
				btn.id = '${av},${i}'
				btn.subscribe_event('mouse_up', app.mup)
				p.add_child(btn)
			}

			b.add_child(p)
		}
	}
	b.subscribe_event('draw', app.main_draw)
	return b
}

fn find_win(p &ui.Component) ?string {
	if p.children.len < 9 {
		return none
	}

	// Horizontal
	for i in 0 .. 3 {
		r := i * 3
		mut a := p.children[r]
		mut b := p.children[r + 1]
		mut c := p.children[r + 2]

		if a.text.len > 0 {
			if a.text == b.text && b.text == c.text {
				return a.text
			}
		}
	}

	// Verticle
	for i in 0 .. 3 {
		mut a := p.children[i]
		mut b := p.children[i + 3]
		mut c := p.children[i + 6]

		if a.text.len > 0 {
			if a.text == b.text && b.text == c.text {
				return a.text
			}
		}
	}

	d := find(p, 2, 4, 6) or { find(p, 0, 4, 8) or { return none } }

	return d
}

fn find(p &ui.Component, i int, j int, k int) ?string {
	a := p.children[i]
	b := p.children[j]
	c := p.children[k]

	if a.text.len > 0 {
		if a.text == b.text && b.text == c.text {
			return a.text
		}
	}
	return none
}

fn (mut app App) main_draw(mut e ui.DrawEvent) {
	if app.sq != -1 {
		sq := e.target.children[app.sq]
		if sq.id.starts_with('WIN') {
			app.sq = -1
			return
		}
		c := e.ctx.theme.button_bg_click
		e.ctx.gg.draw_rect_filled(sq.rx, sq.ry, sq.width, sq.height, c)
	}

	if app.comput && app.turn {
		if app.sq != -1 {
			mut sq := e.target.children[app.sq]

			randi := rand.intn(9) or { -1 }

			mut kid := sq.children[randi]

			app.mup_(mut kid)
		}
	}

	winner := find_win(e.target) or { return }

	if app.winner.len > 0 {
		return
	}

	app.winner = winner

	modal := win_modal(winner)
	app.win.add_child(modal)
}

fn (mut app App) mup(mut e ui.MouseEvent) {
	app.mup_(mut e.target)
}

fn (mut app App) mup_(mut target ui.Component) {
	if target.text.len > 0 {
		return
	}

	id := target.id.split(',')
	ida := id[0].int()
	idb := id[1].int()

	if app.sq != -1 && app.sq != ida {
		return
	}

	txt := if app.turn { 'O' } else { 'X' }

	target.text = txt

	app.sq = idb

	app.turn = !app.turn

	don := find_win(target.parent) or { return }

	mut p := target.parent
	for mut kd in p.children {
		kd.text = don
	}
	p.subscribe_event('after_draw', draw_win)
}

fn draw_win(mut e ui.DrawEvent) {
	txt := e.target.children[0].text

	mut p := e.target

	cfg := gx.TextCfg{
		size: e.target.height
	}

	e.ctx.set_cfg(cfg)

	tw := e.ctx.text_width(txt)
	x := p.x + (p.width / 2) - tw / 2
	e.ctx.draw_text(x, p.y, txt, 0, cfg)

	e.ctx.set_cfg(gx.TextCfg{
		size: e.ctx.font_size
	})

	p.text = txt
	p.id = 'WIN=${txt}'
}
