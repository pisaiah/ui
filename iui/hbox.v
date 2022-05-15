module iui

import gg
import gx

// HBox - implements Component interface
struct HBox {
	Component_A
pub mut:
	win            &Window
	click_event_fn fn (voidptr, voidptr)
	needs_pack     bool
	raw_width      int
	is_width_per   bool
	center_screen  bool
	min_height     int
}

pub fn hbox(win &Window) &HBox {
	return &HBox{
		win: win
		click_event_fn: fn (a voidptr, b voidptr) {}
	}
}

pub fn (mut this HBox) pack() {
	this.needs_pack = true
}

pub fn (mut this HBox) set_min_height(val int) {
	this.min_height = val
}

pub fn (mut this HBox) set_width_as_percent(flag bool, width int) {
	this.is_width_per = flag
	this.raw_width = width
}

pub fn (mut this HBox) draw(ctx &GraphicsContext) {
	mut o_x := 0
	mut o_y := 0

	mut box_width := this.width
	if this.is_width_per {
		size := gg.window_size()
		box_width = int((size.width) * (f32(this.raw_width) / 100))
		this.width = box_width
	}

	mut width := 0
	mut index := 0

	mut yyy := 0

	for mut child in this.children {
		if yyy < child.height {
			yyy = child.height
		}
		child.draw_event_fn(this.win, child)
		if (o_x + child.width > box_width) && !this.needs_pack {
			if o_x > width {
				width = o_x
			}
			o_x = 0

			o_y += yyy + 2
		}

		child.draw_with_offset(ctx, this.x + o_x, this.y + o_y)

		o_x += child.x + child.width
		index += 1

		if index == this.children.len {
			o_y += child.height
		}
		if yyy < child.height {
			yyy = child.height
		}
	}
	yyy += 1

	if yyy != this.height {
		this.height = yyy
	}

	if this.needs_pack {
		this.width = o_x
		if yyy > this.min_height {
			this.height = yyy
		} else {
			this.height = this.min_height
		}
		this.needs_pack = false
	}

	if this.height < this.min_height {
		this.height = this.min_height
	}

	if this.center_screen {
		size := ctx.gg.window_size()

		wid := this.width
		this.x = (size.width / 2) - (wid / 2)
	}

	if this.win.debug_draw {
		this.win.gg.draw_rect_empty(this.x, this.y, this.width, this.height, gx.red)
		this.win.gg.draw_line(this.x, this.y, this.x + this.width, this.y + this.height,
			gx.red)
	}
}
