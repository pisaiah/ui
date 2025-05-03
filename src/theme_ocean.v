module iui

import gx

// Ocean - A Cross Platform Theme
pub fn theme_ocean() &Theme {
	mut th := theme_default()
	th.name = 'Ocean'
	th.accent_fill = gx.rgb(143, 184, 218)
	th.button_fill_fn = ocean_button_fill_fn
	th.bar_fill_fn = ocean_bar_fill_fn
	th.setup_fn = ocean_setup
	th.menu_bar_fill_fn = ocean_menubar_fill_fn

	return th
}

pub fn cache_image(id string, mut g GraphicsContext, buf &u8, bufsize int) int {
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
