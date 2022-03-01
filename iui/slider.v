module iui

import gg
import time
import math

// Slider - implements Component interface
struct Slider {
	Component_A
pub mut:
	win    &Window
	text   string
	min    f32
	cur    f32
	max    f32
	flip   bool
	dir    Direction
	last_s int
	hide   bool
	scroll bool
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
	}

	// go test(mut slid)
	return slid
}

fn test(mut this Slider) {
	for true {
		if this.flip {
			this.cur -= 1
		} else {
			this.cur += 1
		}
		if this.cur >= this.max {
			this.flip = true
		}
		if this.cur <= this.min {
			this.flip = false
		}
		time.sleep(10 * time.millisecond)
	}
}

// Draw this component
pub fn (mut this Slider) draw() {
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
	}

	// TODO: Scroll for .hor
	if this.last_s != this.scroll_i && this.dir == .vert && this.scroll {
		mut pos := this.scroll_i > this.last_s
		mut diff := abs(this.scroll_i - this.last_s) + 1

		if pos {
			this.cur += diff
		} else {
			this.cur -= diff
		}
		this.cur = f32(math.clamp(this.cur, this.min, this.max))

		this.last_s = this.scroll_i
	}

	mut per := this.cur / this.max

	if this.dir == .hor {
		mut wid := (this.width * per)
		wid -= per * 20

		// Horizontal
		this.win.draw_filled_rect(this.x, this.y, this.width, this.height, 1, this.win.theme.scroll_track_color,
			this.win.theme.button_border_normal)
		this.win.gg.draw_rect_filled(this.x + wid, this.y, 20, this.height, this.win.theme.scroll_bar_color)
		this.win.gg.draw_rect_empty(this.x, this.y, this.width, this.height, this.win.theme.button_border_normal)
	} else {
		mut wid := (this.height * per)
		wid -= per * 20

		// Vertical
		this.win.draw_filled_rect(this.x, this.y, this.width, this.height, 1, this.win.theme.scroll_track_color,
			this.win.theme.button_border_normal)
		this.win.gg.draw_rect_filled(this.x, this.y + wid, this.width, 20, this.win.theme.scroll_bar_color)
		this.win.gg.draw_rect_empty(this.x, this.y, this.width, this.height, this.win.theme.button_border_normal)
	}
}
