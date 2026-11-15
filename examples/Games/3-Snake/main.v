module main

import iui as ui
import gg
import rand
import time

@[heap]
struct App {
mut:
	win   &ui.Window
	dir   gg.KeyCode
	by    int = 16
	score int
	btns  []&Square
	apple &ui.Button
	head  &Square = unsafe { nil }

	// Speed timing variables
	last_tick    i64
	last_frame   i64
	tick_rate_ms i64 = 60
}

fn main() {
	mut window := ui.Window.new(
		title:  'Snake'
		width:  520
		height: 400
		theme:  ui.theme_default()
	)

	mut apple := ui.Button.new(text: 'A')
	apple.set_background(gg.red)
	apple.set_bounds(64, 64, 16, 16)

	mut h := &Square{}
	h.main = true
	h.z_index = 10
	h.set_bounds(16, 16, 16, 16)
	h.target_x = 16
	h.target_y = 16

	mut app := &App{
		win:        window
		apple:      apple
		head:       h
		last_tick:  time.now().unix_milli()
		last_frame: time.now().unix_milli()
	}

	window.subscribe_event('key_down', app.key_down)
	h.subscribe_event('draw', app.game_loop)

	window.gg.set_bg_color(gg.green)
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
	h.target_x = x
	h.target_y = y
	h.prev_x = x
	h.prev_y = y
	app.win.add_child(h)
	app.btns << h
}

fn grid(v int) int {
	return (v / 16) * 16
}

fn abs(v int) int {
	if v < 0 { return -v }
	return v
}

fn (mut app App) game_loop(mut e ui.DrawEvent) {
	e.ctx.draw_text(0, 0, 'Score: ${app.score}', e.ctx.font)

	now := time.now().unix_milli()
	elapsed_since_tick := now - app.last_tick

	if elapsed_since_tick >= app.tick_rate_ms {
		app.last_tick = now

		app.head.prev_x = app.head.target_x
		app.head.prev_y = app.head.target_y

		for mut btn in app.btns {
			btn.prev_x = btn.target_x
			btn.prev_y = btn.target_y
		}

		// Apple detection
		mx := app.head.target_x + 8
		my := app.head.target_y + 8
		mx_apple := app.apple.x + 8
		my_apple := app.apple.y + 8

		mut ate_apple := false
		if abs(mx - mx_apple) <= 9 && abs(my - my_apple) <= 9 {
			app.score += 1
			app.place_apple(e.ctx)
			ate_apple = true
		}

		m := 16
		if app.dir == .left {
			app.head.target_x = app.head.prev_x - m
			app.head.target_y = grid(app.head.prev_y)
		}
		if app.dir == .right {
			app.head.target_x = app.head.prev_x + m
			app.head.target_y = grid(app.head.prev_y)
		}
		if app.dir == .up {
			app.head.target_y = app.head.prev_y - m
			app.head.target_x = grid(app.head.prev_x)
		}
		if app.dir == .down {
			app.head.target_y = app.head.prev_y + m
			app.head.target_x = grid(app.head.prev_x)
		}

		// Window wrap boundary checks
		ws := e.ctx.gg.window_size()
		if app.head.target_y <= -m {
			app.head.target_y = ws.height - m
			app.head.prev_y = ws.height
		}
		if app.head.target_x <= -m {
			app.head.target_x = ws.width - m
			app.head.prev_x = ws.width
		}
		if app.head.target_y >= ws.height {
			app.head.target_y = 0
			app.head.prev_y = -m
		}
		if app.head.target_x >= ws.width {
			app.head.target_x = 0
			app.head.prev_x = -m
		}

		if app.btns.len > 0 {
			for i := app.btns.len - 1; i > 0; i-- {
				app.btns[i].target_x = app.btns[i - 1].target_x
				app.btns[i].target_y = app.btns[i - 1].target_y
			}
			app.btns[0].target_x = app.head.prev_x
			app.btns[0].target_y = app.head.prev_y
		}

		if ate_apple {
			growth_x := if app.btns.len > 0 {
				app.btns[app.btns.len - 1].prev_x
			} else {
				app.head.prev_x
			}
			growth_y := if app.btns.len > 0 {
				app.btns[app.btns.len - 1].prev_y
			} else {
				app.head.prev_y
			}
			app.add_btn(growth_x, growth_y)
		}
	}

	mut t := f32(now - app.last_tick) / f32(app.tick_rate_ms)
	if t > 1.0 {
		t = 1.0
	}

	app.head.x = int(f32(app.head.prev_x) + t * f32(app.head.target_x - app.head.prev_x))
	app.head.y = int(f32(app.head.prev_y) + t * f32(app.head.target_y - app.head.prev_y))

	for mut btn in app.btns {
		btn.x = int(f32(btn.prev_x) + t * f32(btn.target_x - btn.prev_x))
		btn.y = int(f32(btn.prev_y) + t * f32(btn.target_y - btn.prev_y))
	}
}

fn (mut app App) key_down(mut e ui.WindowKeyEvent) {
	if e.key in [.left, .right, .up, .down] {
		if e.key == .left && app.dir == .right { return }
		if e.key == .right && app.dir == .left { return }
		if e.key == .up && app.dir == .down { return }
		if e.key == .down && app.dir == .up { return }
		app.dir = e.key
	}
}

struct Square {
	ui.Component_A
mut:
	main     bool
	prev_x   int
	prev_y   int
	target_x int
	target_y int
}

fn (mut this Square) draw(ctx &ui.GraphicsContext) {
	color := if this.main { gg.rgb(0, 110, 0) } else { gg.rgb(0, 160, 0) }
	ctx.gg.draw_rect_filled(this.x, this.y, this.width, this.height, color)
}
