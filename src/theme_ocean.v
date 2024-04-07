module iui

import gx

//	Ocean - A Cross Platform Theme
pub fn theme_ocean() &Theme {
	return &Theme{
		name: 'Ocean'
		text_color: gx.black
		background: gx.rgb(240, 240, 240)
		button_bg_normal: gx.rgb(240, 240, 240)
		button_bg_hover: gx.rgb(229, 241, 251)
		button_bg_click: gx.rgb(204, 228, 247)
		button_border_normal: gx.rgb(135, 145, 155)
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

fn cache_image(id string, mut ctx GraphicsContext, buf &u8, bufsize int) int {
	mut img := ctx.gg.create_image_from_memory(buf, bufsize) or { panic(err) }
	if img.simg.id == 0 && ctx.line_height > 0 {
		img.init_sokol_image()
	}
	val := ctx.gg.cache_image(img)
	ctx.icon_cache[id] = val
	return val
}

pub fn ocean_setup(mut win Window) {
	mut ctx := win.graphics_context

	mut img0 := $embed_file('assets/theme/ocean-btn.png')
	cache_image('ocean-btn', mut ctx, img0.data(), img0.len)

	mut img1 := $embed_file('assets/theme/ocean-bar.png')
	cache_image('ocean-bar', mut ctx, img1.data(), img1.len)

	mut img2 := $embed_file('assets/theme/ocean-menu.png')
	cache_image('ocean-menu', mut ctx, img2.data(), img2.len)

	mut img3 := $embed_file('assets/theme/ocean-bar-w.png')
	cache_image('ocean-bar-w', mut ctx, img3.data(), img3.len)
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

	mut img0 := $embed_file('assets/theme/7/btn.png')
	cache_image('seven-btn', mut ctx, img0.data(), img0.len)
}

pub fn seven_button_fill_fn(x int, y int, w int, h int, r int, bg gx.Color, ctx &GraphicsContext) {
	if bg == ctx.theme.button_bg_normal {
		ctx.gg.draw_image_by_id(x, y, w, h, ctx.icon_cache['seven-btn'])
	} else {
		ctx.gg.draw_rounded_rect_filled(x, y, w, h, r, bg)
	}
}

pub fn seven_bar_fill_fn(x int, y f32, w int, h f32, hor bool, ctx &GraphicsContext) {
	if hor {
		hh := h / 2
		ctx.gg.draw_rect_filled(x, y, w, hh, gx.rgb(238, 238, 238))
		ctx.gg.draw_rect_filled(x, y + hh, w, hh, gx.rgb(214, 214, 214))
		ctx.gg.draw_rect_empty(x, y, w, h, ctx.theme.scroll_bar_color)
	} else {
		xx := x - 1
		ww := (w + 2) / 2
		ctx.gg.draw_rect_filled(xx, y, w + 3, h, gx.rgb(238, 238, 238))
		ctx.gg.draw_rect_filled(xx + ww, y, ww + 1, h, gx.rgb(214, 214, 214))
		ctx.gg.draw_rect_empty(xx, y, w + 3, h, gx.rgb(99, 130, 191))
	}
}

pub fn seven_menubar_fill_fn(x int, y int, w int, h int, ctx &GraphicsContext) {
	yy := y + 8
	hh := (h - 8) / 4
	ctx.gg.draw_rect_filled(x, y, w, h, gx.rgb(244, 244, 244))
	ctx.gg.draw_rect_filled(x, yy + hh, w, hh, gx.rgb(239, 239, 239))
	ctx.gg.draw_rect_filled(x, yy + (hh + hh), w, hh, gx.rgb(233, 233, 233))
	ctx.gg.draw_rect_filled(x, yy + (hh * 3), w, hh, gx.rgb(228, 228, 228))
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

	mut img0 := $embed_file('assets/theme/7d/btn.png')
	cache_image('seven_dark-btn', mut ctx, img0.data(), img0.len)

	mut img1 := $embed_file('assets/theme/7d/bar.png')
	cache_image('seven_dark-bar', mut ctx, img1.data(), img1.len)

	mut img2 := $embed_file('assets/theme/7d/menu.png')
	cache_image('seven_dark-menu', mut ctx, img2.data(), img2.len)
}

pub fn seven_dark_button_fill_fn(x int, y int, w int, h int, r int, bg gx.Color, ctx &GraphicsContext) {
	if bg == ctx.theme.button_bg_normal {
		ctx.gg.draw_image_by_id(x, y, w, h, ctx.icon_cache['seven_dark-btn'])
	} else {
		ctx.gg.draw_rounded_rect_filled(x, y, w, h, r, bg)
	}
}

pub fn seven_dark_bar_fill_fn(x int, y f32, w int, h f32, hor bool, ctx &GraphicsContext) {
	if hor {
		hh := h / 2
		ctx.gg.draw_rect_filled(x, y, w, hh, gx.rgb(80, 80, 80))
		ctx.gg.draw_rect_filled(x, y + hh, w, hh, gx.rgb(37, 37, 37))
		ctx.gg.draw_rect_empty(x, y, w, h, ctx.theme.scroll_bar_color)
	} else {
		id := ctx.icon_cache['seven_dark-bar']
		ctx.gg.draw_image_by_id(x - 2, y, w + 5, h, id)
		ctx.gg.draw_rect_empty(x - 2, y, w + 5, h, ctx.theme.scroll_bar_color)
	}
}

pub fn seven_dark_menubar_fill_fn(x int, y int, w int, h int, ctx &GraphicsContext) {
	ctx.gg.draw_image_by_id(x, y, w, h + 1, ctx.icon_cache['seven_dark-menu'])
}
