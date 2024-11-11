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
	thumb_color ?gg.Color
	last_scroll int
}

pub fn (mut s Slider) switch_dir() {
	if s.dir == .vert {
		s.dir = .hor
	} else {
		s.dir = .vert
	}

	w := s.width
	h := s.height
	s.width = h
	s.height = w
}

pub fn (mut this Slider) set_custom_thumb_color(color gg.Color) {
	this.thumb_color = color
}

pub fn (s &Slider) get_thumb_color() ?gg.Color {
	return s.thumb_color
}

// Direction of the Slider
pub enum Direction {
	hor
	vert
}

// Slider Config
@[params]
pub struct SliderConfig {
pub:
	min         int
	max         int
	dir         Direction
	thumb_color ?gg.Color
}

pub fn Slider.new(c SliderConfig) &Slider {
	return &Slider{
		text:        ''
		min:         c.min
		max:         c.max
		dir:         c.dir
		scroll:      true
		thumb_wid:   30
		thumb_color: c.thumb_color
	}
}

pub fn (mut s Slider) pack() {
	s.width = 0
	s.height = 0
}

pub fn (mut s Slider) pack_do(g &GraphicsContext) {
	// Note: values taken from default JSlider size
	if s.dir == .vert {
		s.width = 16
		s.height = 200
	} else {
		s.width = 200
		s.height = 16
	}
}

// Draw this component
pub fn (mut this Slider) draw(ctx &GraphicsContext) {
	if this.hide {
		return
	}

	if this.width == 0 && this.height == 0 {
		this.pack_do(ctx)
	}

	if this.is_mouse_down {
		this.on_mouse_down(ctx)
	}

	if this.is_mouse_rele {
		this.is_mouse_down = false
		this.is_mouse_rele = false
	}

	// Scroll
	if this.scroll {
		diff := abs(this.scroll_i) // + 1
		if this.last_scroll != diff {
			new_val := f32(math.clamp(diff, this.min, this.max))
			if this.cur != new_val {
				this.cur = new_val
				invoke_slider_change(this, ctx, new_val)
			}
			this.last_scroll = diff
		} else {
			this.scroll_i = int(this.cur)
			this.last_scroll = int(this.cur)
		}
	}

	per := this.cur / this.max

	thumb_color := this.thumb_color or { ctx.theme.scroll_bar_color }

	if this.dir == .hor {
		wid := (this.width * per) - per * this.thumb_wid
		this.draw_hor(ctx, wid, thumb_color)
	} else {
		wid := (this.height * per) - per * this.thumb_wid
		this.draw_vert(ctx, wid, thumb_color)
	}
}

fn (mut s Slider) on_mouse_down(g &GraphicsContext) {
	if s.dir == .hor {
		cx := math.clamp(g.win.mouse_x - s.x, 0, s.width)
		new_val := f32((cx * s.max) / s.width)
		if s.cur != new_val {
			s.cur = new_val
			invoke_slider_change(s, g, new_val)
		}
	} else {
		cx := math.clamp(g.win.mouse_y - s.y, 0, s.height)
		new_val := f32((cx * s.max) / s.height)
		if s.cur != new_val {
			s.cur = new_val
			invoke_slider_change(s, g, new_val)
		}
	}
	s.scroll_i = int(s.cur)
}

fn (s &Slider) draw_hor(g &GraphicsContext, wid f32, thumb_color gg.Color) {
	hei := s.height
	g.draw_rounded_bordered_rect(s.x, s.y, s.width, hei, 8, g.theme.scroll_track_color,
		g.theme.button_border_normal)
	g.gg.draw_rounded_rect_filled(s.x + wid, s.y, s.thumb_wid, hei, 16, thumb_color)
}

fn (s &Slider) draw_vert(g &GraphicsContext, wid f32, color gg.Color) {
	g.draw_bordered_rect(s.x, s.y, s.width, s.height, g.theme.scroll_track_color, g.theme.button_border_normal)
	g.gg.draw_rounded_rect_filled(s.x, s.y + wid, s.width, s.thumb_wid, 8, color)
	g.gg.draw_rect_empty(s.x, s.y, s.width, s.height, g.theme.button_border_normal)
}
