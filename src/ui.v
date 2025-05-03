// Copyright (c) 2021-2024 Isaiah.
module iui

import gg
import gx
import time
import os
import os.font

pub const version = '0.0.24'

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
	/*
	if mut com is Selectbox {
		if com.show_items {
			list_height := (com.items.len * com.sub_height)
			hei = list_height / 2
		}
	}
	*/

	// Don't process if MenuItem is hidden.
	if mut com is MenuItem {
		par := &MenuItem(com.parent)
		if com.sub == 1 && !par.open {
			return false
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
	popups           []&Popup
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
	event_map        map[string][]fn (voidptr)
	custom_titlebar  bool
	custom_controls  ?WindowControls
}

struct WindowControls {
mut:
	p &Panel
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
	font_path       string = default_font()
	font_size       int    = 16
	ui_mode         bool
	user_data       voidptr
	title           string
	width           int
	height          int
	theme           &Theme = theme_default()
	custom_titlebar bool
}

pub fn (mut win Window) run() {
	win.invoke_window_create()
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
		custom_titlebar:  cfg.custom_titlebar
	}

	// blank_draw_event_fn(mut win, &Component_A{})
	txt := $if emscripten ? {
		'canvas'
	} $else {
		cfg.title
	}

	sample_count := $if aa ? { 2 } $else { 0 }
	swap_interval := $if si2 ? { 2 } $else { 1 }

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
		sample_count:  sample_count
		swap_interval: swap_interval
	)
	win.graphics_context = new_graphics(win)
	if win.graphics_context.icon_cache.len == 0 {
		win.graphics_context.fill_icon_cache(mut win)
	}

	$if windows {
		if win.gg.native_rendering {
			win.gg.ui_mode = false
		}

		// "UI Mode"
		if cfg.ui_mode {
			set_power_save(true)
			set_window_fps(40)
		}
	}

	win.theme.setup_fn(mut win)
	return win
}

pub fn (win &Window) invoke_window_create() {
	ev := &WindowEvent{
		win: win
	}
	for f in win.event_map['window_create'] {
		f(ev)
	}
}

pub fn (mut win Window) add_theme(theme &Theme) {
	win.graphics_context.themes.add_theme(theme)
}

pub fn (mut win Window) set_theme(theme Theme) {
	theme.setup_fn(mut win)
	win.theme = theme
	ref := &theme

	win.graphics_context.theme = ref
	theme.setup_fn(mut win)

	win.gg.set_bg_color(theme.background)
	win.invoke_theme_change_event()
}

pub fn (win &Window) invoke_key_event(key gg.KeyCode, gg_ev &gg.Event, typ string) {
	ev := WindowKeyEvent{
		win: win
		key: key
		ev:  unsafe { gg_ev }
	}
	for f in win.event_map[typ] {
		f(&ev)
	}
}

pub fn (win &Window) invoke_theme_change_event() {
	ev := WindowThemeChangeEvent{
		win: win
	}
	for f in win.event_map['theme_change'] {
		f(&ev)
	}
}

fn C.win_make_borderless(w &Window)

fn C.win_post_control_message(val int)

fn win_post_control_message(val int) {
	$if windows {
		C.win_post_control_message(val)
	}
}

// v-native-render
/*
fn C.get_hwnd() C.HWND
fn C.sapp_win32_get_hwnd() C.HWND

@[export: 'iui_get_hwnd_2']
fn (win &Window) get_hwnd_2() voidptr {
	$if windows {
		if win.gg.native_rendering {
			return C.get_hwnd()
		}
	}

	return C.sapp_win32_get_hwnd()
}
*/

// Borderless Window support
pub fn (win &Window) win32_make_borderless() {
	$if windows {
		C.win_make_borderless(win)
	}
}

pub fn is_custom_titlebar_supported() bool {
	$if windows {
		return true
	}
	return false
}

pub fn (mut win Window) draw_window_controls() {
	if !is_custom_titlebar_supported() {
		return
	}

	g := win.graphics_context

	if win.custom_controls == none {
		mut p := Panel.new(layout: FlowLayout.new(hgap: 0, vgap: 0))

		mut min := Button.new(icon: -1, text: '\uE937', font_size: 10)
		mut max := Button.new(icon: -1, text: '\uE938', font_size: 10)
		mut xxx := Button.new(icon: -1, text: '\uE8BB', font_size: 10)

		min.border_radius = -1
		max.border_radius = -1
		xxx.border_radius = -1

		min.font = -1
		max.font = -1
		xxx.font = -1

		min.subscribe_event('mouse_up', fn (e &MouseEvent) {
			win_post_control_message(1)
		})

		max.subscribe_event('mouse_up', fn (e &MouseEvent) {
			win_post_control_message(2)
		})

		xxx.subscribe_event('mouse_up', fn (e &MouseEvent) {
			win_post_control_message(0)
		})

		min.icon_width = 0
		min.icon_height = 1
		max.icon_width = 1
		max.icon_height = 1
		xxx.icon_width = 2
		xxx.icon_height = 1

		min.set_area_filled_state(false, .normal)
		max.set_area_filled_state(false, .normal)
		xxx.set_area_filled_state(false, .normal)

		min.set_bounds(0, 0, 40, 30)
		max.set_bounds(0, 0, 40, 30)
		xxx.set_bounds(0, 0, 40, 30)

		if isnil(win.bar) {
			win.bar = Menubar.new()
		}

		p.add_child(min)
		p.add_child(max)
		p.add_child(xxx)
		p.z_index = 900
		p.set_bounds(g.gg.window_size().width - 121, win.bar.padding / 4, 121, 30)

		if !isnil(win.bar) {
			win.bar.margin_top = 2
		}
		win.custom_controls = WindowControls{
			p: p
		}
	}

	if win.custom_controls != none {
		win.custom_controls.p.x = g.gg.window_size().width - 121
		win.custom_controls.p.draw(g)
	}

	txt := win.config.title
	tw := g.text_width(txt)
	tc := g.theme.text_color
	title_color := gx.rgba(tc.r, tc.g, tc.b, 100)

	bw := win.bar.get_items_width()

	w := (win.get_size().width / 2) - tw / 2
	h := (win.bar.height / 2) - g.line_height / 2
	nw := if w < bw { bw + 4 } else { w }

	if bw == 0 {
		g.draw_text_ofset(0, 0, 8, h, txt, gx.TextCfg{
			size:  g.font_size
			color: title_color
		})
		return
	}

	g.draw_text_ofset(0, 0, nw, h, txt, gx.TextCfg{
		size:  g.font_size
		color: title_color
	})
}

pub fn (win &Window) get_size() gg.Size {
	return win.gg.window_size()
}

pub fn (win &Window) invoke_draw_event() {
	if win.event_map['draw'].len == 0 {
		return
	}

	ev := WindowDrawEvent{
		win: win
	}
	for f in win.event_map['draw'] {
		f(&ev)
	}
}

pub fn (mut com Window) subscribe_event(val string, f fn (voidptr)) {
	com.event_map[val] << f
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

	$if customtitlebar ? {
		app.custom_titlebar = true
	}

	if app.custom_titlebar {
		// Testing
		if !isnil(app.bar) {
			// app.bar.padding = 12
		}
		app.win32_make_borderless()
	}

	if app.components.len == 1 {
		if app.components[0] is Container || app.components[0] is ScrollView
			|| app.components[0] is Tabbox {
			// Content Pane
			mut bar := app.get_bar()
			ws := app.gg.window_size()
			if ws.width > 0 {
				app.components[0].width = ws.width
			}

			if bar != unsafe { nil } {
				hei := ws.height
				if hei > 0 {
					app.components[0].y = app.bar.height // 27
					app.components[0].height = ws.height - app.bar.height
				}
			} else {
				app.components[0].height = ws.height
			}
		}
	}

	app.invoke_draw_event()

	// Draw components
	if app.components.len > 0 {
		mut last := app.components.last()
		if mut last is Page {
			invoke_draw_event(last, app.graphics_context)
			last.draw(app.graphics_context)
			invoke_after_draw_event(last, app.graphics_context)
		} else {
			app.draw_children()
		}
	}

	// Draw Popups last
	for mut pop in app.popups {
		pop.draw(app.graphics_context)
	}

	if app.custom_titlebar {
		app.draw_window_controls()
	}

	if app.tooltip.len != 0 {
		app.draw_tooltip(app.graphics_context)

		// app.tooltip = ''
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

fn (mut app Window) draw_children() {
	mut bar_drawn := false

	if !isnil(app.bar) {
		app.bar.width = gg.window_size().width
	}

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
	}

	if app.show_menu_bar && !bar_drawn {
		mut bar := app.get_bar()
		if bar != unsafe { nil } {
			bar.draw(app.graphics_context)
		}
	}
}

pub fn (mut w Window) refresh_ui() {
	w.gg.refresh_ui()
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
