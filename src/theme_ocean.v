module iui

import gx
import gg

//	Ocean - A Cross Platform Theme
pub fn theme_ocean() &Theme {
	return &Theme{
		name: 'Ocean'
		text_color: gx.black
		background: gx.rgb(238, 238, 238)
		button_bg_normal: gx.rgb(240, 240, 240)
		button_bg_hover: gx.rgb(229, 241, 251)
		button_bg_click: gx.rgb(204, 228, 247)
		button_border_normal: gx.rgb(135, 145, 155) // gx.rgb(190, 190, 190)
		button_border_hover: gx.rgb(0, 120, 215)
		button_border_click: gx.rgb(0, 84, 153)
		menubar_background: gx.rgb(255, 255, 255)
		menubar_border: gx.rgb(255, 255, 255)
		dropdown_background: gx.rgb(255, 255, 255)
		dropdown_border: gx.rgb(224, 224, 224)
		textbox_background: gx.rgb(255, 255, 255)
		textbox_border: gx.rgb(200, 200, 200)
		checkbox_selected: gx.rgb(143, 184, 218)
		checkbox_bg: gx.rgb(254, 254, 254)
		progressbar_fill: gx.rgb(143, 184, 210)
		scroll_track_color: gx.rgb(238, 238, 238)
		scroll_bar_color: gx.rgb(170, 170, 170)
		button_fill_fn: ocean_button_fill_fn
		bar_fill_fn: ocean_bar_fill_fn
		setup_fn: ocean_setup
		menu_bar_fill_fn: ocean_menubar_fill_fn
	}
}

pub fn ocean_setup(mut win Window) {
	mut ctx := win.graphics_context
	mut o_file := $embed_file('assets/theme/ocean-btn.png')
	mut o_icons := win.create_gg_image(o_file.data(), o_file.len)
	ctx.icon_cache['ocean-btn'] = win.gg.cache_image(o_icons)

	mut o_file1 := $embed_file('assets/theme/ocean-bar.png')
	o_icons = win.create_gg_image(o_file1.data(), o_file1.len)
	ctx.icon_cache['ocean-bar'] = ctx.gg.cache_image(o_icons)

	mut o_file2 := $embed_file('assets/theme/ocean-menu.png')
	o_icons = win.create_gg_image(o_file2.data(), o_file2.len)
	ctx.icon_cache['ocean-menu'] = ctx.gg.cache_image(o_icons)

	mut o_file3 := $embed_file('assets/theme/ocean-bar-w.png')
	o_icons = win.create_gg_image(o_file3.data(), o_file3.len)
	ctx.icon_cache['ocean-bar-w'] = ctx.gg.cache_image(o_icons)
}

pub fn ocean_button_fill_fn(x int, y int, w int, h int, r int, bg gx.Color, ctx &GraphicsContext) {
	if bg == ctx.theme.button_bg_normal {
		ctx.gg.draw_image_by_id(x, y, w, h, ctx.icon_cache['ocean-btn'])
	} else {
		ctx.gg.draw_rounded_rect_filled(x, y, w, h, r, bg)
	}
}

pub fn ocean_bar_fill_fn(x int, y f32, w int, h f32, hor bool, ctx &GraphicsContext) {
	id := if hor { ctx.icon_cache['ocean-bar-w'] } else { ctx.icon_cache['ocean-bar'] }

	if hor {
		ctx.gg.draw_image_by_id(x, y - 2, w, h + 4, id)
		ctx.gg.draw_rect_empty(x, y - 2, w, h + 4, gx.rgb(99, 130, 191))
	} else {
		ctx.gg.draw_image_by_id(x - 2, y, w + 4, h, id)
		ctx.gg.draw_rect_empty(x - 2, y, w + 4, h, gx.rgb(99, 130, 191))
	}
}

pub fn ocean_menubar_fill_fn(x int, y int, w int, h int, ctx &GraphicsContext) {
	ctx.gg.draw_image_by_id(x, y, w, h + 1, ctx.icon_cache['ocean-menu'])
}

// Seven - Memic windows 7
pub fn theme_seven() &Theme {
	return &Theme{
		name: 'Seven'
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
		textbox_border: gx.rgb(200, 200, 200)
		checkbox_selected: gx.rgb(30, 160, 220)
		checkbox_bg: gx.rgb(254, 254, 254)
		progressbar_fill: gx.rgb(143, 184, 210)
		scroll_track_color: gx.rgb(238, 238, 238)
		scroll_bar_color: gx.rgb(170, 170, 170)
		button_fill_fn: seven_button_fill_fn
		bar_fill_fn: seven_bar_fill_fn
		setup_fn: seven_setup
		menu_bar_fill_fn: seven_menubar_fill_fn
	}
}

pub fn seven_setup(mut win Window) {
	mut ctx := win.graphics_context
	mut o_file := $embed_file('assets/theme/7/btn.png')
	mut o_icons := win.create_gg_image(o_file.data(), o_file.len)
	ctx.icon_cache['seven-btn'] = win.gg.cache_image(o_icons)

	mut o_file1 := $embed_file('assets/theme/7/bar.png')
	o_icons = win.create_gg_image(o_file1.data(), o_file1.len)
	ctx.icon_cache['seven-bar'] = ctx.gg.cache_image(o_icons)

	mut o_file2 := $embed_file('assets/theme/7/menu.png')
	o_icons = win.create_gg_image(o_file2.data(), o_file2.len)
	ctx.icon_cache['seven-menu'] = ctx.gg.cache_image(o_icons)

	mut o_file3 := $embed_file('assets/theme/7/barw.png')
	o_icons = win.create_gg_image(o_file3.data(), o_file3.len)
	ctx.icon_cache['seven-bar-w'] = ctx.gg.cache_image(o_icons)
}

pub fn seven_button_fill_fn(x int, y int, w int, h int, r int, bg gx.Color, ctx &GraphicsContext) {
	if bg == ctx.theme.button_bg_normal {
		ctx.gg.draw_image_by_id(x, y, w, h, ctx.icon_cache['seven-btn'])
	} else {
		ctx.gg.draw_rounded_rect_filled(x, y, w, h, r, bg)
	}
}

pub fn seven_bar_fill_fn(x int, y f32, w int, h f32, hor bool, ctx &GraphicsContext) {
	id := if hor { ctx.icon_cache['seven-bar-w'] } else { ctx.icon_cache['seven-bar'] }

	if hor {
		ctx.gg.draw_image_by_id(x, y - 2, w, h + 4, id)
		ctx.gg.draw_rect_empty(x, y - 2, w, h + 4, gx.rgb(99, 130, 191))
	} else {
		ctx.gg.draw_image_by_id(x - 2, y, w + 5, h, id)
		ctx.gg.draw_rect_empty(x - 2, y, w + 4, h, gx.rgb(99, 130, 191))
	}
}

pub fn seven_menubar_fill_fn(x int, y int, w int, h int, ctx &GraphicsContext) {
	ctx.gg.draw_image_by_id(x, y, w, h + 1, ctx.icon_cache['seven-menu'])
}

// Seven - Memic windows 7
pub fn theme_seven_dark() &Theme {
	return &Theme{
		name: 'Seven Dark'
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
		dropdown_background: gx.rgb(20, 20, 20)
		dropdown_border: gx.rgb(90, 90, 90)
		textbox_background: gx.rgb(34, 39, 46)
		textbox_border: gx.rgb(130, 130, 130)
		checkbox_selected: gx.rgb(240, 99, 40)
		checkbox_bg: gx.rgb(5, 5, 5)
		progressbar_fill: gx.rgb(130, 130, 130)
		scroll_track_color: gx.rgb(0, 0, 0)
		scroll_bar_color: gx.rgb(170, 170, 170)
		button_fill_fn: seven_dark_button_fill_fn
		bar_fill_fn: seven_dark_bar_fill_fn
		setup_fn: seven_dark_setup
		menu_bar_fill_fn: seven_dark_menubar_fill_fn
	}
}

pub fn seven_dark_setup(mut win Window) {
	mut ctx := win.graphics_context
	mut o_file := $embed_file('assets/theme/7d/btn.png')
	mut o_icons := win.create_gg_image(o_file.data(), o_file.len)
	ctx.icon_cache['seven_dark-btn'] = win.gg.cache_image(o_icons)

	mut o_file1 := $embed_file('assets/theme/7d/bar.png')
	o_icons = win.create_gg_image(o_file1.data(), o_file1.len)
	ctx.icon_cache['seven_dark-bar'] = ctx.gg.cache_image(o_icons)

	mut o_file2 := $embed_file('assets/theme/7d/menu.png')
	o_icons = win.create_gg_image(o_file2.data(), o_file2.len)
	ctx.icon_cache['seven_dark-menu'] = ctx.gg.cache_image(o_icons)

	mut o_file3 := $embed_file('assets/theme/7d/barw.png')
	o_icons = win.create_gg_image(o_file3.data(), o_file3.len)
	ctx.icon_cache['seven_dark-bar-w'] = ctx.gg.cache_image(o_icons)
}

pub fn seven_dark_button_fill_fn(x int, y int, w int, h int, r int, bg gx.Color, ctx &GraphicsContext) {
	if bg == ctx.theme.button_bg_normal {
		ctx.gg.draw_image_by_id(x, y, w, h, ctx.icon_cache['seven_dark-btn'])
	} else {
		ctx.gg.draw_rounded_rect_filled(x, y, w, h, r, bg)
	}
}

pub fn seven_dark_bar_fill_fn(x int, y f32, w int, h f32, hor bool, ctx &GraphicsContext) {
	id := if hor { ctx.icon_cache['seven_dark-bar-w'] } else { ctx.icon_cache['seven_dark-bar'] }

	if hor {
		ctx.gg.draw_image_by_id(x, y - 2, w, h + 4, id)
		ctx.gg.draw_rect_empty(x, y - 2, w, h + 4, ctx.theme.scroll_bar_color)
	} else {
		ctx.gg.draw_image_by_id(x - 1, y, w + 3, h, id)
		ctx.gg.draw_rect_empty(x - 2, y, w + 5, h, ctx.theme.scroll_bar_color)
	}
}

pub fn seven_dark_menubar_fill_fn(x int, y int, w int, h int, ctx &GraphicsContext) {
	ctx.gg.draw_image_by_id(x, y, w, h + 1, ctx.icon_cache['seven_dark-menu'])
}
