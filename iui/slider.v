module iui

import gg
import math

// Slider - implements Component interface
pub struct Slider {
	Component_A
pub mut:
	win         &Window
	text        string
	min         f32
	cur         f32
	max         f32
	flip        bool
	dir         Direction
	last_s      int
	hide        bool
	scroll      bool
	thumb_wid   int
	thumb_color gg.Color
}

pub fn (mut this Slider) set_custom_thumb_color(color gg.Color) {
	this.thumb_color = color
}

pub enum Direction {
	hor
	vert
}

// Return new Slider
pub fn slider(win &Window, min f32, max f32, dir Direction) &Slider {
	mut slid := &Slider{
		win: win
		text: 'TEST'
		min: min
		max: max
		dir: dir
		scroll: true
		thumb_wid: 30
		thumb_color: gg.Color{0, 0, 0, 0}
	}

	// go test(mut slid)
	return slid
}

// Draw this component
pub fn (mut this Slider) draw(ctx &GraphicsContext) {
	if this.hide {
		return
	}

	if this.is_mouse_down {
		if this.dir == .hor {
			mut cx := math.clamp(this.win.mouse_x - this.x, 0, this.width)
			mut perr := cx / this.width
			perr = perr * this.max
			this.cur = f32(perr)
		} else {
			mut cx := math.clamp(this.win.mouse_y - this.y, 0, this.height)
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
		mut wid := (this.width * per)
		wid -= per * this.thumb_wid

		// Horizontal
		this.win.draw_bordered_rect(this.x, this.y, this.width, this.height, 8, ctx.theme.scroll_track_color,
			ctx.theme.button_border_normal)
		ctx.gg.draw_rounded_rect_filled(this.x + wid, this.y, this.thumb_wid, this.height,
			16, thumb_color)
	} else {
		mut wid := (this.height * per)
		wid -= per * this.thumb_wid

		// Vertical
		this.win.draw_filled_rect(this.x, this.y, this.width, this.height, 1, ctx.theme.scroll_track_color,
			ctx.theme.button_border_normal)
		ctx.gg.draw_rounded_rect_filled(this.x, this.y + wid, this.width, this.thumb_wid,
			8, ctx.theme.scroll_bar_color)
		ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, ctx.theme.button_border_normal)
	}
}
