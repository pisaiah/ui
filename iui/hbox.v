module iui

import gg
// import gx

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

pub fn (mut this HBox) set_width_as_percent(flag bool, width int) {
	this.is_width_per = flag
	this.raw_width = width
}

pub fn (mut this HBox) draw() {
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

	for mut child in this.children {
		child.draw_event_fn(this.win, child)
		if o_x + child.width > box_width {
			if o_x > width {
				width = o_x
			}
			o_x = 0
			o_y += child.height
		}

		draw_with_offset(mut child, this.x + o_x, this.y + o_y)

		if this.is_mouse_down {
			if point_in_raw(mut child, this.win.click_x, this.win.click_y) {
				child.is_mouse_down = true
			} else {
				child.is_mouse_down = false
			}
		} else {
			child.is_mouse_down = false
		}
		if this.is_mouse_rele {
			if point_in_raw(mut child, this.win.mouse_x, this.win.mouse_y) {
				child.is_mouse_rele = true
			} else {
				child.is_mouse_down = false
				child.is_mouse_rele = false
			}
		} else {
			child.is_mouse_rele = false
		}

		o_x += child.width
		index += 1

		if index == this.children.len {
			o_y += child.height
		}
	}

	// this.win.gg.draw_rect_empty(this.x, this.y, this.width, this.height, gx.blue)

	if o_y != this.height {
		this.height = o_y
	}

	if this.needs_pack {
		this.width = o_x
		this.height = o_y
		this.needs_pack = false
	}

	this.is_mouse_rele = false

	if this.center_screen {
		size := this.win.gg.window_size()

		wid := this.width
		this.x = (size.width / 2) - (wid / 2)
	}
}
