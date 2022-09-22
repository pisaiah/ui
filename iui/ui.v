// Copyright (c) 2021-2022 Isaiah.
module iui

import gg
import gx
import time
import os
import os.font

pub const (
	version = '0.0.12'
)

pub fn default_font() string {
	$if emscripten ? {
		return 'myfont.ttf'
	}

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

pub fn is_in_bounds(px int, py int, bounds Bounds) bool {
	x := bounds.x
	y := bounds.y

	midx := x + (bounds.width / 2)
	midy := y + (bounds.height / 2)

	return (abs(midx - px) < (bounds.width / 2)) && (abs(midy - py) < (bounds.height / 2))
}

pub fn is_in(com &Component, px int, py int) bool {
	x := if com.rx == 0 { com.x } else { com.rx }
	y := if com.ry == 0 { com.y } else { com.ry }

	midx := x + (com.width / 2)
	midy := y + (com.height / 2)

	return (abs(midx - px) < (com.width / 2)) && (abs(midy - py) < (com.height / 2))
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
pub struct Window {
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
pub struct FontSet {
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
pub mut:
	gg          &gg.Context
	theme       &Theme
	font        int
	font_size   int = 16
	line_height int
	win         &Window
	icon_cache  map[string]int
}

pub fn (ctx &GraphicsContext) get_icon_sheet_id() int {
	if ctx.theme.name == 'Green Mono' {
		return ctx.icon_cache['icons_green']
	}
	return ctx.icon_cache['tree_file']
}

pub fn (mut ctx GraphicsContext) fill_icon_cache(mut win Window) {
	mut tfile := $embed_file('assets/tree_file.png')
	mut tree_file := win.gg.create_image_from_memory(tfile.data(), tfile.len)

	mut green_file := $embed_file('assets/icons_green.png')
	mut green_icons := win.gg.create_image_from_memory(green_file.data(), green_file.len)

	ctx.icon_cache['tree_file'] = ctx.gg.cache_image(tree_file)
	ctx.icon_cache['icons_green'] = ctx.gg.cache_image(green_icons)
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
		font_size: win.font_size
		win: win
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

[heap; params]
pub struct WindowConfig {
	font_path string = default_font()
	font_size int    = 16
	ui_mode   bool
	user_data voidptr
	title     string
	width     int
	height    int
	theme     &Theme = theme_default()
}

pub fn (win &Window) run() {
	win.gg.run()
}

pub fn make_window(config &WindowConfig) &Window {
	mut win := &Window{
		gg: 0
		theme: config.theme
		bar: 0
		config: config
		font_size: config.font_size
		graphics_context: 0
	}

	blank_draw_event_fn(mut win, &Component_A{})

	the_title := $if emscripten ? {
		'canvas'
	} $else {
		config.title
	}

	win.gg = gg.new_context(
		bg_color: win.theme.background
		width: config.width
		height: config.height
		create_window: true
		window_title: the_title
		frame_fn: frame
		event_fn: on_event
		user_data: win
		// TODO config.user_data
		font_path: config.font_path
		font_size: config.font_size
		ui_mode: config.ui_mode
	)
	win.graphics_context = new_graphics_context(win)
	if win.graphics_context.icon_cache.len == 0 {
		win.graphics_context.fill_icon_cache(mut win)
	}
	return win
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

	the_title := $if emscripten ? {
		'canvas'
	} $else {
		config.title
	}

	app.gg = gg.new_context(
		bg_color: app.theme.background
		width: width
		height: height
		create_window: true
		window_title: the_title
		frame_fn: frame
		event_fn: on_event
		user_data: app
		// TODO config.user_data
		font_path: config.font_path
		font_size: config.font_size
		ui_mode: config.ui_mode
	)
	app.graphics_context = new_graphics_context(app)
	if app.graphics_context.icon_cache.len == 0 {
		app.graphics_context.fill_icon_cache(mut app)
	}
	return app
}

pub fn (mut win Window) set_theme(theme Theme) {
	win.theme = theme
	ref := &theme
	if win.bar != unsafe { nil } {
		win.bar.theme = ref
	}
	win.graphics_context.theme = ref
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

fn (app &Window) do_sleep() {
	if app.config.ui_mode {
		return
	}
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

fn (mut app Window) draw() {
	// Custom 'UI Mode' - Refresh text caret
	// app.do_sleep()
	now := time.now().unix_time_milli()

	// Sort by Z-index; Lower draw first
	app.components.sort(a.z_index < b.z_index)

	if app.graphics_context.line_height == 0 {
		app.graphics_context.calculate_line_height()
	}

	// Draw components
	mut bar_drawn := false
	for mut com in app.components {
		com.draw_event_fn(mut app, com)

		if com.z_index > 100 && app.show_menu_bar && !bar_drawn {
			mut bar := app.get_bar()
			if bar != unsafe { nil } {
				bar.draw(app.graphics_context)
			}
			bar_drawn = true
		}

		com.draw(app.graphics_context)
		com.after_draw_event_fn(mut app, com)
	}

	// Draw Menubar last
	if app.show_menu_bar && !bar_drawn {
		mut bar := app.get_bar()
		if bar != unsafe { nil } {
			bar.draw(app.graphics_context)
		}
	}

	if app.font_size != app.graphics_context.font_size {
		app.graphics_context.font_size = app.font_size
		app.graphics_context.calculate_line_height()
	}

	end := time.now().unix_time_milli()
	if end - app.last_update > 1000 {
		app.last_update = end
	}
	app.frame_time = int(end - now)
}

fn rune_box_scroll(e &gg.Event, mut a TextField) {
	if !a.is_selected {
		return
	}

	scroll_y := (int(e.scroll_y) / 2)
	if abs(e.scroll_y) != e.scroll_y {
		a.scroll_i += -scroll_y
	} else if a.scroll_i > 0 {
		a.scroll_i -= scroll_y
	}
}

pub fn (mut ctx GraphicsContext) calculate_line_height() {
	ctx.line_height = ctx.gg.text_height('A1!|{}j;') + 2

	if ctx.line_height < ctx.font_size {
		// Fix for wasm
		ctx.line_height = ctx.font_size + 2
	}

	dump('$ctx.line_height & $ctx.font_size')
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
