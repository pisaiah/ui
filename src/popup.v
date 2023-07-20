module iui

import gg

struct Popup {
	Component_A
mut:
	shown bool
}

fn (mut this Popup) draw(ctx &GraphicsContext) {
	ctx.gg.draw_rect_filled(this.x, this.y, this.width, this.height, ctx.theme.button_bg_normal)
	ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, ctx.theme.button_border_normal)

	mut y := this.y
	for mut child in this.children {
		child.draw_with_offset(ctx, this.x, y)
		if this.width < child.width {
			this.width = child.width
		}
		y += child.height
	}
}

// https://docs.oracle.com/javase/8/docs/api/javax/swing/JPopupMenu.html#show-java.awt.Component-int-int-
fn (mut this Popup) show(invoker &Component, x int, y int, ctx &GraphicsContext) {
	this.x = invoker.x + x
	this.y = invoker.y + y

	// this.is_mouse_rele = false
	this.shown = true
	if ctx.win.popups.len > 0 {
		return
	}
	ctx.win.add_popup(this)
}

fn (mut this Popup) hide(ctx &GraphicsContext) {
	mut win := ctx.win
	this.shown = false
	win.popups = win.popups.filter(it.x != this.x && it.y != this.y)
}
