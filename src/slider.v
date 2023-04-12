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

pub fn new_slider(cfg SliderConfig) &Slider {
	mut slid := &Slider{
		text: ''
		min: cfg.min
		max: cfg.max
		dir: cfg.dir
		scroll: true
		thumb_wid: 30
		thumb_color: cfg.thumb_color
	}

	return slid
}

pub fn slider(cfg SliderConfig) &Slider {
	return new_slider(cfg)
}

// Draw this component
pub fn (mut this Slider) draw(ctx &GraphicsContext) {
	if this.hide {
		return
	}

	if this.is_mouse_down {
		if this.dir == .hor {
			mut cx := math.clamp(ctx.win.mouse_x - this.x, 0, this.width)
			mut perr := cx / this.width
			perr = perr * this.max
			this.cur = f32(perr)
		} else {
			mut cx := math.clamp(ctx.win.mouse_y - this.y, 0, this.height)
			mut perr := cx / this.height
			perr = perr * this.max
			this.cur = f32(perr)
		}
		this.scroll_i = int(this.cur)
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

		// Horizontal
		hei := this.height
		ctx.win.draw_bordered_rect(this.x, this.y, this.width, hei, 8, ctx.theme.scroll_track_color,
			ctx.theme.button_border_normal)
		ctx.gg.draw_rounded_rect_filled(this.x + wid, this.y, this.thumb_wid, hei, 16,
			thumb_color)
	} else {
		wid := (this.height * per) - per * this.thumb_wid

		// Vertical
		ctx.win.draw_filled_rect(this.x, this.y, this.width, this.height, 1, ctx.theme.scroll_track_color,
			ctx.theme.button_border_normal)
		ctx.gg.draw_rounded_rect_filled(this.x, this.y + wid, this.width, this.thumb_wid,
			8, ctx.theme.scroll_bar_color)
		ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, ctx.theme.button_border_normal)
	}
}
