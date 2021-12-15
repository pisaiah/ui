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

	textbox_background gx.Color
	textbox_border     gx.Color

	checkbox_bg       gx.Color
	checkbox_selected gx.Color

	progressbar_fill gx.Color
}

//
//	Default Theme - Memics Windows 10
//
pub fn theme_default() Theme {
	return Theme{
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
		menubar_border: gx.rgb(250, 250, 250)
		dropdown_background: gx.rgb(242, 242, 242)
		dropdown_border: gx.rgb(224, 224, 224)
		textbox_background: gx.rgb(255, 255, 255)
		textbox_border: gx.rgb(215, 215, 215)
		checkbox_selected: gx.rgb(37, 161, 218)
		checkbox_bg: gx.rgb(254, 254, 254)
		progressbar_fill: gx.rgb(81, 180, 225)
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
		button_border_normal: gx.rgb(130, 130, 130)
		button_border_hover: gx.rgb(0, 120, 215)
		button_border_click: gx.rgb(0, 84, 153)
		menubar_background: gx.rgb(60, 60, 60)
		menubar_border: gx.rgb(10, 10, 10)
		dropdown_background: gx.rgb(10, 10, 10)
		dropdown_border: gx.rgb(0, 0, 0)
		textbox_background: gx.rgb(10, 10, 10)
		textbox_border: gx.rgb(130, 130, 130)
		checkbox_selected: gx.rgb(130, 130, 130)
		checkbox_bg: gx.rgb(5, 5, 5)
		progressbar_fill: gx.rgb(130, 130, 130)
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
		textbox_background: gx.rgb(0, 0, 0)
		textbox_border: gx.rgb(200, 200, 200)
		checkbox_selected: gx.rgb(220, 220, 220)
		checkbox_bg: gx.rgb(0, 0, 0)
		progressbar_fill: gx.rgb(220, 220, 220)
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
		textbox_background: gx.rgb(0, 0, 0)
		textbox_border: gx.rgb(200, 0, 0)
		checkbox_selected: gx.rgb(255, 0, 0)
		checkbox_bg: gx.rgb(0, 0, 0)
		progressbar_fill: gx.rgb(255, 0, 0)
	}
}

//
//	MintY - Memics LinuxMint's Default Theme
//
pub fn theme_minty() Theme {
	return Theme{
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
		progressbar_fill: gx.rgb(154, 184, 124)
	}
}
