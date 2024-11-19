module iui

import gx

// Ocean - A Cross Platform Theme
pub fn theme_ocean() &Theme {
	mut light := theme_default()
	light.name = 'Ocean'
	light.accent_fill = gx.rgb(143, 184, 218)
	light.button_fill_fn = ocean_button_fill_fn
	light.bar_fill_fn = ocean_bar_fill_fn
	light.setup_fn = ocean_setup
	light.menu_bar_fill_fn = ocean_menubar_fill_fn

	return light
}

fn cache_image(id string, mut g GraphicsContext, buf &u8, bufsize int) int {
	mut img := g.gg.create_image_from_memory(buf, bufsize) or { panic(err) }
	if img.simg.id == 0 && g.line_height > 0 {
		img.init_sokol_image()
	}
	val := g.gg.cache_image(img)
	g.icon_cache[id] = val
	return val
}

pub fn ocean_setup(mut win Window) {
	mut g := win.graphics_context
	mut img0 := $embed_file('assets/theme/ocean-btn.png')
	cache_image('ocean-btn', mut g, img0.data(), img0.len)
}

pub fn ocean_button_fill_fn(x int, y int, w int, h int, r int, bg gx.Color, g &GraphicsContext) {
	if bg == g.theme.button_bg_normal {
		g.gg.draw_image_by_id(x, y, w, h, g.icon_cache['ocean-btn'])
	} else {
		g.gg.draw_rounded_rect_filled(x, y, w, h, r, bg)
	}
}

pub fn ocean_bar_fill_fn(x int, y f32, w int, h f32, hor bool, g &GraphicsContext) {
	if hor {
		new_x := x + (w / 2) - (h / 2)
		new_y := y + (h / 2) - (w / 2)
		g.draw_iconset_image(new_x, new_y, h, w, 64, 0, 16, 2, -90)
	} else {
		g.draw_iconset_image(x, y, w, h, 64, 0, 16, 1, 0)
	}
	g.gg.draw_rect_empty(x, y, w, h, gx.rgb(99, 130, 191))
}

pub fn ocean_menubar_fill_fn(x int, y int, w int, h int, g &GraphicsContext) {
	g.draw_iconset_image(x, y, w + 1, h, 81, 0, 5, 24, 0)
}

// Seven
pub fn theme_seven() &Theme {
	mut light := theme_default()
	light.name = 'Seven'
	light.accent_fill = gx.rgb(143, 184, 218)
	light.button_fill_fn = seven_button_fill_fn
	light.bar_fill_fn = seven_bar_fill_fn
	light.setup_fn = seven_setup
	light.menu_bar_fill_fn = seven_menubar_fill_fn
	return light
}

// Seven Dark
pub fn theme_seven_dark() &Theme {
	mut light := theme_dark()
	light.name = 'Seven Dark'
	light.accent_fill = gx.rgb(143, 184, 218)
	light.button_fill_fn = seven_dark_button_fill_fn
	light.bar_fill_fn = seven_dark_bar_fill_fn
	light.setup_fn = seven_dark_setup
	light.menu_bar_fill_fn = seven_dark_menubar_fill_fn
	return light
}

pub fn seven_setup(mut win Window) {
	mut g := win.graphics_context

	mut img0 := $embed_file('assets/theme/7/btn.png')
	cache_image('seven-btn', mut g, img0.data(), img0.len)
}

pub fn seven_button_fill_fn(x int, y int, w int, h int, r int, bg gx.Color, g &GraphicsContext) {
	if bg == g.theme.button_bg_normal {
		g.gg.draw_image_by_id(x, y, w, h, g.icon_cache['seven-btn'])
	} else {
		g.gg.draw_rounded_rect_filled(x, y, w, h, r, bg)
	}
}

pub fn seven_bar_fill_fn(x int, y f32, w int, h f32, hor bool, g &GraphicsContext) {
	hh := if hor { h / 2 } else { h }
	ww := if hor { w } else { w / 2 }

	g.gg.draw_rect_filled(x, y, w, hh, gx.rgb(238, 238, 238))

	if hor {
		g.gg.draw_rect_filled(x, y + hh, ww, hh, gx.rgb(214, 214, 214))
	} else {
		g.gg.draw_rect_filled(x + ww, y, ww, hh, gx.rgb(214, 214, 214))
	}

	g.gg.draw_rect_empty(x, y, w + 1, h, g.theme.scroll_bar_color)
}

pub fn seven_menubar_fill_fn(x int, y int, w int, h int, g &GraphicsContext) {
	yy := y + 8
	hh := (h - 8) / 4
	g.gg.draw_rect_filled(x, y, w, h, gx.rgb(244, 244, 244))
	g.gg.draw_rect_filled(x, yy + hh, w, hh, gx.rgb(239, 239, 239))
	g.gg.draw_rect_filled(x, yy + (hh + hh), w, hh, gx.rgb(233, 233, 233))
	g.gg.draw_rect_filled(x, yy + (hh * 3), w, hh, gx.rgb(228, 228, 228))
}

pub fn seven_dark_setup(mut win Window) {
	mut ctx := win.graphics_context

	mut img0 := $embed_file('assets/theme/7d/btn.png')
	cache_image('seven_dark-btn', mut ctx, img0.data(), img0.len)

	mut img2 := $embed_file('assets/theme/7d/menu.png')
	cache_image('seven_dark-menu', mut ctx, img2.data(), img2.len)
}

pub fn seven_dark_button_fill_fn(x int, y int, w int, h int, r int, bg gx.Color, g &GraphicsContext) {
	if bg == g.theme.button_bg_normal {
		g.gg.draw_image_by_id(x, y, w, h, g.icon_cache['seven_dark-btn'])
	} else {
		g.gg.draw_rounded_rect_filled(x, y, w, h, r, bg)
	}
}

pub fn seven_dark_bar_fill_fn(x int, y f32, w int, h f32, hor bool, g &GraphicsContext) {
	hh := if hor { h / 2 } else { h }
	ww := if hor { w } else { w / 2 }

	g.gg.draw_rect_filled(x, y, w, hh, gx.rgb(80, 80, 80))

	if hor {
		g.gg.draw_rect_filled(x, y + hh, ww, hh, gx.rgb(37, 37, 37))
	} else {
		g.gg.draw_rect_filled(x + ww, y, ww, hh, gx.rgb(37, 37, 37))
	}

	g.gg.draw_rect_empty(x, y, w, h, g.theme.scroll_bar_color)
}

pub fn seven_dark_menubar_fill_fn(x1 int, y int, w int, h int, g &GraphicsContext) {
	g.gg.draw_image_by_id(x1, y, w, h + 1, g.icon_cache['seven_dark-menu'])
}
