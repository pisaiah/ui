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
		thumb_wid:   24
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
		s.width = 20
		s.height = 200
		s.thumb_wid = s.width
	} else {
		s.width = 200
		s.height = 20
		s.thumb_wid = s.height
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

	if ctx.theme.name == 'Ocean' {
		this.thumb_wid = 16
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

const slider_radius = 32

fn (s &Slider) ocean_theme_test(g &GraphicsContext, x f32, y f32, ro int) {
	g.gg.draw_image_with_config(gg.DrawImageConfig{
		img_id:    g.get_icon_sheet_id()
		img_rect:  gg.Rect{
			x:      x
			y:      y
			width:  16
			height: 16
		}
		rotation:  ro
		part_rect: gg.Rect{32 * 1, 32 * 0, 16, 16}
	})
}

fn (s &Slider) draw_hor(g &GraphicsContext, wid f32, thumb_color gg.Color) {
	hei := s.thumb_wid
	color := s.thumb_color or { g.theme.accent_fill }
	line_height := s.height / 4
	line_y := s.y + (s.height / 2) - (line_height / 2)

	g.gg.draw_rounded_rect_filled(s.x, line_y, s.width, line_height, 8, g.theme.scroll_bar_color)
	g.gg.draw_rounded_rect_filled(s.x, line_y, wid + 4, line_height, 8, color)

	cut := if s.is_mouse_down {
		5
	} else if is_in(s, g.win.mouse_x, g.win.mouse_y) {
		3
	} else {
		4
	}

	if g.theme.name == 'Ocean' {
		s.ocean_theme_test(g, s.x + wid, s.y + 2, 0)
		return
	}

	y := s.y + (s.height / 2) - (s.thumb_wid / 2)
	g.gg.draw_rounded_rect_filled(s.x + wid, y, s.thumb_wid, hei, slider_radius, g.theme.textbox_border)
	g.gg.draw_rounded_rect_empty(s.x + wid, y, s.thumb_wid, hei, slider_radius, g.theme.button_border_normal)
	g.gg.draw_rounded_rect_filled(s.x + wid + cut, y + cut, s.thumb_wid - cut * 2, hei - cut * 2,
		slider_radius, color)
}

fn (s &Slider) draw_vert(g &GraphicsContext, wid f32, thumb_color gg.Color) {
	hei := s.thumb_wid
	color := s.thumb_color or { g.theme.accent_fill }
	line_width := s.width / 4
	line_x := s.x + (s.width / 2) - (line_width / 2)

	g.gg.draw_rounded_rect_filled(line_x, s.y, line_width, s.height, 8, g.theme.scroll_bar_color)
	g.gg.draw_rounded_rect_filled(line_x, s.y, line_width, wid + 4, 8, color)

	if g.theme.name == 'Ocean' {
		s.ocean_theme_test(g, s.x + 2, s.y + wid, 90)
		return
	}

	cut := if s.is_mouse_down {
		5
	} else if is_in(s, g.win.mouse_x, g.win.mouse_y) {
		3
	} else {
		4
	}

	x := s.x + (s.width / 2) - (s.thumb_wid / 2)

	g.gg.draw_rounded_rect_filled(x, s.y + wid, s.thumb_wid, hei, slider_radius, g.theme.textbox_border)
	g.gg.draw_rounded_rect_empty(x, s.y + wid, s.thumb_wid, hei, slider_radius, g.theme.button_border_normal)
	g.gg.draw_rounded_rect_filled(x + cut, s.y + wid + cut, s.thumb_wid - cut * 2, hei - cut * 2,
		slider_radius, color)
}

fn (s &Slider) draw_vert_old(g &GraphicsContext, wid f32, color gg.Color) {
	g.draw_bordered_rect(s.x, s.y, s.width, s.height, g.theme.scroll_track_color, g.theme.button_border_normal)
	g.gg.draw_rounded_rect_filled(s.x, s.y + wid, s.width, s.thumb_wid, 8, color)
	g.gg.draw_rect_empty(s.x, s.y, s.width, s.height, g.theme.button_border_normal)
}
