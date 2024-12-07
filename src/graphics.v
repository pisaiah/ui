module iui

import gx
import sokol.sgl
import math

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

pub fn (g &GraphicsContext) draw_rounded_rect(x f32, y f32, w f32, h f32, r f32, bord gx.Color, bg gx.Color) {
	g.gg.draw_rounded_rect_filled(x, y, w, h, r, bord)
	g.gg.draw_rounded_rect_filled(x + 1, y + 1, w - 2, h - 2, r, bg)
}
