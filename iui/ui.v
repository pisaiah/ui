// Copyright (c) 2021-2022 Isaiah.
module iui

import gg
import gx
import time
import os
import os.font

pub const (
	version = '0.0.9'
)

pub fn default_font() string {
	/*
	windows_def := 'C:/windows/fonts/segoeui.ttf'
	if os.exists(windows_def) {
		return windows_def
	} else {*/
	return font.default()
	//}
}

pub struct Bounds {
	x      int
	y      int
	width  int
	height int
}

pub fn debug(o string) {
	$if debug ? {
		println('(Debug) ' + o)
	}
}

pub fn point_in_raw(mut com Component, px int, py int) bool {
	if com.rx == 0 && com.ry == 0 {
		// Not drawn with offset
		return point_in(mut com, px, py)
	}

	midx := com.rx + (com.width / 2)
	midy := com.ry + (com.height / 2)

	return (abs(midx - px) < (com.width / 2)) && (abs(midy - py) < (com.height / 2))
}

pub fn point_in(mut com Component, px int, py int) bool {
	midx := com.x + (com.width / 2)
	midy := com.y + (com.height / 2)

	return (abs(midx - px) < (com.width / 2)) && (abs(midy - py) < (com.height / 2))
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
	com.x = x
	com.y = y
	com.width = width
	com.height = height
}

// Window
[heap]
struct Window {
pub mut:
	gg               &gg.Context
	font_size        int = 16
	mouse_x          int
	mouse_y          int
	click_x          int
	click_y          int
	theme            Theme
	bar              &Menubar
	components       []Component
	show_menu_bar    bool = true
	shift_pressed    bool
	key_down_event   fn (mut Window, gg.KeyCode, &gg.Event) = fn (mut win Window, key gg.KeyCode, e &gg.Event) {}
	last_update      i64
	frame_time       int
	has_event        bool = true
	config           &WindowConfig
	extra_map        map[string]string
	id_map           map[string]voidptr
	debug_draw       bool
	graphics_context &GraphicsContext
	fonts            FontSet
}

// fonts
struct FontSet {
mut:
	hash map[string]int
}

pub fn (mut win Window) add_font(font_name string, font_path string) int {
	bytes := os.read_bytes(font_path) or { []u8{} }

	if bytes.len > 0 {
		font := win.gg.ft.fons.add_font_mem('sans', bytes, false)
		if font >= 0 {
			win.fonts.hash[font_name] = font
			win.gg.ft.fons.set_font(font)
			return font
		} else {
			// Error
			panic('error')
		}
	} else {
		panic('unreadable')
		// Unreadable
	}
	return 0
}

// Struct for Graphics context
// (Removes the need to pass Window everywhere for drawing)
pub struct GraphicsContext {
pub:
	gg    &gg.Context
	theme &Theme
pub mut:
	font int
}

pub fn (ctx &GraphicsContext) set_cfg(cfg gx.TextCfg) {
	ctx.gg.set_cfg(cfg)
	ctx.gg.ft.fons.set_font(ctx.font)
}

pub fn (ctx &GraphicsContext) draw_text(x int, y int, text_ string, font int, cfg gx.TextCfg) {
	scale := if ctx.gg.ft.scale == 0 { f32(1) } else { ctx.gg.ft.scale }
	ctx.gg.set_cfg(cfg)
	ctx.gg.ft.fons.set_font(font)
	ctx.gg.ft.fons.draw_text(x * scale, y * scale, text_) // TODO: check offsets/alignment
}

fn new_graphics_context(win &Window) &GraphicsContext {
	return &GraphicsContext{
		gg: win.gg
		theme: &win.theme
	}
}

pub fn (win Window) get_from_id(id string) voidptr {
	return win.id_map[id]
}

pub fn (mut win Window) add_child(com Component) {
	win.components << com
}

pub fn window(theme Theme, title string, width int, height int) &Window {
	return window_with_config(theme, title, width, height, &WindowConfig{
		font_path: default_font()
		ui_mode: true
		user_data: 0
	})
}

[heap]
pub struct WindowConfig {
	font_path string = default_font()
	font_size int    = 16
	ui_mode   bool
	user_data voidptr
}

pub fn window_with_config(theme Theme, title string, width int, height int, config &WindowConfig) &Window {
	mut app := &Window{
		gg: 0
		theme: theme
		bar: 0
		config: config
		font_size: config.font_size
		graphics_context: 0
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
		user_data: app // TODO config.user_data
		font_path: config.font_path
		font_size: config.font_size
		ui_mode: config.ui_mode
	)
	app.graphics_context = new_graphics_context(app)
	return app
}

pub fn (mut win Window) set_theme(theme Theme) {
	win.theme = theme
	if win.bar != voidptr(0) {
		win.bar.theme = theme
	}
	win.gg.set_bg_color(theme.background)
}

fn frame(mut app Window) {
	app.gg.begin()
	app.draw()
	app.gg.end()
}

fn (app &Window) display() {
}

pub fn (app &Window) draw_bordered_rect(x int, y int, width int, height int, a int, bg gx.Color, bord gx.Color) {
	app.gg.draw_rounded_rect_filled(x, y, width, height, a, bg)
	app.gg.draw_rounded_rect_empty(x, y, width, height, a, bord)
}

pub fn (app &Window) draw_filled_rect(x int, y int, width int, height int, a int, bg gx.Color, bord gx.Color) {
	app.gg.draw_rect_filled(x, y, width, height, bg)
	app.gg.draw_rect_empty(x, y, width, height, bord)
}

fn (mut app Window) draw() {
	// Custom 'UI Mode' - Refresh text caret
	if !app.config.ui_mode {
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

	// Sort by Z-index; Lower draw first
	app.components.sort(a.z_index < b.z_index)

	// Draw components
	mut bar_drawn := false
	for mut com in app.components {
		com.draw_event_fn(app, com)

		if com.z_index > 100 && app.show_menu_bar && !bar_drawn {
			mut bar := app.get_bar()
			if bar != voidptr(0) {
				bar.draw(app.graphics_context)
			}
			bar_drawn = true
		}

		com.draw(app.graphics_context)
		com.after_draw_event_fn(app, com)
	}

	// Draw Menubar last
	if app.show_menu_bar && !bar_drawn {
		mut bar := app.get_bar()
		if bar != voidptr(0) {
			bar.draw(app.graphics_context)
		}
	}

	end := time.now().unix_time_milli()
	if end - app.last_update > 1000 {
		app.last_update = end
	}
	app.frame_time = int(end - now)
}

fn rune_box_scroll(e &gg.Event, mut a TextField) {
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
