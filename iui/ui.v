// Copyright (c) 2021-2022 Isaiah.
// All Rights Reserved.
module iui

import gg
import gx
import time
import math

pub const (
	version = '0.0.1'
	ui_mode = true
	font_size = 15
)

pub fn debug(o string) {
	$if debug ? {
		println('(Debug) ' + o)
	}
}

// Component Interface

[heap]
pub interface Component {
mut:
	text string
	x int
	y int
	width int
	height int
	last_click f64
	is_selected bool
	carrot_index int
	z_index int
	scroll_i int
	is_mouse_down bool
	is_mouse_rele bool
	draw_event_fn fn (mut Window, &Component)
	draw()
}

[heap]
pub struct Component_A {
pub mut:
	text          string
	x             int
	y             int
	width         int
	height        int
	last_click    f64
	is_selected   bool
	carrot_index  int
	z_index       int
	scroll_i      int
	is_mouse_down bool
	is_mouse_rele bool
	draw_event_fn fn (mut Window, &Component) = fn (mut win Window, tree &Component) {}
}

pub fn (mut com Component_A) draw() {
	// Stub
}

pub fn point_in(mut com Component, px int, py int) bool {
	midx := com.x + (com.width / 2)
	midy := com.y + (com.height / 2)

	return (math.abs(midx - px) < (com.width / 2)) && (math.abs(midy - py) < (com.height / 2))
}

pub fn draw_with_offset(mut com Component, offx int, offy int) {
	ox := com.x
	oy := com.y

	com.x = com.x + offx
	com.y = com.y + offy
	com.draw()
	com.x = ox
	com.y = oy
}

pub fn (mut com Component_A) set_bounds(x int, y int, width int, height int) {
	set_bounds(mut com, x, y, width, height)
}

pub fn (mut com Component_A) set_pos(x int, y int) {
	com.x = x
	com.y = y
}

pub fn set_pos(mut com Component, x int, y int) {
	com.x = x
	com.y = y
}

pub fn set_size(mut com Component, width int, height int) {
	com.width = width
	com.height = height
}

pub fn set_bounds(mut com Component, x int, y int, width int, height int) {
	set_pos(mut com, x, y)
	set_size(mut com, width, height)
}

// Window
[heap]
struct Window {
pub mut:
	gg            &gg.Context
	mouse_x       int
	mouse_y       int
	click_x       int
	click_y       int
	lastt         f64
	fps           int
	fpss          int
	theme         Theme
	bar           &Menubar
	components    []Component
	show_menu_bar bool = true
	shift_pressed bool

	modal_show  bool
	modal_title string
	modal_text  string

	last_update i64
	frame_time  int
	has_event   bool = true
}

pub fn (mut win Window) add_child(com Component) {
	win.components << com
}

pub fn window(theme Theme, title string, width int, height int) &Window {
	mut app := &Window{
		gg: 0
		theme: theme
		bar: 0
	}
	// go app.idle_draw()
	mut font_path := gg.system_font_path()
	app.gg = gg.new_context(
		bg_color: app.theme.background
		width: width
		height: height
		create_window: true
		window_title: title
		frame_fn: frame
		event_fn: on_event
		user_data: app
		font_path: font_path
		font_size: font_size
		ui_mode: iui.ui_mode
	)
	return app
}

// Update at 1FPS during idle, (for text cursor blinking)
pub fn (mut win Window) idle_draw() {
	for {
		now := time.now().unix_time_milli()
		if now - win.last_update > 1000 {
			win.gg.refresh_ui()
			win.last_update = now
			println(now)
		}
		time.sleep(1000 * time.millisecond)
	}
}

pub fn (mut win Window) set_theme(theme Theme) {
	win.theme = theme
	win.gg.set_bg_color(theme.background)
}

fn frame(mut app Window) {
	app.gg.begin()
	app.draw()
	app.gg.end()
}

fn (app &Window) display() {
}

fn (app &Window) draw_bordered_rect(x int, y int, width int, height int, a int, bg gx.Color, bord gx.Color) {
	app.gg.draw_rounded_rect(x, y, width, height, a, bg)
	app.gg.draw_rounded_rect_empty(x, y, width, height, a, bord)
}

fn (mut app Window) draw() {
	// Custom 'UI Mode' - Refresh text carrot
	if !iui.ui_mode {
		sleep := (50 - app.frame_time)
		mut sleep_ := 0
		if !app.has_event {
			for sleep_ < sleep {
				time.sleep(10 * time.millisecond)
				sleep_ += 10
			}
		} else {
			time.sleep(5 * time.millisecond) // Reduce CPU Usage
		}
	}

	now := time.now().unix_time_milli()
	/*
	app.gg.draw_text(400, 80, app.fps.str() + ' FPS', gx.TextCfg{
		size: font_size
		color: app.theme.text_color
	})*/

	// Sort by Z-index
	app.components.sort(a.z_index < b.z_index)

	// Draw components
	mut bar_drawn := false
	for mut com in app.components {
		if mut com is Button {
			if com.in_modal && !app.modal_show {
				continue
			}
		}

		com.draw_event_fn(app, &com)

		if com.z_index > 100 && app.show_menu_bar {
			mut bar := app.get_bar()
			bar.draw()
			bar_drawn = true
		}

		if app.show_menu_bar {
			com.draw()
		} else {
			draw_with_offset(mut com, 0, -25)
		}
	}

	// Draw Menubar last
	if app.show_menu_bar && !bar_drawn {
		mut bar := app.get_bar()
		bar.draw()
	}

	if app.modal_show {
		mut ws := gg.window_size()

		app.gg.draw_rounded_rect(0, 0, ws.width, ws.height, 2, gx.rgba(0, 0, 0, 100))

		app.gg.draw_rounded_rect((ws.width / 2) - (300 / 2), 50, 300, 26, 2, gx.rgb(80,
			80, 80))

		mut title := app.modal_title
		tw := text_width(app, title)
		th := text_height(app, title)
		app.gg.draw_text((ws.width / 2) - (tw / 2), 50 + (th / 2) - 1, title, gx.TextCfg{
			size: 16
			color: gx.rgb(240, 240, 240)
		})
		app.draw_bordered_rect((ws.width / 2) - (300 / 2), 74, 300, 200, 2, app.theme.background,
			gx.rgb(80, 80, 80))

		mut spl := app.modal_text.split('\n')
		mut mult := 10
		for txt in spl {
			app.gg.draw_text((ws.width / 2) - (300 / 2) + 26, 86 + mult, txt, gx.TextCfg{
				size: 15
				color: app.theme.text_color
			})
			mult += app.gg.text_height(txt) + 4
		}

		mut close := button(app, 'OK')
		close.x = (ws.width / 2) - 50
		close.y = 230
		close.width = 100
		close.height = 25
		app.add_child(close)
		close.set_click(fn (mut win Window, btn Button) {
			win.modal_show = false
			mut co := win.components.index(Component(btn))
			win.components.delete(co)
		})
		close.in_modal = true
		close.draw()
	}
	end := time.now().unix_time_milli()
	app.fpss++
	if end - app.last_update > 1000 {
		app.fps = app.fpss
		app.fpss = 0
		app.last_update = end
	}
	app.frame_time = int(end - now)
}

fn on_event(e &gg.Event, mut app Window) {
	if e.typ == .mouse_leave {
		app.has_event = false
	} else {
		app.has_event = true
	}

	if e.typ == .mouse_move && !app.modal_show {
		app.mouse_x = int(e.mouse_x)
		app.mouse_y = int(e.mouse_y)
	}
	if e.typ == .mouse_down {
		// if app.show_menu_bar && app.bar.is_hovering() {
		//	return
		//}

		app.click_x = int(e.mouse_x)
		app.click_y = int(e.mouse_y)

		// Sort by Z-index
		app.components.sort(a.z_index > b.z_index)

		mut found := false
		for mut com in app.components {
			if point_in(mut com, app.click_x, app.click_y) && !found {
				found = true
				if mut com is Tabbox {
					for _, mut val in com.kids {
						for mut comm in val {
							if point_in(mut comm, app.click_x - com.x, (app.click_y - com.y - 20))
								&& !found {
								comm.is_mouse_down = true
							}
						}
					}
				}
				com.is_mouse_down = true
			} else {
				if mut com is Tabbox {
					for _, mut val in com.kids {
						for mut comm in val {
							if point_in(mut comm, app.click_x - com.x, (app.click_y - com.y - 20)) {
								comm.is_mouse_down = false
							}
						}
					}
				}
				com.is_mouse_down = false
			}
		}
	}

	if e.typ == .mouse_up {
		app.click_x = -1
		app.click_y = -1
		mx := int(e.mouse_x)
		my := int(e.mouse_y)
		mut found := false
		app.components.sort(a.z_index > b.z_index)
		for mut com in app.components {
			if point_in(mut com, mx, my) && !found {
				com.is_mouse_down = false
				com.is_mouse_rele = true
				if mut com is Tabbox {
					for _, mut val in com.kids {
						for mut comm in val {
							if point_in(mut comm, mx - com.x, (my - com.y - 20)) {
								comm.is_mouse_down = false
								comm.is_mouse_rele = true
							}
						}
					}
				}

				if mut com is Modal {
					for mut kid in com.children {
						mut ws := gg.window_size()
						mut sx := (ws.width / 2) - (500 / 2)
						if point_in(mut kid, mx - com.x - sx, (my - com.y) - 76) {
							kid.is_mouse_down = false
							kid.is_mouse_rele = true
						}
					}
				}
				found = true
			} else {
				com.is_mouse_down = false
			}
		}
	}
	if e.typ == .key_down {
		app.key_down(e.key_code, e)
	}
	if e.typ == .key_up {
		letter := e.key_code.str()
		if letter == 'left_shift' || letter == 'right_shift' {
			app.shift_pressed = false
		}
	}

	if e.typ == .mouse_scroll {
		for mut a in app.components {
			if mut a is Tabbox {
				for _, mut val in a.kids {
					for mut comm in val {
						if mut comm is Textbox {
							text_box_scroll(e, mut comm)
						}
					}
				}
			}

			if mut a is Textbox {
				text_box_scroll(e, mut a)
			}
		}
	}
}

fn text_box_scroll(e &gg.Event, mut a Textbox) {
	if a.is_selected {
		scroll_y := (int(e.scroll_y) / 2)
		if math.abs(e.scroll_y) != e.scroll_y {
			a.scroll_i += -scroll_y
		} else if a.scroll_i > 0 {
			a.scroll_i -= scroll_y
		}
	}
}

// Modal
pub fn (mut win Window) message_box(title string, s string) {
	win.modal_show = true
	win.modal_title = title
	win.modal_text = s
}

// Functions for GG
pub fn text_width(win Window, text string) int {
	return win.gg.text_width(text)
}

pub fn text_height(win Window, text string) int {
	return win.gg.text_height(text)
}
