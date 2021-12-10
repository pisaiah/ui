// Copyright (c) 2021-2022 Isaiah.
// All Rights Reserved.
module iui

import gg
import gx
import time
import math

const (
	win_width  = 500
	win_height = 512
	version    = '0.0.1'
)

// Component Interface
pub interface Component {
mut:
	text string
	x int
	y int
	width int
	height int
	last_click f64
	draw()
	// click_event_fn fn (mut Window, Component)
}

pub fn (mut com Button) set_click(b fn (mut Window, Button)) {
	com.click_event_fn = b
}

pub fn blank_event(mut win Window, a Button) {
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
	bar           Menubar
	components    []Component
	show_menu_bar bool = true
}

pub fn window(theme Theme) &Window {
	mut app := &Window{
		gg: 0
		theme: theme
	}
	app.init()
	return app
}

pub fn (mut app Window) init() {
	mut font_path := gg.system_font_path()
	app.gg = gg.new_context(
		bg_color: app.theme.background
		width: iui.win_width
		height: iui.win_height
		create_window: true
		window_title: 'V GG Demo'
		frame_fn: frame
		event_fn: on_event
		user_data: app
		font_path: font_path
		font_size: 14
	)
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

fn (mut app Window) get_bar() Menubar {
	return app.bar
}

fn (app &Window) draw_bordered_rect(x int, y int, width int, height int, a int, bg gx.Color, bord gx.Color) {
	app.gg.draw_rounded_rect(x, y, width, height, a, bg)
	app.gg.draw_empty_rounded_rect(x, y, width, height, a, bord)
}

[heap]
struct Menubar {
pub mut:
	app   &Window
	theme Theme
	items []MenuItem
}

[heap]
struct MenuItem {
pub mut:
	items          []MenuItem
	text           string
	shown          bool
	show_items     bool
	click_event_fn fn (mut Window, MenuItem)
}

pub fn menuitem(text string) MenuItem {
	return MenuItem{
		text: text
		shown: false
		show_items: false
		click_event_fn: blank_event_mi
	}
}

fn blank_event_mi(mut win Window, item MenuItem) {
}

pub fn (mut com MenuItem) set_click(b fn (mut Window, MenuItem)) {
	com.click_event_fn = b
}

pub fn menubar(app &Window, theme Theme) Menubar {
	return Menubar{
		app: app
		theme: theme
	}
}

fn (mut mb Menubar) draw() {
	mut wid := gg.window_size().width
	mb.app.gg.draw_rounded_rect(0, 0, wid, 25, 2, mb.app.theme.menubar_background)
	mb.app.gg.draw_empty_rounded_rect(0, 0, wid, 25, 2, mb.app.theme.menubar_border)

	mut mult := 0
	for mut item in mb.items {
		mb.app.draw_menu_button(50 * mult, 0, 50, 25, mut item)
		mult++
	}
}

struct Button {
pub mut:
	app            &Window
	text           string
	x              int
	y              int
	width          int
	height         int
	last_click     f64
	click_event_fn fn (mut Window, Button)
}

pub fn button(app &Window, text string) Button {
	return Button{
		text: text
		app: app
		click_event_fn: blank_event
	}
}

pub fn (mut btn Button) draw() {
	btn.app.draw_button(btn.x, btn.y, btn.width, btn.height, mut btn)
}

fn (app &Window) draw_button(x int, y int, width int, height int, mut btn Button) {
	mut y1 := y
	if !app.show_menu_bar {
		y1 = y1 - 25
	}

	text := btn.text
	size := app.gg.text_width(text) / 2
	sizh := app.gg.text_height(text) / 2

	mut bg := app.theme.button_bg_normal
	mut border := app.theme.button_border_normal

	mut mid := (x + (width / 2))
	mut midy := (y1 + (height / 2))

	// Detect Hover
	if (math.abs(mid - app.mouse_x) < (width / 2)) && (math.abs(midy - app.mouse_y) < (height / 2)) {
		bg = app.theme.button_bg_hover
		border = app.theme.button_border_hover
	}

	// Detect Click
	if (math.abs(mid - app.click_x) < (width / 2)) && (math.abs(midy - app.click_y) < (height / 2)) {
		now := time.now().unix_time_milli()

		// TODO: Better click time
		if now - btn.last_click > 100 {
			// btn.eb.publish('click', work, error) // TODO: Eventbus broken? (INVALID MEMORY ERROR)
			btn.click_event_fn(app, *btn)

			bg = app.theme.button_bg_click
			border = app.theme.button_border_click
			btn.last_click = time.now().unix_time_milli()
		}
	}

	// Draw Button Background & Border
	app.gg.draw_rounded_rect(x, y1, width, height, 2, bg)
	app.gg.draw_empty_rounded_rect(x, y1, width, height, 2, border)

	// Draw Button Text
	app.gg.draw_text((x + (width / 2)) - size, y1 + (height / 2) - sizh, text, gx.TextCfg{
		size: 14
		color: app.theme.text_color
	})
}

fn (app &Window) draw_menu_button(x int, y int, width int, height int, mut item MenuItem) {
	size := app.gg.text_width(item.text) / 2
	sizh := app.gg.text_height(item.text) / 2

	mut bg := app.theme.menubar_background
	mut border := app.theme.menubar_border

	mut midx := (x + (width / 2))
	mut midy := (y + (height / 2))

	// Detect Hover
	if (math.abs(midx - app.mouse_x) < (width / 2)) && (math.abs(midy - app.mouse_y) < (height / 2)) {
		bg = app.theme.button_bg_hover
		border = app.theme.button_border_hover
	}

	// Detect Click
	mut clicked := ((math.abs(midx - app.click_x) < (width / 2))
		&& (math.abs(midy - app.click_y) < (height / 2)))
	if clicked && !item.show_items {
		bg = app.theme.button_bg_click
		border = app.theme.button_border_click
		item.show_items = true

		item.click_event_fn(app, *item)

		if item.text == 'About iUI' {
			go message_box('About iUI', "Isaiah's UI Toolkit for V.\nVersion: " + iui.version +
				'\n\nCopyright (c) 2021-2022 Isaiah.\t\nAll Rights Reserved.')
		}
	}

	if item.show_items && item.items.len > 0 {
		bg = app.theme.button_bg_click
		border = app.theme.button_border_click
		mut wid := 100

		for mut sub in item.items {
			sub_size := app.gg.text_width(sub.text + '...')
			if wid < sub_size {
				wid = sub_size
			}
		}

		app.draw_bordered_rect(x, y + height, wid, (item.items.len * 26) + 2, 2, app.theme.dropdown_background,
			app.theme.dropdown_border)

		mut mult := 0
		for mut sub in item.items {
			app.draw_menu_button(x + 1, y + height + mult + 1, wid - 2, 25, mut sub)
			mult += 26
		}
	}

	if item.show_items && app.click_x != -1 && app.click_y != -1 && !clicked {
		item.show_items = false
	}

	// Draw Button Background & Border
	app.gg.draw_rounded_rect(x, y, width, height, 2, bg)
	app.gg.draw_empty_rounded_rect(x, y, width, height, 2, border)

	// Draw Button Text
	app.gg.draw_text((x + (width / 2)) - size, y + (height / 2) - sizh, item.text, gx.TextCfg{
		size: 14
		color: app.theme.text_color
	})
}

fn (mut app Window) draw() {
	time.sleep(10 * time.millisecond) // Reduce CPU Usage

	if (time.now().unix_time_milli() - app.lastt) > 1000 {
		app.fps = app.fpss
		app.fpss = 0
		app.lastt = time.now().unix_time_milli()
	}
	app.fpss++
	app.display()

	// Draw components
	for mut com in app.components {
		com.draw()
	}

	// Draw Menubar last
	if app.show_menu_bar {
		mut bar := app.get_bar()
		bar.draw()
	}
}

fn on_event(e &gg.Event, mut app Window) {
	if e.typ == .mouse_move {
		app.mouse_x = int(e.mouse_x)
		app.mouse_y = int(e.mouse_y)
		for mut com in app.components {
			com.text = app.mouse_x.str() + ' / ' + app.mouse_y.str()
		}
	}
	if e.typ == .mouse_down {
		app.click_x = int(e.mouse_x)
		app.click_y = int(e.mouse_y)
	}

	if e.typ == .mouse_up {
		app.click_x = -1
		app.click_y = -1
	}
	if e.typ == .key_down {
		app.key_down(e.key_code)
	}
}

fn (mut app Window) key_down(key gg.KeyCode) {
	// global keys
	match key {
		.escape {
			app.gg.quit()
		}
		.left_alt {
			app.show_menu_bar = !app.show_menu_bar
		}
		else {}
	}
}
