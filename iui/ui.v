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
	is_selected bool
	draw()
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
	shift_pressed bool
}

pub fn window(theme Theme) &Window {
	mut app := &Window{
		gg: 0
		theme: theme
	}
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
	is_selected    bool
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
			btn.is_selected = true

			bg = app.theme.button_bg_click
			border = app.theme.button_border_click
			btn.last_click = time.now().unix_time_milli()
		}
	} else {
		btn.is_selected = false
	}

	// Draw Button Background & Border
	app.gg.draw_rounded_rect(x, y1, width, height, 4, bg)
	app.gg.draw_empty_rounded_rect(x, y1, width, height, 4, border)

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
			if com is Button {
				// com.text = app.mouse_x.str() + ' / ' + app.mouse_y.str()
			}
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
		app.key_down(e.key_code, e)
	}
	if e.typ == .key_up {
		letter := e.key_code.str()
		if letter == 'left_shift' || letter == 'right_shift' {
			app.shift_pressed = false
		}
	}
}

// Textbox
struct Textbox {
pub mut:
	app            &Window
	text           string
	x              int
	y              int
	width          int
	height         int
	last_click     f64
	click_event_fn fn (mut Window, Textbox)
	is_blink       bool
	last_blink     f64
	wrap           bool = true
	is_selected    bool
}

fn (mut app Window) key_down(key gg.KeyCode, e &gg.Event) {
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
	for mut a in app.components {
		if a is Textbox {
			if a.is_selected {
				kc := u32(gg.KeyCode(e.key_code))
				mut letter := e.key_code.str()
				mut res := utf32_to_str(kc)
				if letter == 'space' {
					letter = ' '
				}
				if letter == 'enter' {
					letter = '\n'
				}
				if letter == 'left_shift' || letter == 'right_shift' {
					letter = ''
					app.shift_pressed = true
					return
				}
				if letter.starts_with('_') {
					letter = letter.replace('_', '')
					nums := [')', '!', '@', '#', '$', '%', '^', '&', '*', '(']
					if app.shift_pressed && letter.len > 0 {
						letter = nums[letter.u32()]
					}
				}
				if letter == 'minus' {
					if app.shift_pressed {
						letter = '_'
					} else {
						letter = '-'
					}
				}
				if letter == 'left_bracket' && app.shift_pressed {
					letter = '{'
				}
				if letter == 'right_bracket' && app.shift_pressed {
					letter = '{'
				}
				if letter == 'equal' && app.shift_pressed {
					letter = '+'
				}
				if letter == 'apostrophe' && app.shift_pressed {
					letter = '"'
				}
				if letter == 'comma' && app.shift_pressed {
					letter = '<'
				}
				if letter == 'period' && app.shift_pressed {
					letter = '>'
				}
				if letter == 'slash' && app.shift_pressed {
					letter = '?'
				}
				if letter == 'tab' {
					letter = '	'
				}
				if letter == 'semicolon' && app.shift_pressed {
					letter = ':'
				}
				letter = letter.replace('backslash', '\\')
				if letter == 'backspace' {
					if a.text.len > 0 {
						a.text = a.text.substr(0, a.text.len - 1)
					}
				} else {
					if app.shift_pressed && letter.len > 0 {
						letter = letter.to_upper()
					}
					if letter.len > 1 {
						letter = res
					}
					a.text = a.text + letter
				}
			}
		}
	}
}

pub fn textbox(app &Window, text string) Textbox {
	return Textbox{
		text: text
		app: app
		click_event_fn: blank_event_tbox
	}
}

pub fn (mut com Textbox) set_click(b fn (mut Window, Textbox)) {
	com.click_event_fn = b
}

pub fn blank_event_tbox(mut win Window, a Textbox) {
}

pub fn (mut com Textbox) draw() {
	mut spl := com.text.split('\n')
	mut y_mult := 0
	size := 14
	padding := 4

	mut app := com.app
	mut bg := app.theme.textbox_background
	mut border := app.theme.textbox_border

	mut mid := (com.x + (com.width / 2))
	mut midy := (com.y + (com.height / 2))

	// Detect Hover
	if (math.abs(mid - app.mouse_x) < (com.width / 2))
		&& (math.abs(midy - app.mouse_y) < (com.height / 2)) {
		border = app.theme.button_border_hover
	}

	// Detect Click
	if (math.abs(mid - app.click_x) < (com.width / 2))
		&& (math.abs(midy - app.click_y) < (com.height / 2)) {
		now := time.now().unix_time_milli()

		if now - com.last_click > 100 {
			com.is_selected = true
			com.click_event_fn(app, *com)

			bg = app.theme.button_bg_click
			border = app.theme.button_border_click
			com.last_click = time.now().unix_time_milli()
		}
	} else {
        if app.click_x > -1 {
            com.is_selected = false
        }
    }
    
    if com.is_selected {
        border = app.theme.button_border_click
    }

	com.app.draw_bordered_rect(com.x, com.y, com.width, com.height, 2, bg, border)

	mut cl := 0
	for txt in spl {
		mut tl := com.app.gg.text_width(txt)
		if com.wrap && tl > com.width {
			// TODO
			com.app.gg.draw_text(com.x + padding, com.y + y_mult + padding, txt, gx.TextCfg{
				size: size
				color: com.app.theme.text_color
			})
		} else {
			com.app.gg.draw_text(com.x + padding, com.y + y_mult + padding, txt, gx.TextCfg{
				size: size
				color: com.app.theme.text_color
			})
		}
		if cl < spl.len - 1 {
			y_mult += (com.app.gg.text_height(txt) + com.app.gg.text_height(spl[0])) / 2
		}
		cl++
	}

	mut now := time.now().unix_time_milli()
	if now - com.last_blink > 1000 {
		com.is_blink = !com.is_blink
		com.last_blink = now
	}
	if com.is_blink {
		mut lw := com.app.gg.text_width(spl[spl.len - 1]) - 1
		com.app.gg.draw_text(com.x + lw + padding, com.y + y_mult + padding, '|', gx.TextCfg{
			size: size
			color: com.app.theme.text_color
		})
	}
}

// Checkbox
struct Checkbox {
pub mut:
	app            &Window
	text           string
	x              int
	y              int
	width          int
	height         int
	last_click     f64
	click_event_fn fn (mut Window, Checkbox)
	is_selected    bool
}

pub fn checkbox(app &Window, text string) Checkbox {
	return Checkbox{
		text: text
		app: app
		click_event_fn: blank_event_cbox
	}
}

pub fn (mut com Checkbox) set_click(b fn (mut Window, Checkbox)) {
	com.click_event_fn = b
}

pub fn blank_event_cbox(mut win Window, a Checkbox) {
}

pub fn (mut com Checkbox) draw() {
	app := com.app
	width := com.width
	height := com.height
	mut bg := app.theme.checkbox_bg
	mut border := app.theme.button_border_normal

	mut mid := (com.x + (width / 2))
	mut midy := (com.y + (height / 2))

	// Detect Hover
	if (math.abs(mid - app.mouse_x) < (width / 2)) && (math.abs(midy - app.mouse_y) < (height / 2)) {
		bg = app.theme.button_bg_hover
		border = app.theme.button_border_hover
	}

	// Detect Click
	if (math.abs(mid - app.click_x) < (width / 2)) && (math.abs(midy - app.click_y) < (height / 2)) {
		now := time.now().unix_time_milli()

		if now - com.last_click > 100 {
			com.is_selected = !com.is_selected
			com.click_event_fn(app, *com)

			bg = app.theme.button_bg_click
			border = app.theme.button_border_click
			com.last_click = time.now().unix_time_milli()
		}
	}

	com.app.draw_bordered_rect(com.x, com.y, com.width, com.height, 2, bg, border)
	if com.is_selected {
		cut := 4
		com.app.draw_bordered_rect(com.x + cut, com.y + cut, com.width - (cut * 2), com.height - (cut * 2),
			2, com.app.theme.checkbox_selected, com.app.theme.checkbox_selected)
	}
	sizh := app.gg.text_height(com.text) / 2
	app.gg.draw_text(com.x + com.width + 4, com.y + (height / 2) - sizh, com.text, gx.TextCfg{
		size: 14
		color: app.theme.text_color
	})
}
