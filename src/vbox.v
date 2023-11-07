module iui

import gg
import gx

// VBox - implements Component interface
pub struct VBox {
	Component_A
pub mut:
	needs_pack   bool
	overflow     bool = true
	update_width bool = true
}

[params]
pub struct VBoxConfig {
	pack     bool
	overflow bool = true
	bounds   Bounds
}

pub fn VBox.new(c VBoxConfig) &VBox {
	return &VBox{
		needs_pack: c.pack
		overflow: c.overflow
		x: c.bounds.x
		y: c.bounds.y
		width: c.bounds.width
		height: c.bounds.height
	}
}

pub fn (mut this VBox) pack() {
	this.needs_pack = true
}

pub fn (mut this VBox) draw(ctx &GraphicsContext) {
	mut o_x := 0
	mut o_y := 0

	mut width := 0

	this.scroll_i = 0

	for i in this.scroll_i .. this.children.len {
		if i < 0 {
			continue
		}
		mut child := this.children[i]
		if !isnil(child.draw_event_fn) {
			// deprecated draw fn
			mut win := ctx.win
			child.draw_event_fn(mut win, &child)
		}

		ypos := this.y + o_y
		if ypos < this.y {
			o_y += child.height
			child.ry = -999
			continue
		}

		if !this.overflow && (ypos + child.height) > this.y + this.height {
			continue
		}

		child.draw_with_offset(ctx, this.x + o_x, ypos)

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
		this.height = o_y + this.children.len
	}
	if width >= this.width && this.update_width {
		this.width = width
	}

	if ctx.win.debug_draw {
		ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, gx.orange)
	}
}
