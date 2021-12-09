module main

import gx

struct Theme {
	text_color           gx.Color
	background           gx.Color
	button_bg_normal     gx.Color
	button_bg_hover      gx.Color
    button_bg_click      gx.Color
	button_border_normal gx.Color
	button_border_hover  gx.Color
    button_border_click  gx.Color
    menubar_background   gx.Color
    menubar_border       gx.Color
}

// Default Theme
pub fn theme_default() Theme {
	return Theme{
		text_color: gx.black
		background: gx.rgb(248,248,248)
		button_bg_normal: gx.rgb(230, 230, 230)
		button_bg_hover: gx.rgb(229, 241, 251)
        button_bg_click: gx.rgb(204, 228, 247)
		button_border_normal: gx.rgb(180, 180, 180)
		button_border_hover: gx.rgb(0, 120, 215)
        button_border_click: gx.rgb(0,84, 153)
        menubar_background: gx.rgb(255,255,255)
        menubar_border: gx.rgb(242,242,242)
	}
}

// Dark Theme
pub fn theme_dark() Theme {
	return Theme{
		text_color: gx.rgb(240, 240, 240)
		background: gx.rgb(50, 50, 50)
		button_bg_normal: gx.rgb(10, 10, 10)
		button_bg_hover: gx.rgb(70, 70, 70)
        button_bg_click: gx.rgb(50,50,50)
		button_border_normal: gx.rgb(120, 120, 120)
		button_border_hover: gx.rgb(0, 120, 215)
        button_border_click: gx.rgb(0, 84, 153)
        menubar_background: gx.rgb(60,60,60)
        menubar_border: gx.rgb(10,10,10)
	}
}