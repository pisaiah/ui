module main

import iui as ui
import gx
import gg
import rand
import time

@[heap]
struct App {
mut:
	win &ui.Window
	dir gg.KeyCode
	// left, right, up, down
	by        int = 16
	hx        int
	hy        int
	score     int
	count     int
	btns      []&Square
	apple     &ui.Button
	last_tick i64
}

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title: 'Snake'
		width: 520
		height: 400
		theme: ui.theme_default()
	)

	mut apple := ui.Button.new(text: 'A')
	apple.set_background(gx.red)

	apple.set_bounds(64, 64, 16, 16)

	mut app := &App{
		win: window
		apple: apple
	}
	window.key_down_event = app.key_down

	window.gg.set_bg_color(gx.green)

	mut h := ui.Button.new(text: 'S')

	h.z_index = 10
	h.set_background(gx.rgb(0, 150, 0))
	h.set_bounds(16, 16, app.by, app.by)
	h.subscribe_event('draw', app.h_draw)
	window.add_child(h)
	window.add_child(apple)

	window.run()
}

fn (mut app App) place_apple(ctx &ui.GraphicsContext) {
	ws := ctx.gg.window_size()

	x := rand.intn(ws.width - 16) or { 0 }
	y := rand.intn(ws.height - 16) or { 0 }

	grx := (x / 16) * 16
	gry := (y / 16) * 16

	app.apple.set_bounds(grx, gry, 16, 16)
}

fn (mut app App) add_btn(x int, y int) {
	mut h := &Square{}
	h.set_bounds(x, y, app.by, app.by)
	app.win.add_child(h)
	app.btns << h
}

fn grid(v int) int {
	return (v / 16) * 16
}

fn abs(v int) int {
	if v < 0 {
		return -v
	}
	return v
}

fn (mut app App) h_draw(mut e ui.DrawEvent) {
	e.ctx.draw_text(0, 0, '${app.score}', 0)

	now := time.now().unix_time_milli()
	if now - app.last_tick < 50 {
		return
	}

	app.last_tick = now

	x := e.target.x
	y := e.target.y

	mx := x + 8
	my := y + 8

	mx_apple := app.apple.x + 8
	my_apple := app.apple.y + 8

	if abs(mx - mx_apple) <= 9 && abs(my - my_apple) <= 9 {
		// dump('hit apple')
		app.score += 1
		app.place_apple(e.ctx)
	}

	app.hx = x
	app.hy = y

	m := 16 // app.by // / 2
	if app.dir == .left {
		e.target.x = x - m
		e.target.y = grid(y)
	}
	if app.dir == .right {
		e.target.x = x + m
		e.target.y = grid(y)
	}
	if app.dir == .up {
		e.target.y = y - m
		e.target.x = grid(x)
	}
	if app.dir == .down {
		e.target.y = y + m
		e.target.x = grid(x)
	}

	ws := e.ctx.gg.window_size()
	if e.target.y <= -m {
		e.target.y = ws.height + m
		return
	}
	if e.target.x <= -m {
		e.target.x = ws.width + m
		return
	}

	if e.target.y >= ws.height + m {
		e.target.y = 0
	}
	if e.target.x >= ws.width + m {
		e.target.x = 0
	}

	if app.count == app.score {
		if app.score > 0 {
			mut lx := x
			mut ly := y
			for ii in -(app.btns.len - 1) .. 1 {
				mut btn := app.btns[-ii]
				llx := btn.x
				lly := btn.y

				// btn.x = grid(lx)
				// btn.y = grid(ly)
				btn.pos(lx, ly)

				ly = lly
				lx = llx
			}
		}
	} else {
		app.add_btn(grid(x), grid(y))
		app.count += 1
	}
}

fn (mut app App) key_down(mut win ui.Window, key gg.KeyCode, e &gg.Event) {
	if key in [.left, .right, .up, .down] {
		app.dir = key
	}
	if key == .space {
		app.score += 10
	}
}

// test
struct Square {
	ui.Component_A
mut:
	lx int
	ly int
}

fn (mut this Square) pos(x int, y int) {
	this.lx = x
	this.ly = y
	this.x = grid(x)
	this.y = grid(y)
}

fn (mut this Square) draw(ctx &ui.GraphicsContext) {
	dx := (this.x - this.lx)
	dy := (this.y - this.ly)

	if dx != 0 {
		// this.lx = dx
		// dump(dx)
	}

	ctx.gg.draw_rect_filled(this.x - dx, this.y - dy, this.width, this.height, gx.rgb(0,
		100, 0))
}
