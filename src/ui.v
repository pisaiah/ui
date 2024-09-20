// Copyright (c) 2021-2023 Isaiah.
module iui

import gg
import gx
import time
import os
import os.font

pub const version = '0.0.21'

pub fn default_font() string {
	$if emscripten ? {
		return 'myfont.ttf'
	}

	def := font.default()
	return def
}

pub struct Bounds {
pub:
	x      int
	y      int
	width  int
	height int
}

pub fn debug(o string) {
}

pub fn is_in_bounds(px int, py int, b Bounds) bool {
	x := b.x
	y := b.y

	midx := x + (b.width / 2)
	midy := y + (b.height / 2)

	return abs(midx - px) < (b.width / 2) && abs(midy - py) < (b.height / 2)
}

pub fn is_in(com &Component, px int, py int) bool {
	x := if com.rx == 0 { com.x } else { com.rx }
	y := if com.ry == 0 { com.y } else { com.ry }

	midx := x + (com.width / 2)
	midy := y + (com.height / 2)

	return abs(midx - px) < (com.width / 2) && abs(midy - py) < (com.height / 2)
}

pub fn point_in_raw(mut com Component, px int, py int) bool {
	if com.rx == 0 && com.ry == 0 {
		// Not drawn with offset
		return point_in(mut com, px, py)
	}

	mut hei := com.height / 2
	if mut com is Selectbox {
		if com.show_items {
			list_height := (com.items.len * com.sub_height)
			hei = list_height / 2
		}
	}

	midx := com.rx + (com.width / 2)
	midy := com.ry + hei

	return abs(midx - px) < (com.width / 2) && abs(midy - py) < hei
}

pub fn point_in(mut com Component, px int, py int) bool {
	midx := com.x + (com.width / 2)
	midy := com.y + (com.height / 2)

	return abs(midx - px) < (com.width / 2) && abs(midy - py) < (com.height / 2)
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
@[heap]
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
	popups           []Popup
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
	frame_evnt_count int
	sleep_if_no_evnt bool = true
	second_pass      u8
	tooltip          string
}

fn (win &Window) draw_tooltip(ctx &GraphicsContext) {
	mut x := win.mouse_x
	mut y := win.mouse_y - 16

	lines := win.tooltip.split_into_lines()

	if lines.len > 1 {
		x += 20
	}

	ts := ctx.text_width(lines[0])
	th := ctx.line_height * lines.len

	ctx.gg.draw_rect_filled(x, y, ts, th, gx.rgb(184, 207, 229))
	ctx.gg.draw_rect_empty(x, y, ts, th, gx.rgb(99, 130, 191))

	for line in lines {
		ctx.draw_text(x, y, line, ctx.font, gx.TextCfg{
			size:  win.font_size
			color: ctx.theme.text_color
		})
		y += ctx.line_height
	}
}

pub fn (mut win Window) set_font(font_path string) {
	win.graphics_context.font = font_path
}

@[deprecated]
pub fn (mut win Window) add_font(font_name string, font_path string) int {
	win.set_font(font_path)
	return -1
}

// Struct for Graphics context
@[heap]
pub struct GraphicsContext {
pub mut:
	gg          &gg.Context
	theme       &Theme
	font        string
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
	mut tree_file := win.gg.create_image_from_memory(tfile.data(), tfile.len) or { panic(err) }

	mut green_file := $embed_file('assets/icons_green.png')
	mut green_icons := win.gg.create_image_from_memory(green_file.data(), green_file.len) or {
		panic(err)
	}

	mut cb_file := $embed_file('assets/check.png')
	mut cb_icons := win.gg.create_image_from_memory(cb_file.data(), cb_file.len) or { panic(err) }

	ctx.icon_cache['tree_file'] = ctx.gg.cache_image(tree_file)
	ctx.icon_cache['icons_green'] = ctx.gg.cache_image(green_icons)
	ctx.icon_cache['check_box'] = ctx.gg.cache_image(cb_icons)
}

pub fn (ctx &GraphicsContext) set_cfg(cfg gx.TextCfg) {
	// cfg.family = ''
	mut cfgg := gx.TextCfg{
		...cfg
		family: ctx.font
	}

	ctx.gg.set_text_cfg(cfgg)
	$if windows {
		if ctx.gg.native_rendering {
			return
		}
	}

	// ctx.gg.ft.fons.set_font(ctx.font)

	// ctx.gg.ft.fons.set_font(ctx.gg.ft.fonts_map[ ctx.win.fonts.names[ctx.font] ])
}

pub fn (ctx &GraphicsContext) draw_text(x int, y int, text_ string, font_id string, cfg gx.TextCfg) {
	$if windows {
		if ctx.gg.native_rendering {
			ctx.gg.draw_text(x, y, text_, cfg)
			return
		}

		$if wintxt ? {
			if text_.len > 0 {
				ctx.draw_win32_text(x, y, text_, cfg)
			}
			return
		}
	}
	scale := if ctx.gg.ft.scale == 0 { f32(1) } else { ctx.gg.ft.scale }

	mut cfgg := gx.TextCfg{
		...cfg
		family: font_id
		// ctx.family
	}

	ctx.gg.set_text_cfg(cfgg)

	// ctx.gg.ft.fons.set_font(font_id)
	ctx.gg.ft.fons.draw_text(x * scale, y * scale, text_)

	/*$if windows {
		win_draw_text(x, y, text_, cfg)
	}*/
}

fn new_graphics(win &Window) &GraphicsContext {
	return &GraphicsContext{
		gg:        win.gg
		theme:     &win.theme
		font_size: win.font_size
		win:       win
	}
}

@[deprecated: 'Use get[T](id)']
pub fn (win &Window) get_from_id(id string) voidptr {
	return unsafe { win.id_map[id] }
}

pub fn (win &Window) get[T](id string) T {
	return win.id_map[id] or { panic('Component with ID "${id}" not found.') }
}

/*
pub fn (mut win Window) add_child(com Component) {
	win.components << com
}*/

pub fn (win &Window) add_child(com Component) {
	unsafe { win.components << com }
}

pub fn (win &Window) add_popup(com &Popup) {
	unsafe { win.popups << com }
}

pub fn window(c &WindowConfig) &Window {
	return Window.new(c)
}

@[heap; params]
pub struct WindowConfig {
pub:
	font_path string = default_font()
	font_size int    = 16
	ui_mode   bool
	user_data voidptr
	title     string
	width     int
	height    int
	theme     &Theme = theme_default()
}

pub fn (mut win Window) run() {
	win.gg.run()
}

pub fn Window.new(cfg &WindowConfig) &Window {
	mut win := &Window{
		gg:               unsafe { nil }
		theme:            cfg.theme
		bar:              unsafe { nil }
		config:           cfg
		font_size:        cfg.font_size
		graphics_context: unsafe { nil }
	}

	blank_draw_event_fn(mut win, &Component_A{})

	txt := $if emscripten ? {
		'canvas'
	} $else {
		cfg.title
	}

	win.gg = gg.new_context(
		bg_color:      win.theme.background
		width:         cfg.width
		height:        cfg.height
		create_window: true
		window_title:  txt
		frame_fn:      frame
		event_fn:      on_event
		user_data:     win
		font_path:     cfg.font_path
		font_size:     cfg.font_size
		ui_mode:       cfg.ui_mode
	)
	win.graphics_context = new_graphics(win)
	if win.graphics_context.icon_cache.len == 0 {
		win.graphics_context.fill_icon_cache(mut win)
	}

	$if windows {
		if win.gg.native_rendering {
			win.gg.ui_mode = false
		}
	}

	win.theme.setup_fn(mut win)
	return win
}

pub fn (mut win Window) set_theme(theme Theme) {
	theme.setup_fn(mut win)
	win.theme = theme
	ref := &theme

	win.graphics_context.theme = ref
	theme.setup_fn(mut win)

	win.gg.set_bg_color(theme.background)
}

// GG does not init_sokol_image for images loaded after gg_init_sokol_window
pub fn (mut win Window) create_gg_image(buf &u8, bufsize int) gg.Image {
	mut img := win.gg.create_image_from_memory(buf, bufsize) or { panic(err) }
	if img.simg.id == 0 && win.graphics_context.line_height > 0 {
		img.init_sokol_image()
	}
	return img
}

fn frame(mut app Window) {
	app.gg.begin()
	app.draw()
	app.gg.end()
}

fn (app &Window) display() {
}

pub fn (app &Window) draw_bordered_rect(x int, y int, w int, h int, a int, bg gx.Color, bord gx.Color) {
	app.gg.draw_rounded_rect_filled(x, y, w, h, a, bg)
	app.gg.draw_rounded_rect_empty(x, y, w, h, a, bord)
}

pub fn (g &GraphicsContext) draw_bordered_rect(x int, y int, w int, h int, bg gx.Color, bord gx.Color) {
	g.gg.draw_rect_filled(x, y, w, h, bg)
	g.gg.draw_rect_empty(x, y, w, h, bord)
}

// ui_mode: lower cpu usage
fn (mut w Window) do_sleep() {
	$if no_ui_sleep ? {
		return
	}

	if w.config.ui_mode {
		return
	}

	if !w.sleep_if_no_evnt {
		return
	}

	if w.has_event {
		w.frame_evnt_count += 1
		if w.frame_evnt_count > 3 {
			w.has_event = false
			w.frame_evnt_count = 0
		}
	}

	if !w.has_event {
		//	time.sleep(10 * time.millisecond) // Reduce CPU Usage
	}
}

fn (mut app Window) draw() {
	// Custom 'UI Mode' - Refresh text caret
	app.do_sleep()
	now := time.now().unix_milli()

	// Sort by Z-index; Lower draw first
	app.components.sort(a.z_index < b.z_index)

	if app.graphics_context.line_height == 0 {
		app.graphics_context.calculate_line_height()
	}

	if app.components.len == 1 {
		if app.components[0] is Panel || app.components[0] is ScrollView {
			// Content Pane
			mut bar := app.get_bar()
			ws := app.gg.window_size()
			if ws.width > 0 {
				app.components[0].width = ws.width
			}

			if bar != unsafe { nil } {
				hei := ws.height
				if hei > 0 {
					app.components[0].y = 27
					app.components[0].height = ws.height - 27
				}
			} else {
				app.components[0].height = ws.height
			}
		}
	}

	// Draw components
	mut bar_drawn := false
	for mut com in app.components {
		if !isnil(com.draw_event_fn) {
			com.draw_event_fn(mut app, com)
		}

		if mut com is Page {
			bar_drawn = true
		}

		if com.z_index > 100 && app.show_menu_bar && !bar_drawn {
			mut bar := app.get_bar()
			if bar != unsafe { nil } {
				bar.draw(app.graphics_context)
			}
			bar_drawn = true
		}

		invoke_draw_event(com, app.graphics_context)
		com.draw(app.graphics_context)
		invoke_after_draw_event(com, app.graphics_context)
		com.after_draw_event_fn(mut app, com)
	}

	// Draw Popups last
	for mut pop in app.popups {
		pop.draw(app.graphics_context)
	}

	if app.tooltip.len != 0 {
		app.draw_tooltip(app.graphics_context)

		// app.tooltip = ''
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

	end := time.now().unix_milli()
	if end - app.last_update > 500 {
		app.last_update = end
		app.second_pass += 1
		app.tooltip = ''
	} else {
		app.second_pass = 0
	}
	app.frame_time = int(end - now)
}

pub fn (mut g GraphicsContext) calculate_line_height() {
	g.line_height = g.gg.text_height('A1!{}j;') + 2

	if g.line_height < g.font_size {
		// Fix for wasm
		$if emscripten ? {
			g.line_height = g.font_size + 2
		}
	}
}

// Functions for GG
pub fn (g &GraphicsContext) text_width(text string) int {
	$if windows {
		if g.gg.native_rendering {
			return g.gg.text_width(text)
		}
	}
	ctx := g.gg
	adv := ctx.ft.fons.text_bounds(0, 0, text, &f32(0))
	return int(adv / ctx.scale)
}

pub fn (mut w Window) refresh_ui() {
	w.gg.refresh_ui()
}

// Functions for GG
pub fn text_height(win Window, text string) int {
	return win.gg.text_height(text)
}

@[inline]
pub fn abs[T](a T) T {
	return if a > 0 { a } else { -a }
}

pub fn open_url(url string) {
	url_ := if url.starts_with('http') { url } else { 'http://' + url }

	$if windows {
		os.execute('cmd.exe /c "start ${url_}"')
	} $else $if macos {
		os.execute('open "${url_}"')
	} $else $if linux {
		os.execute('xdg-open "${url_}"')
	}
}

pub fn min_h(ctx &GraphicsContext) int {
	return ctx.line_height + 9
}
