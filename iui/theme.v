// Copyright (c) 2021-2022 Isaiah.
// All Rights Reserved.
module iui

import gx

struct Theme {
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
}

//
//	Default Theme
//
pub fn theme_default() Theme {
	return Theme{
		name: 'Default'
		text_color: gx.black
		background: gx.rgb(248, 248, 248)
		button_bg_normal: gx.rgb(230, 230, 230)
		button_bg_hover: gx.rgb(229, 241, 251)
		button_bg_click: gx.rgb(204, 228, 247)
		button_border_normal: gx.rgb(180, 180, 180)
		button_border_hover: gx.rgb(0, 120, 215)
		button_border_click: gx.rgb(0, 84, 153)
		menubar_background: gx.rgb(255, 255, 255)
		menubar_border: gx.rgb(242, 242, 242)
		dropdown_background: gx.rgb(242, 242, 242)
		dropdown_border: gx.rgb(204, 204, 204)
	}
}

//
//	Dark Theme
//
pub fn theme_dark() Theme {
	return Theme{
		name: 'Dark'
		text_color: gx.rgb(240, 240, 240)
		background: gx.rgb(50, 50, 50)
		button_bg_normal: gx.rgb(10, 10, 10)
		button_bg_hover: gx.rgb(70, 70, 70)
		button_bg_click: gx.rgb(50, 50, 50)
		button_border_normal: gx.rgb(120, 120, 120)
		button_border_hover: gx.rgb(0, 120, 215)
		button_border_click: gx.rgb(0, 84, 153)
		menubar_background: gx.rgb(60, 60, 60)
		menubar_border: gx.rgb(10, 10, 10)
		dropdown_background: gx.rgb(10, 10, 10)
		dropdown_border: gx.rgb(0, 0, 0)
	}
}

//
//	Dark Theme - High Contrast
//
pub fn theme_dark_hc() Theme {
	return Theme{
		name: 'Dark High Contrast'
		text_color: gx.rgb(255, 255, 255)
		background: gx.rgb(0, 0, 0)
		button_bg_normal: gx.rgb(0, 0, 0)
		button_bg_hover: gx.rgb(70, 70, 70)
		button_bg_click: gx.rgb(50, 50, 50)
		button_border_normal: gx.rgb(220, 220, 220)
		button_border_hover: gx.rgb(100, 220, 255)
		button_border_click: gx.rgb(10, 94, 163)
		menubar_background: gx.rgb(10, 10, 10)
		menubar_border: gx.rgb(200, 200, 200)
		dropdown_background: gx.rgb(10, 10, 10)
		dropdown_border: gx.rgb(0, 0, 0)
	}
}

//
//	Black Red
//
pub fn theme_black_red() Theme {
	return Theme{
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
	}
}
