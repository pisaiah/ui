module themes

import gx
import iui as ui

// Dark RGB
pub fn theme_dark_rgb() &ui.Theme {
	mut th := ui.theme_dark()
	th.name = 'Dark (RGB)'
	th.accent_text = gx.black
	th.accent_fill = gx.rgb(255, 0, 0)
	th.accent_fill_second = gx.rgb(200, 0, 0)
	th.accent_fill_third = gx.rgb(200, 0, 0)
	th.setup_fn = rgb_setup
	return th
}

fn darker(c gx.Color, mut theme ui.Theme) {
	f1 := .8
	f2 := .6
	theme.accent_fill_second.r = u8(f32(c.r) * f1)
	theme.accent_fill_second.g = u8(f32(c.g) * f1)
	theme.accent_fill_second.b = u8(f32(c.b) * f1)
	theme.accent_fill_third.r = u8(f32(c.r) * f2)
	theme.accent_fill_third.g = u8(f32(c.g) * f2)
	theme.accent_fill_third.b = u8(f32(c.b) * f2)
	theme.scroll_bar_color.r = u8(f32(c.r) * f2)
	theme.scroll_bar_color.g = u8(f32(c.g) * f2)
	theme.scroll_bar_color.b = u8(f32(c.b) * f2)
}

pub fn rgb_setup(mut win ui.Window) {
	win.theme.accent_fill = gx.rgb(0, 0, 0)
	win.subscribe_event('draw', rgb_animate_colors)
}

fn rgb_animate_colors(mut e ui.WindowDrawEvent) {
	mut theme_pointer := e.win.graphics_context.theme
	next_rgb_color(mut theme_pointer)
}

fn next_rgb_color(mut th ui.Theme) {
	if th.accent_fill.g < 255 && th.accent_fill.r == 255 && th.accent_fill.b == 0 {
		th.accent_fill.g++
	} else if th.accent_fill.g == 255 && th.accent_fill.r > 0 && th.accent_fill.b == 0 {
		th.accent_fill.r--
	} else if th.accent_fill.g == 255 && th.accent_fill.r == 0 && th.accent_fill.b < 255 {
		th.accent_fill.b++
	} else if th.accent_fill.g > 0 && th.accent_fill.r == 0 && th.accent_fill.b == 255 {
		th.accent_fill.g--
	} else if th.accent_fill.g == 0 && th.accent_fill.r < 255 && th.accent_fill.b == 255 {
		th.accent_fill.r++
	} else if th.accent_fill.g == 0 && th.accent_fill.r == 255 && th.accent_fill.b > 0 {
		th.accent_fill.b--
	}
	darker(th.accent_fill, mut th)
}
