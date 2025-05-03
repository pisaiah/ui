// Copyright (c) 2021-2025 Isaiah.
module iui

import gx

// Fluenty/WinUI3 values
const control_corner_radius = 4

// Fluenty/WinUI3 Design (Light)
const light_accent_text = gx.white
const light_accent_fill = gx.rgb(0, 80, 158)
const light_accent_fill_second = gx.rgb(25, 97, 167)
const light_accent_fill_third = gx.rgb(50, 113, 175)

// Fluenty/WinUI3 Design (Dark)
const dark_accent_text = gx.black
const dark_accent_fill = gx.rgb(64, 180, 255)
const dark_accent_fill_second = gx.rgb(60, 170, 230)
const dark_accent_fill_third = gx.rgb(57, 156, 210)

const included_themes = [theme_default(), theme_dark(), theme_dark_red(),
	theme_dark_green(), theme_minty(), theme_ocean()]

// Theme Manager
pub struct ThemeManager {
mut:
	all_themes []&Theme
}

pub fn ThemeManager.new() &ThemeManager {
	return &ThemeManager{
		all_themes: unsafe { included_themes }
	}
}

pub fn (mut man ThemeManager) add_theme(theme &Theme) {
	man.all_themes << theme
}

pub fn (man &ThemeManager) get_theme(name string) &Theme {
	themes := man.all_themes.filter(it.name == name)
	if themes.len == 0 {
		return get_system_theme()
	}
	return themes[0]
}

pub fn (man &ThemeManager) get_themes() []&Theme {
	return man.all_themes
}

// MenuItem in the Theme section click event
fn theme_click(mut e MouseEvent) {
	text := e.target.text
	theme := e.ctx.themes.get_theme(text)
	e.ctx.win.set_theme(theme)
}

pub fn (mut win Window) make_theme_menu() &MenuItem {
	return create_theme_menu(mut win)
}

// Make a 'Theme' menu item to select themes
pub fn create_theme_menu(mut win Window) &MenuItem {
	mut theme_menu := MenuItem.new(
		text: 'Themes'
	)

	// TODO: Add events for Theme add/change
	win.subscribe_event('window_create', fn [mut theme_menu] (mut e WindowEvent) {
		themes := e.win.graphics_context.themes.get_themes()
		for theme in themes {
			item := MenuItem.new(
				text:     theme.name
				click_fn: theme_click
			)
			theme_menu.add_child(item)
		}
	})

	return theme_menu
}

// Default Theme
pub fn get_system_theme() &Theme {
	return theme_default()
}

@[deprecated: 'Use ThemeManager']
pub fn get_all_themes() []&Theme {
	return included_themes
}

@[deprecated: 'Use ThemeManager']
pub fn theme_by_name(name string) &Theme {
	themes := get_all_themes().filter(it.name == name)
	if themes.len == 0 {
		return get_system_theme()
	}
	return themes[0]
}

pub interface UITheme {
	name        string
	accent_fill gx.Color
}

pub struct Theme implements UITheme {
pub mut:
	name string

	accent_text        gx.Color
	accent_fill        gx.Color
	accent_fill_second gx.Color
	accent_fill_third  gx.Color

	text_color gx.Color
	background gx.Color

	button_bg_normal     gx.Color
	button_bg_hover      gx.Color
	button_bg_click      gx.Color
	button_border_normal gx.Color
	button_border_hover  gx.Color
	button_border_click  gx.Color

	menubar_background  gx.Color
	menubar_border      gx.Color
	dropdown_background gx.Color
	dropdown_border     gx.Color

	textbox_background gx.Color
	textbox_border     gx.Color

	// checkbox_bg gx.Color
	scroll_track_color gx.Color
	scroll_bar_color   gx.Color

	button_fill_fn   fn (int, int, int, int, int, gx.Color, &GraphicsContext) = default_button_fill_fn
	bar_fill_fn      fn (int, f32, int, f32, bool, &GraphicsContext)          = default_bar_fill_fn
	menu_bar_fill_fn fn (int, int, int, int, &GraphicsContext)                = default_menubar_fill_fn
	setup_fn         fn (mut Window) = blank_setup
}

pub fn blank_setup(mut win Window) {
}

pub fn default_button_fill_fn(x int, y int, w int, h int, r int, bg gx.Color, ctx &GraphicsContext) {
	ctx.gg.draw_rounded_rect_filled(x, y, w, h, r, bg)
}

pub fn default_bar_fill_fn(x int, y f32, w int, h f32, hor bool, ctx &GraphicsContext) {
	ctx.win.gg.draw_rect_filled(x, y, w, h, ctx.theme.scroll_bar_color)
}

pub fn default_menubar_fill_fn(x int, y int, w int, h int, ctx &GraphicsContext) {
	ctx.gg.draw_rect_filled(x, y, w, h, ctx.theme.menubar_background)
}

//	Default Theme - Memics Windows
pub fn theme_default() &Theme {
	return &Theme{
		name: 'Default'

		accent_text:        light_accent_text
		accent_fill:        light_accent_fill
		accent_fill_second: light_accent_fill_second
		accent_fill_third:  light_accent_fill_third

		text_color:           gx.black
		background:           gx.rgb(248, 248, 248)
		button_bg_normal:     gx.rgb(255, 255, 255)
		button_bg_hover:      gx.rgb(229, 241, 251)
		button_bg_click:      gx.rgb(204, 228, 247)
		button_border_normal: gx.rgb(190, 190, 190)
		button_border_hover:  gx.rgb(0, 120, 215)
		button_border_click:  gx.rgb(0, 84, 153)
		menubar_background:   gx.white
		menubar_border:       gx.white
		dropdown_background:  gx.white
		dropdown_border:      gx.rgb(224, 224, 224)
		textbox_background:   gx.white
		textbox_border:       gx.rgb(230, 230, 230)
		scroll_track_color:   gx.rgba(238, 238, 238, 230)
		scroll_bar_color:     gx.rgb(170, 170, 170)
	}
}

//	Dark Theme
pub fn theme_dark() &Theme {
	return &Theme{
		name: 'Dark'

		accent_text:        dark_accent_text
		accent_fill:        dark_accent_fill
		accent_fill_second: dark_accent_fill_second
		accent_fill_third:  dark_accent_fill_third

		text_color:           gx.rgb(230, 230, 230)
		background:           gx.rgb(30, 30, 30)
		button_bg_normal:     gx.rgb(50, 50, 50)
		button_bg_hover:      gx.rgb(70, 70, 70)
		button_bg_click:      gx.rgb(50, 50, 50)
		button_border_normal: gx.rgb(70, 70, 70)
		button_border_hover:  gx.rgb(0, 120, 215)
		button_border_click:  gx.rgb(0, 84, 153)
		menubar_background:   gx.rgb(30, 30, 30)
		menubar_border:       gx.rgb(30, 30, 30)
		dropdown_background:  gx.rgb(10, 10, 10)
		dropdown_border:      gx.rgb(0, 0, 0)
		textbox_background:   gx.rgb(34, 39, 46)
		textbox_border:       gx.rgb(50, 50, 50)
		scroll_track_color:   gx.rgba(0, 0, 0, 190)
		scroll_bar_color:     gx.rgb(170, 170, 170)
	}
}

//	MintY - Memics LinuxMint's Default Theme
pub fn theme_minty() &Theme {
	return &Theme{
		name: 'Minty'

		accent_text:        light_accent_text
		accent_fill:        gx.rgb(154, 184, 124)
		accent_fill_second: gx.rgb(144, 174, 114)
		accent_fill_third:  gx.rgb(134, 164, 104)

		text_color:           gx.black
		background:           gx.rgb(240, 240, 240)
		button_bg_normal:     gx.rgb(245, 245, 245)
		button_bg_hover:      gx.rgb(200, 225, 190)
		button_bg_click:      gx.rgb(154, 200, 124)
		button_border_normal: gx.rgb(207, 207, 207)
		button_border_hover:  gx.rgb(181, 203, 158)
		button_border_click:  gx.rgb(0, 153, 84)
		menubar_background:   gx.rgb(245, 245, 245)
		menubar_border:       gx.rgb(242, 242, 242)
		dropdown_background:  gx.rgb(242, 242, 242)
		dropdown_border:      gx.rgb(204, 204, 204)
		textbox_background:   gx.white
		textbox_border:       gx.rgb(215, 215, 215)
		scroll_track_color:   gx.rgb(238, 238, 238)
		scroll_bar_color:     gx.rgb(181, 203, 158)
	}
}

// Dark
pub fn theme_dark_red() &Theme {
	mut th := theme_dark()
	th.name = 'Dark (Red Accent)'
	th.accent_text = gx.black
	th.accent_fill = gx.rgb(250, 0, 0)
	th.accent_fill_second = gx.rgb(200, 0, 0)
	th.accent_fill_third = gx.rgb(150, 0, 0)
	th.scroll_bar_color = gx.rgb(150, 0, 0)
	return th
}

// Dark
pub fn theme_dark_green() &Theme {
	mut th := theme_dark()
	th.name = 'Dark (Green Accent)'
	th.accent_text = gx.black
	th.accent_fill = gx.rgb(0, 250, 0)
	th.accent_fill_second = gx.rgb(0, 200, 0)
	th.accent_fill_third = gx.rgb(0, 150, 0)
	th.scroll_bar_color = gx.rgb(0, 150, 0)
	return th
}
