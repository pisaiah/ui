// Copyright (c) 2021-2022 Isaiah.
module iui

import gx

// Default Blue on Windows;
// Minty (Linux Mint) on Linux/other
pub fn get_system_theme() &Theme {
	//$if windows {
	return theme_default()
	//} $else {
	// Default to Linux Mint
	//	return theme_minty()
	//}
}

pub fn get_all_themes() []&Theme {
	return [theme_default(), theme_dark(), theme_dark_hc(), theme_black_red(),
		theme_minty(), theme_black_green(), theme_ocean()]
}

pub fn theme_by_name(name string) &Theme {
	themes := get_all_themes().filter(it.name == name)
	if themes.len == 0 {
		return get_system_theme()
	}
	return themes[0]
}

pub struct Theme {
pub:
	name       string
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

	checkbox_bg       gx.Color
	checkbox_selected gx.Color

	progressbar_fill gx.Color

	scroll_track_color gx.Color
	scroll_bar_color   gx.Color

	button_fill_fn   fn (int, int, int, int, int, gx.Color, &GraphicsContext) = default_button_fill_fn
	bar_fill_fn      fn (int, f32, int, f32, bool, &GraphicsContext) = default_bar_fill_fn
	menu_bar_fill_fn fn (int, int, int, int, &GraphicsContext)       = default_menubar_fill_fn
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

//	Default Theme - Memics Windows 10
pub fn theme_default() &Theme {
	return &Theme{
		name: 'Default'
		text_color: gx.black
		background: gx.rgb(248, 248, 248)
		button_bg_normal: gx.rgb(240, 240, 240)
		button_bg_hover: gx.rgb(229, 241, 251)
		button_bg_click: gx.rgb(204, 228, 247)
		button_border_normal: gx.rgb(190, 190, 190)
		button_border_hover: gx.rgb(0, 120, 215)
		button_border_click: gx.rgb(0, 84, 153)
		menubar_background: gx.rgb(255, 255, 255)
		menubar_border: gx.rgb(255, 255, 255)
		dropdown_background: gx.rgb(255, 255, 255)
		dropdown_border: gx.rgb(224, 224, 224)
		textbox_background: gx.rgb(255, 255, 255)
		textbox_border: gx.rgb(215, 215, 215)
		checkbox_selected: gx.rgb(37, 161, 218)
		checkbox_bg: gx.rgb(254, 254, 254)
		progressbar_fill: gx.rgb(37, 161, 218)
		scroll_track_color: gx.rgb(238, 238, 238)
		scroll_bar_color: gx.rgb(170, 170, 170)
	}
}

//	Dark Theme
pub fn theme_dark() &Theme {
	return &Theme{
		name: 'Dark'
		text_color: gx.rgb(230, 230, 230)
		background: gx.rgb(30, 30, 30)
		button_bg_normal: gx.rgb(10, 10, 10)
		button_bg_hover: gx.rgb(70, 70, 70)
		button_bg_click: gx.rgb(50, 50, 50)
		button_border_normal: gx.rgb(130, 130, 130)
		button_border_hover: gx.rgb(0, 120, 215)
		button_border_click: gx.rgb(0, 84, 153)
		menubar_background: gx.rgb(30, 30, 30)
		menubar_border: gx.rgb(30, 30, 30)
		dropdown_background: gx.rgb(10, 10, 10)
		dropdown_border: gx.rgb(0, 0, 0)
		textbox_background: gx.rgb(34, 39, 46)
		textbox_border: gx.rgb(130, 130, 130)
		checkbox_selected: gx.rgb(240, 99, 40)
		checkbox_bg: gx.rgb(5, 5, 5)
		progressbar_fill: gx.rgb(130, 130, 130)
		scroll_track_color: gx.rgb(0, 0, 0)
		scroll_bar_color: gx.rgb(170, 170, 170)
	}
}

//	Dark Theme - High Contrast
pub fn theme_dark_hc() &Theme {
	return &Theme{
		name: 'Dark Black'
		text_color: gx.rgb(255, 255, 255)
		background: gx.rgb(0, 0, 0)
		button_bg_normal: gx.rgb(0, 0, 0)
		button_bg_hover: gx.rgb(70, 70, 70)
		button_bg_click: gx.rgb(50, 50, 50)
		button_border_normal: gx.rgb(220, 220, 220)
		button_border_hover: gx.rgb(100, 220, 255)
		button_border_click: gx.rgb(10, 94, 163)
		menubar_background: gx.rgb(10, 10, 10)
		menubar_border: gx.rgb(99, 99, 99)
		dropdown_background: gx.rgb(10, 10, 10)
		dropdown_border: gx.rgb(0, 0, 0)
		textbox_background: gx.rgb(0, 0, 0)
		textbox_border: gx.rgb(200, 200, 200)
		checkbox_selected: gx.rgb(220, 220, 220)
		checkbox_bg: gx.rgb(0, 0, 0)
		scroll_track_color: gx.rgb(0, 0, 0)
		scroll_bar_color: gx.rgb(205, 205, 205)
	}
}

//	Black Red
pub fn theme_black_red() &Theme {
	return &Theme{
		name: 'Black Red'
		text_color: gx.rgb(255, 255, 255)
		background: gx.rgb(0, 0, 0)
		button_bg_normal: gx.rgb(0, 0, 0)
		button_bg_hover: gx.rgb(70, 0, 0)
		button_bg_click: gx.rgb(40, 0, 0)
		button_border_normal: gx.rgb(255, 0, 0)
		button_border_hover: gx.rgb(230, 10, 15)
		button_border_click: gx.rgb(150, 0, 0)
		menubar_background: gx.rgb(10, 10, 10)
		menubar_border: gx.rgb(160, 0, 0)
		dropdown_background: gx.rgb(160, 0, 0)
		dropdown_border: gx.rgb(0, 0, 0)
		textbox_background: gx.rgb(0, 0, 0)
		textbox_border: gx.rgb(200, 0, 0)
		checkbox_selected: gx.rgb(255, 0, 0)
		checkbox_bg: gx.rgb(0, 0, 0)
		scroll_track_color: gx.rgb(0, 0, 0)
		scroll_bar_color: gx.rgb(240, 0, 0)
	}
}

//	MintY - Memics LinuxMint's Default Theme
pub fn theme_minty() &Theme {
	return &Theme{
		name: 'Minty'
		text_color: gx.black
		background: gx.rgb(240, 240, 240)
		button_bg_normal: gx.rgb(245, 245, 245)
		button_bg_hover: gx.rgb(200, 225, 190)
		button_bg_click: gx.rgb(154, 200, 124)
		button_border_normal: gx.rgb(207, 207, 207)
		button_border_hover: gx.rgb(181, 203, 158)
		button_border_click: gx.rgb(0, 153, 84)
		menubar_background: gx.rgb(245, 245, 245)
		menubar_border: gx.rgb(242, 242, 242)
		dropdown_background: gx.rgb(242, 242, 242)
		dropdown_border: gx.rgb(204, 204, 204)
		textbox_background: gx.rgb(255, 255, 255)
		textbox_border: gx.rgb(215, 215, 215)
		checkbox_selected: gx.rgb(154, 184, 124)
		checkbox_bg: gx.rgb(247, 247, 247)
		scroll_track_color: gx.rgb(238, 238, 238)
		scroll_bar_color: gx.rgb(181, 203, 158)
	}
}

// Black Green
pub fn theme_black_green() &Theme {
	return &Theme{
		name: 'Green Mono'
		text_color: gx.rgb(200, 255, 200)
		background: gx.rgb(0, 0, 0)
		button_bg_normal: gx.rgb(0, 0, 0)
		button_bg_hover: gx.rgb(0, 70, 0)
		button_bg_click: gx.rgb(0, 40, 0)
		button_border_normal: gx.rgb(0, 255, 0)
		button_border_hover: gx.rgb(10, 230, 15)
		button_border_click: gx.rgb(0, 150, 0)
		menubar_background: gx.rgb(10, 10, 10)
		menubar_border: gx.rgb(0, 160, 0)
		dropdown_background: gx.rgb(0, 160, 0)
		dropdown_border: gx.rgb(0, 0, 0)
		textbox_background: gx.rgb(0, 0, 0)
		textbox_border: gx.rgb(0, 200, 0)
		checkbox_selected: gx.rgb(0, 255, 0)
		checkbox_bg: gx.rgb(0, 0, 0)
		scroll_track_color: gx.rgb(0, 0, 0)
		scroll_bar_color: gx.rgb(0, 220, 0)
	}
}
