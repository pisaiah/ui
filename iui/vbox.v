module iui

import gg
import gx

// VBox - implements Component interface
pub struct VBox {
	Component_A
pub mut:
	win            &Window
	click_event_fn fn (voidptr, voidptr)
	needs_pack     bool
	overflow       bool = true
	update_width   bool = true
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

pub fn (mut this VBox) draw(ctx &GraphicsContext) {
	mut o_x := 0
	mut o_y := 0

	mut width := 0

	max_scroll := this.children.len - 1
	if this.scroll_i > max_scroll {
		this.scroll_i = max_scroll
	}

	mut hidden_height := 0

	for i in 0 .. this.scroll_i {
		mut child := this.children[i]
		child.ry = -999
		hidden_height += child.height + child.y
	}

	for i in this.scroll_i .. this.children.len {
		if i < 0 {
			continue
		}
		mut child := this.children[i]
		child.draw_event_fn(mut this.win, &child)

		ypos := this.y + o_y //- (this.scroll_i*8)
		if ypos < this.y {
			o_y += child.height
			child.ry = -999
			continue
		}

		if !this.overflow && (ypos + child.height) > this.y + this.height {
			continue
		}

		this.win.draw_with_offset(mut child, this.x + o_x, ypos)

		if this.win.bar != unsafe { nil } {
			if this.win.bar.tik < 99 {
				this.is_mouse_down = false
				this.is_mouse_rele = false
			}
		}

		o_y += child.height + child.y

		if width < (child.width + child.x) {
			width = (child.width + child.x)
		}

		size := gg.window_size()
		if o_y > size.height {
			break
		}
	}

	if o_y != this.height && this.overflow {
		this.height = o_y + hidden_height + this.children.len
	}
	if width >= this.width && this.update_width {
		this.width = width
	}

	/*
	if this.needs_pack {
        this.width = width
        this.height = o_y
        this.needs_pack = false
    }*/

	// this.is_mouse_down = false
	// this.is_mouse_rele = false
	if this.win.debug_draw {
		this.win.gg.draw_rect_empty(this.x, this.y, this.width, this.height, gx.orange)
	}
}
