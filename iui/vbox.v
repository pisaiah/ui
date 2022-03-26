module iui

import gg

// VBox - implements Component interface
struct VBox {
	Component_A
pub mut:
	win            &Window
	click_event_fn fn (voidptr, voidptr)
	needs_pack     bool
	// raw_width      int
	// is_width_per   bool
	update_width bool = true
}

pub fn vbox(win &Window) &VBox {
	return &VBox{
		win: win
		click_event_fn: fn (a voidptr, b voidptr) {}
	}
}

pub fn (mut this VBox) pack() {
	this.needs_pack = true
}

/*
pub fn (mut this VBox) set_height_as_percent(flag bool, width int) {
    this.is_width_per = flag
    this.raw_height = width
}*/

pub fn (mut this VBox) draw() {
	mut o_x := 0
	mut o_y := 0

	mut width := 0

	// for mut child in this.children {
	for i in this.scroll_i .. this.children.len {
		mut child := this.children[i]
		child.draw_event_fn(this.win, &child)
		draw_with_offset(mut child, this.x + o_x, this.y + o_y)

		if this.win.bar != 0 {
			if this.win.bar.tik < 99 {
				this.is_mouse_down = false
				this.is_mouse_rele = false
			}
		}

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
				this.is_mouse_rele = false
			} else {
				child.is_mouse_down = false
				child.is_mouse_rele = false
			}
		} else {
			child.is_mouse_rele = false
		}

		o_y += child.height

		if width < child.width {
			width = child.width
		}

		size := gg.screen_size()
		if o_y > size.height {
			break
		}
	}

	// this.win.gg.draw_rect_empty(this.x, this.y, this.width, this.height, gx.blue)

	if o_y != this.height {
		this.height = o_y
	}
	if width != this.width && this.update_width {
		this.width = width
	}

	/*
	if this.needs_pack {
        this.width = width
        this.height = o_y
        this.needs_pack = false
    }*/

	// this.is_mouse_down = false
	this.is_mouse_rele = false
}
