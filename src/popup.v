module iui

pub struct Popup implements Container {
	Component_A
pub mut:
	shown             bool
	animate           bool
	at                int
	container_pass_ev bool = true
	keep_alive        int
}

pub fn (mut p Popup) set_animate(val bool) {
	p.animate = val
}

@[params]
pub struct PopupCfg {
}

pub fn Popup.new(c PopupCfg) &Popup {
	return &Popup{}
}

fn (mut p Popup) animate_to(y int) {
	if p.y < y {
		p.y += 1
	}
}

fn (mut p Popup) note_keep_alive() {
	p.keep_alive = 1
}

fn (mut p Popup) draw(ctx &GraphicsContext) {
	if !p.container_pass_ev {
		p.is_mouse_down = false
		p.is_mouse_rele = false
	}

	if p.keep_alive > 10 {
		// Timeout
		p.hide(ctx)
	}

	if p.keep_alive > 0 {
		p.keep_alive += 1
	}

	ws := ctx.gg.window_size()
	mut y := p.y - p.at

	ctx.gg.scissor_rect(0, p.y, ws.width, ws.height)

	ctx.gg.draw_rect_filled(p.x, y, p.width, p.height, ctx.theme.button_bg_normal)
	ctx.gg.draw_rect_empty(p.x, y, p.width, p.height, ctx.theme.button_border_normal)

	if p.at > 0 {
		p.container_pass_ev = false
		p.at -= (p.at / 4)
		if p.at < 4 {
			p.at -= 1
		}
	} else {
		p.container_pass_ev = true
	}

	for mut child in p.children {
		if y >= p.y || true {
			child.draw_with_offset(ctx, p.x, y)
		}
		if p.width < child.width {
			p.width = child.width
		}
		y += child.height + child.y
	}
	ctx.gg.scissor_rect(0, 0, ws.width, ws.height)
}

// https://docs.oracle.com/javase/8/docs/api/javax/swing/JPopupMenu.html#show-java.awt.Component-int-int-
pub fn (mut this Popup) show(invoker &Component, x int, y int, ctx &GraphicsContext) {
	this.x = invoker.x + x

	if this.animate {
		this.y = invoker.y + y
		this.at = y
	} else {
		this.y = invoker.y + y
	}

	unsafe {
		this.parent = &Component_A(invoker)
	}
	for mut child in this.children {
		if isnil(child.parent) {
			// child.parent = &Component_A(p)
			child.set_parent(this)
		}
	}

	// this.is_mouse_rele = false
	this.shown = true
	if ctx.win.popups.len > 0 {
		return
	}
	ctx.win.add_popup(this)
}

pub fn (mut this Popup) hide(ctx &GraphicsContext) {
	mut win := ctx.win
	this.shown = false
	win.popups = win.popups.filter(it.x != this.x && it.y != this.y)
}

pub fn (mut this Popup) is_shown(ctx &GraphicsContext) bool {
	if ctx.win.popups.len == 0 {
		this.shown = false
		return false
	}
	return this.shown
}
