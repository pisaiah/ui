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
		ctx.gg.draw_rect_empty(x, y, w, h, gx.rgb(99, 130, 191))
		ctx.gg.draw_image_by_id(x, y, w - 1, h, id)
	} else {
		ctx.gg.draw_rect_empty(x, y, w, h + 1, gx.rgb(99, 130, 191))
		ctx.gg.draw_image_by_id(x - 1, y, w + 2, h, id)
	}
}

pub fn ocean_menubar_fill_fn(x int, y int, w int, h int, ctx &GraphicsContext) {
	ctx.gg.draw_image_by_id(x, y, w, h, ctx.icon_cache['ocean-menu'])
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
		ww := (w + 2) / 2
		ctx.gg.draw_rect_filled(x, y, w + 2, h, gx.rgb(238, 238, 238))
		ctx.gg.draw_rect_filled(x + ww, y, ww + 1, h, gx.rgb(214, 214, 214))
		ctx.gg.draw_rect_empty(x, y, w + 2, h, ctx.theme.scroll_bar_color)
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

pub fn seven_dark_setup(mut win Window) {
	mut ctx := win.graphics_context

	mut img0 := $embed_file('assets/theme/7d/btn.png')
	cache_image('seven_dark-btn', mut ctx, img0.data(), img0.len)

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
		w2 := w + 2
		ww := w2 / 2
		ctx.gg.draw_rect_filled(x, y, ww, h, gx.rgb(80, 80, 80))
		ctx.gg.draw_rect_filled(x + ww, y, ww, h, gx.rgb(37, 37, 37))
		ctx.gg.draw_rect_empty(x, y, w2, h, ctx.theme.scroll_bar_color)
	}
}

pub fn seven_dark_menubar_fill_fn(x1 int, y int, w int, h int, ctx &GraphicsContext) {
	ctx.gg.draw_image_by_id(x1, y, w, h + 1, ctx.icon_cache['seven_dark-menu'])
}

fn (ctx &GraphicsContext) draw_linear_gradient_vert(x int, y int, width int, height int, start_color gx.Color, end_color gx.Color) {
    for i in 0 .. height {
        t := f32(i) / f32(height)
        r := u8(lerp(f32(start_color.r), f32(end_color.r), t))
        g := u8(lerp(f32(start_color.g), f32(end_color.g), t))
        b := u8(lerp(f32(start_color.b), f32(end_color.b), t))
        color := gx.Color{r: r, g: g, b: b}
        ctx.gg.draw_rect_filled(x, y + i, width, 1, color)
    }
}

fn lerp(a f32, b f32, t f32) f32 {
    return a + t * (b - a)
}