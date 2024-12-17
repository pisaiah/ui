module iui

import gx
import sokol.sgl
import math
import gg
import os

// Struct for Graphics context
// Used in drawing methods, Ex: Component.draw(&GraphicsContext)
@[heap]
pub struct GraphicsContext {
pub mut:
	gg          &gg.Context
	theme       &Theme
	font        string
	font_size   int = 16
	line_height int
	win         &Window
	icon_cache  map[string]int
}

fn new_graphics(win &Window) &GraphicsContext {
	return &GraphicsContext{
		gg:        win.gg
		theme:     &win.theme
		font_size: win.font_size
		win:       win
	}
}

pub fn (ctx &GraphicsContext) get_icon_sheet_id() int {
	if ctx.theme.name == 'Dark (Green Accent)' {
		return ctx.icon_cache['icons_green']
	}
	if ctx.theme.name == 'Ocean' {
		return ctx.icon_cache['icons_ocean']
	}
	return ctx.icon_cache['tree_file']
}

pub fn (mut ctx GraphicsContext) fill_icon_cache(mut win Window) {
	mut tfile := $embed_file('assets/tree_file.png')
	mut tree_file := win.gg.create_image_from_memory(tfile.data(), tfile.len) or { panic(err) }

	mut green_file := $embed_file('assets/icons_green.png')
	mut green_icons := win.gg.create_image_from_memory(green_file.data(), green_file.len) or {
		panic(err)
	}

	mut ocean_file := $embed_file('assets/icons_ocean.png')
	mut ocean_icons := win.gg.create_image_from_memory(ocean_file.data(), ocean_file.len) or {
		panic(err)
	}

	mut cb_file := $embed_file('assets/check.png')
	mut cb_icons := win.gg.create_image_from_memory(cb_file.data(), cb_file.len) or { panic(err) }

	ctx.icon_cache['tree_file'] = ctx.gg.cache_image(tree_file)
	ctx.icon_cache['icons_green'] = ctx.gg.cache_image(green_icons)
	ctx.icon_cache['icons_ocean'] = ctx.gg.cache_image(ocean_icons)
	ctx.icon_cache['check_box'] = ctx.gg.cache_image(cb_icons)

	// Icon Font File
	mut font_file := $embed_file('assets/icons.ttf')
	dir := os.join_path(os.data_dir(), '.iui')
	os.mkdir(dir) or {}
	file := os.join_path(dir, 'icons.ttf')
	os.write_file_array(file, font_file.to_bytes()) or {}
	ctx.win.extra_map['icon_ttf'] = file
}

pub fn (ctx &GraphicsContext) icon_ttf_exists() bool {
	if 'icon_ttf' !in ctx.win.extra_map {
		return false
	}
	return os.exists(ctx.win.extra_map['icon_ttf'])
}

pub fn (ctx &GraphicsContext) set_cfg(cfg gx.TextCfg) {
	// cfg.family = ''
	mut cfgg := gx.TextCfg{
		...cfg
		family: ctx.font
	}

	ctx.gg.set_text_cfg(cfgg)
	$if windows {
		if ctx.gg.native_rendering {
			return
		}
	}

	// ctx.gg.ft.fons.set_font(ctx.font)
	// ctx.gg.ft.fons.set_font(ctx.gg.ft.fonts_map[ ctx.win.fonts.names[ctx.font] ])
}

pub fn (ctx &GraphicsContext) reset_text_font() {
	cfg_reset := gx.TextCfg{
		color:  ctx.theme.text_color
		size:   ctx.font_size
		family: ctx.font
	}
	ctx.gg.set_text_cfg(cfg_reset)
}

pub fn (ctx &GraphicsContext) draw_text(x int, y int, text_ string, font_id string, cfg gx.TextCfg) {
	$if windows {
		if ctx.gg.native_rendering {
			ctx.gg.draw_text(x, y, text_, cfg)
			return
		}
		$if wintxt ? {
			if text_.len > 0 {
				ctx.draw_win32_text(x, y, text_, cfg)
			}
			return
		}
	}
	scale := if ctx.gg.ft.scale == 0 { f32(1) } else { ctx.gg.ft.scale }

	cfgg := gx.TextCfg{
		...cfg
		family: font_id
	}

	ctx.gg.set_text_cfg(cfgg)

	// ctx.gg.ft.fons.set_font(font_id)
	ctx.gg.ft.fons.draw_text(x * scale, y * scale, text_)

	/*$if windows {
		win_draw_text(x, y, text_, cfg)
	}*/
}

pub fn (ctx &GraphicsContext) draw_text_ofset(x int, y int, xo int, yo int, text string, cfg gx.TextCfg) {
	$if windows {
		if ctx.gg.native_rendering {
			ctx.gg.draw_text(x, y, text, cfg)
			return
		}
	}
	scale := if ctx.gg.ft.scale == 0 { f32(1) } else { ctx.gg.ft.scale }

	ctx.gg.set_text_cfg(cfg)
	ctx.gg.ft.fons.draw_text((x * scale) + (xo * scale), (y * scale) + (yo * scale), text)

	if cfg.family != ctx.font {
		ctx.reset_text_font()
	}
}

pub fn min_h(ctx &GraphicsContext) int {
	return ctx.line_height + 9
}

pub fn (mut g GraphicsContext) calculate_line_height() {
	g.line_height = g.gg.text_height('A1!{}j;') + 2

	if g.line_height < g.font_size {
		// Fix for wasm
		$if emscripten ? {
			g.line_height = g.font_size + 2
		}
	}
}

// Functions for GG
pub fn (g &GraphicsContext) text_width(text string) int {
	$if windows {
		if g.gg.native_rendering {
			return g.gg.text_width(text)
		}
	}
	ctx := g.gg
	adv := ctx.ft.fons.text_bounds(0, 0, text, &f32(0))
	return int(adv / ctx.scale)
}

pub fn (ctx &GraphicsContext) refresh_ui() {
	mut win := ctx.win
	win.gg.refresh_ui()
}

pub fn (g &GraphicsContext) draw_bordered_rect(x int, y int, w int, h int, bg gx.Color, bord gx.Color) {
	g.gg.draw_rect_filled(x, y, w, h, bg)
	g.gg.draw_rect_empty(x, y, w, h, bord)
}

pub fn (g &GraphicsContext) draw_rounded_bordered_rect(x int, y int, w int, h int, r int, bg gx.Color, bord gx.Color) {
	g.gg.draw_rounded_rect_filled(x, y, w, h, r, bg)
	g.gg.draw_rounded_rect_empty(x, y, w, h, r, bord)
}

fn (g &GraphicsContext) draw_iconset_image(x f32, y f32, w f32, h f32, px int, py int, pw int, ph int, ro int) {
	g.gg.draw_image_with_config(gg.DrawImageConfig{
		img_id:    g.get_icon_sheet_id()
		img_rect:  gg.Rect{
			x:      x
			y:      y
			width:  w
			height: h
		}
		rotation:  ro
		part_rect: gg.Rect{px, py, pw, ph}
	})
}

// Copy from draw.c.v
pub fn (g &GraphicsContext) draw_rounded_rect_filled_top(x f32, y f32, w f32, h f32, radius f32, c gx.Color) {
	$if windows {
		if g.gg.native_rendering {
			g.gg.draw_rect_filled(x, y, w, h, c)
			return
		}
	}

	if w <= 0 || h <= 0 || radius < 0 {
		return
	}

	if c.a != 255 {
		sgl.load_pipeline(g.gg.pipeline.alpha)
	}
	sgl.c4b(c.r, c.g, c.b, c.a)

	mut new_radius := radius
	if w >= h && radius > h / 2 {
		new_radius = h / 2
	} else if radius > w / 2 {
		new_radius = w / 2
	}
	r := new_radius * g.gg.scale
	sx := x * g.gg.scale // start point x
	sy := y * g.gg.scale
	width := w * g.gg.scale
	height := h * g.gg.scale

	// circle center coordinates
	ltx := sx + r
	lty := sy + r
	rtx := sx + width - r
	rty := lty
	rbx := rtx
	rby := sy + height - r

	mut rad := f32(0)
	mut dx := f32(0)
	mut dy := f32(0)

	if r != 0 {
		// left top quarter
		sgl.begin_triangle_strip()
		for i in 0 .. 31 {
			rad = f32(math.radians(i * 3))
			dx = r * math.cosf(rad)
			dy = r * math.sinf(rad)
			sgl.v2f(ltx - dx, lty - dy)
			sgl.v2f(ltx, lty)
		}
		sgl.end()

		// right top quarter
		sgl.begin_triangle_strip()
		for i in 0 .. 31 {
			rad = f32(math.radians(i * 3))
			dx = r * math.cosf(rad)
			dy = r * math.sinf(rad)
			sgl.v2f(rtx + dx, rty - dy)
			sgl.v2f(rtx, rty)
		}
		sgl.end()
	}

	// top rectangle
	sgl.begin_quads()
	sgl.v2f(ltx, sy)
	sgl.v2f(rtx, sy)
	sgl.v2f(rtx, rty)
	sgl.v2f(ltx, lty)
	sgl.end()

	// middle & bottom rectangle
	sgl.begin_quads()
	sgl.v2f(sx, lty)
	sgl.v2f(rtx + r, rty)
	sgl.v2f(rbx + r, rby + r)
	sgl.v2f(sx, rby + r)
	sgl.end()
}

pub fn (g &GraphicsContext) draw_corner_rect(x f32, y f32, w f32, h f32, bord gx.Color, bg gx.Color) {
	g.draw_rounded_rect(x, y, w, h, control_corner_radius, bord, bg)
}

pub fn (g &GraphicsContext) draw_rounded_rect(x f32, y f32, w f32, h f32, r f32, bord gx.Color, bg gx.Color) {
	g.gg.draw_rounded_rect_filled(x, y, w, h, r, bord)
	g.gg.draw_rounded_rect_filled(x + 1, y + 1, w - 2, h - 2, r, bg)
}
