module iui

import gg
import gx

// HBox - implements Component interface
@[heap]
pub struct HBox {
	Component_A
pub mut:
	needs_pack    bool
	raw_width     int
	is_width_per  bool
	center_screen bool
	min_height    int
	overflow_full bool = true
}

@[params]
pub struct HBoxConfig {
pub:
	pack          bool
	overflow      bool = true
	bounds        Bounds
	center_screen bool
}

pub fn HBox.new(cfg HBoxConfig) &HBox {
	return &HBox{
		center_screen: cfg.center_screen
		needs_pack:    cfg.pack
		overflow_full: cfg.overflow
		x:             cfg.bounds.x
		y:             cfg.bounds.y
		width:         cfg.bounds.width
		height:        cfg.bounds.height
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
		if this.parent == unsafe { nil } {
			size := gg.window_size()
			box_width = int((size.width) * (f32(this.raw_width) / 100))
			this.width = box_width
		} else {
			size := this.parent
			box_width = int((size.width) * (f32(this.raw_width) / 100))
			this.width = box_width
		}
	}

	mut width := 0
	mut index := 0

	mut yyy := 0

	for mut child in this.children {
		if !isnil(child.draw_event_fn) {
			// deprecated draw fn
			mut win := ctx.win
			child.draw_event_fn(mut win, &child)
		}

		gw := if this.overflow_full {
			o_x + child.width > box_width
		} else {
			o_x + (child.width / 2) > box_width
		}

		if gw && !this.needs_pack {
			if o_x > width {
				width = o_x
			}
			o_x = 0

			o_y += yyy + 2
		}

		if yyy < child.y + child.height {
			yyy = child.y + child.height
		}

		child.draw_with_offset(ctx, this.x + o_x, this.y + o_y)

		o_x += child.x + child.width
		index += 1

		if index == this.children.len {
			o_y += child.y + child.height
		}
		if yyy < child.height {
			yyy = child.y + child.height
		}
	}
	yyy += 1

	if yyy != this.height {
		this.height = yyy
	}
	this.height = o_y

	if this.needs_pack {
		this.width = o_x
		if yyy > this.min_height {
			this.height = yyy
		} else {
			this.height = this.min_height
		}
		this.needs_pack = false
	}

	if this.height < this.min_height && this.min_height > 0 {
		this.height = this.min_height
	}

	if this.center_screen {
		size := ctx.gg.window_size()

		wid := this.width
		this.x = (size.width / 2) - (wid / 2)
	}

	if ctx.win.debug_draw {
		ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, gx.red)
		ctx.gg.draw_line(this.x, this.y, this.x + this.width, this.y + this.height, gx.red)
	}
}
