module iui

import gg
import math

// Slider - implements Component interface
pub struct Slider {
	Component_A
pub mut:
	min         f32
	cur         f32
	max         f32
	dir         Direction
	hide        bool
	scroll      bool
	thumb_wid   int
	thumb_color gg.Color
}

pub fn (mut this Slider) set_custom_thumb_color(color gg.Color) {
	this.thumb_color = color
}

// Direction of the Slider
pub enum Direction {
	hor
	vert
}

// Slider Config
[params]
pub struct SliderConfig {
	min         int
	max         int
	dir         Direction
	thumb_color gg.Color = gg.Color{0, 0, 0, 0}
}

pub fn Slider.new(c SliderConfig) &Slider {
	return &Slider{
		text: ''
		min: c.min
		max: c.max
		dir: c.dir
		scroll: true
		thumb_wid: 30
		thumb_color: c.thumb_color
	}
}

[deprecated: 'Use Slider.new']
pub fn slider(cfg SliderConfig) &Slider {
	return Slider.new(cfg)
}

// Draw this component
pub fn (mut this Slider) draw(ctx &GraphicsContext) {
	if this.hide {
		return
	}

	if this.is_mouse_down {
		this.on_mouse_down(ctx)
	}

	if this.is_mouse_rele {
		this.is_mouse_down = false
		this.is_mouse_rele = false
	}

	// TODO: Scroll for .hor
	if this.dir == .vert && this.scroll {
		diff := abs(this.scroll_i) + 1

		this.cur = diff
		this.cur = f32(math.clamp(this.cur, this.min, this.max))
	}

	mut per := this.cur / this.max

	thumb_color := if this.thumb_color.a > 0 { this.thumb_color } else { ctx.theme.scroll_bar_color }

	if this.dir == .hor {
		wid := (this.width * per) - per * this.thumb_wid
		this.draw_hor(ctx, wid, thumb_color)
	} else {
		wid := (this.height * per) - per * this.thumb_wid
		this.draw_vert(ctx, wid)
	}
}

fn (mut s Slider) on_mouse_down(g &GraphicsContext) {
	if s.dir == .hor {
		cx := math.clamp(g.win.mouse_x - s.x, 0, s.width)
		s.cur = f32((cx * s.max) / s.width)
	} else {
		cx := math.clamp(g.win.mouse_y - s.y, 0, s.height)
		s.cur = f32((cx * s.max) / s.height)
	}
	s.scroll_i = int(s.cur)
}

fn (s &Slider) draw_hor(g &GraphicsContext, wid f32, thumb_color gg.Color) {
	hei := s.height
	g.win.draw_bordered_rect(s.x, s.y, s.width, hei, 8, g.theme.scroll_track_color, g.theme.button_border_normal)
	g.gg.draw_rounded_rect_filled(s.x + wid, s.y, s.thumb_wid, hei, 16, thumb_color)
}

fn (s &Slider) draw_vert(g &GraphicsContext, wid f32) {
	g.draw_bordered_rect(s.x, s.y, s.width, s.height, g.theme.scroll_track_color, g.theme.button_border_normal)
	g.gg.draw_rounded_rect_filled(s.x, s.y + wid, s.width, s.thumb_wid, 8, g.theme.scroll_bar_color)
	g.gg.draw_rect_empty(s.x, s.y, s.width, s.height, g.theme.button_border_normal)
}
