// Copyright (c) 2021-2022 Isaiah.
// All Rights Reserved.
module iui

import gg
import gx
import time
import os
import os.font

pub const (
	version = '0.0.1'
	ui_mode = false // Note: On N4100; ui_mode uses
		// 	   more cpu while on than off.
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
	after_draw_event_fn fn (mut Window, &Component)
	draw()
}

[heap]
pub struct Component_A {
pub mut:
	text                string
	x                   int
	y                   int
	width               int
	height              int
	last_click          f64
	is_selected         bool
	carrot_index        int
	z_index             int
	scroll_i            int
	is_mouse_down       bool
	is_mouse_rele       bool
	draw_event_fn       fn (mut Window, &Component) = blank_draw_event_fn
	after_draw_event_fn fn (mut Window, &Component) = blank_draw_event_fn
}

fn blank_draw_event_fn(mut win Window, tree &Component) {
	// Stub
}

pub fn (mut com Component_A) draw() {
	// Stub
}

pub fn point_in(mut com Component, px int, py int) bool {
	midx := com.x + (com.width / 2)
	midy := com.y + (com.height / 2)

	return (abs(midx - px) < (com.width / 2)) && (abs(midy - py) < (com.height / 2))
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
	font_size     int = 14
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

	last_update i64
	frame_time  int
	has_event   bool = true
	extra_map   map[string]string
}

pub fn (mut win Window) add_child(com Component) {
	win.components << com
}

pub fn window(theme Theme, title string, width int, height int) &Window {
	return window_with_font(theme, title, width, height, font.default())
}

pub fn window_with_font(theme Theme, title string, width int, height int, font_path string) &Window {
	mut app := &Window{
		gg: 0
		theme: theme
		bar: 0
	}

	// Call blank function so -skip-unused won't skip it
	blank_draw_event_fn(mut app, &Component_A{})

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
		font_size: app.font_size
		ui_mode: iui.ui_mode
	)
	return app
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
	app.gg.draw_rounded_rect_filled(x, y, width, height, a, bg)
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

	// Sort by Z-index; Lower draw first
	app.components.sort(a.z_index < b.z_index)

	// Draw components
	mut bar_drawn := false
	for mut com in app.components {
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
		com.after_draw_event_fn(app, &com)
	}

	// Draw Menubar last
	if app.show_menu_bar && !bar_drawn {
		mut bar := app.get_bar()
		bar.draw()
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

	if e.typ == .mouse_move {
		app.mouse_x = int(e.mouse_x)
		app.mouse_y = int(e.mouse_y)
	}
	if e.typ == .mouse_down {
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
				if mut com is Modal {
					for mut child in com.children {
						if point_in(mut child, app.click_x - com.x, (app.click_y - com.y)) && !found {
							child.is_mouse_down = true
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
						if point_in(mut kid, mx - com.x - sx, (my - com.y) - (com.top_off + 26)) {
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

			if mut a is Modal {
				scroll_y := (int(e.scroll_y) / 2)
				if abs(e.scroll_y) != e.scroll_y {
					a.scroll_i += -scroll_y
				} else if a.scroll_i > 0 {
					a.scroll_i -= scroll_y
				}
				if a.scroll_i < 0 {
					a.scroll_i = 0
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
		if abs(e.scroll_y) != e.scroll_y {
			a.scroll_i += -scroll_y
		} else if a.scroll_i > 0 {
			a.scroll_i -= scroll_y
		}
	}
}

// Functions for GG
pub fn text_width(win Window, text string) int {
	return win.gg.text_width(text)
}

pub fn text_height(win Window, text string) int {
	return win.gg.text_height(text)
}

//
[inline]
pub fn abs<T>(a T) T {
	return if a > 0 { a } else { -a }
}

pub fn open_url(url string) {
	mut url_ := url
	if !url.starts_with('http') {
		url_ = 'https://' + url
	}
	$if windows {
		os.execute('cmd.exe /c "start $url_"')
	} $else $if macos {
		os.execute('open "$url_"')
	} $else $if linux {
		os.execute('xdg-open "$url_"')
	}
}
