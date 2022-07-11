module iui

import math

// ScrollView Component
//
// Implementation Details:
//	https://docs.oracle.com/javase/8/docs/api/javax/swing/JScrollPane.html
//	https://docs.oracle.com/javase/tutorial/uiswing/components/scrollpane.html
//	https://javatpoint.com/java-jscrollpane
pub struct ScrollView {
	Component_A
pub mut:
	increment int = 4
	in_scroll bool
}

[params]
pub struct ScrollViewConfig {
pub mut:
	bounds    Bounds
	view      &Component
	increment int = 4
}

pub fn scroll_view(cfg ScrollViewConfig) &ScrollView {
	scroll_view := &ScrollView{
		x: cfg.bounds.x
		y: cfg.bounds.y
		width: cfg.bounds.width
		height: cfg.bounds.height
		children: [cfg.view]
		increment: cfg.increment
	}
	return scroll_view
}

// Notes: https://bit.ly/javadoc-JScrollPane-setViewportView-Component
pub fn (mut this ScrollView) set_view(com &Component) {
	this.add_child(com)
}

// Notes: JScrollPane.setUnitIncrement
pub fn (mut this ScrollView) set_increment(value int) {
	this.increment = value
}

// Draw
pub fn (mut this ScrollView) draw(ctx &GraphicsContext) {
	x := this.x
	y := this.y

	// Set Scissor
	ctx.gg.scissor_rect(x, y, this.width, this.height)

	total_height := this.draw_children(ctx)

	this.clamp_scroll_index(total_height)

	ctx.gg.draw_rect_empty(x, y, this.width, this.height, ctx.theme.scroll_bar_color)
	this.draw_scrollbar(ctx, this.height, total_height)

	// Reset Scissor
	ws := ctx.gg.window_size()
	ctx.gg.scissor_rect(0, 0, ws.width, ws.height)
}

// Draw the children
pub fn (mut this ScrollView) draw_children(ctx &GraphicsContext) int {
	mut y_pos := this.y - (this.scroll_i * this.increment)
	mut total_height := 0

	for mut child in this.children {
		if child.parent == unsafe { nil } {
			child.parent = this
		}

		// Override child's scroll index;
		// TODO: Not do this.
		child.scroll_i = 0

		child.draw_event_fn(ctx.win, child)
		child.draw_with_offset(ctx, this.x, y_pos)
		child.after_draw_event_fn(ctx.win, child)

		y_pos += child.y + child.height
		total_height += child.y + child.height
	}
	return total_height
}

fn (mut this ScrollView) clamp_scroll_index(total_height int) {
	if total_height > this.height {
		scroll := (this.scroll_i * this.increment)
		current := this.height + scroll
		max := total_height

		if current > max {
			a := total_height / this.increment
			b := this.height / this.increment
			this.scroll_i = a - b
		}
	} else {
		this.scroll_i = 0
	}
}

fn (mut this ScrollView) draw_scrollbar(ctx &GraphicsContext, cl int, spl_len int) {
	xx := if this.rx != 0 { this.rx } else { this.x }
	y := if this.rx != 0 { this.ry } else { this.y }

	x := xx + this.width - 15

	// Scroll Bar
	scroll := this.scroll_i * this.increment
	bar_height := this.height - 35

	sth := int((f32(scroll) / f32(spl_len)) * bar_height)
	enh := int((f32(cl) / f32(spl_len)) * bar_height)
	requires_scrollbar := (bar_height - enh) > 0

	// Draw Scroll
	if requires_scrollbar {
		wid := 15

		ctx.win.draw_bordered_rect(x, y, wid, this.height, 2, ctx.theme.scroll_track_color,
			ctx.win.theme.button_bg_hover)

		ctx.win.gg.draw_rounded_rect_filled(x + 2, y + 15 + sth, 10, enh, 4, ctx.win.theme.scroll_bar_color)
	} else {
		return
	}

	ctx.gg.draw_rect_empty(x, y, 15, this.height, ctx.theme.textbox_border)
	ctx.gg.draw_rect_empty(x, y + 15, 15, this.height - 30, ctx.theme.textbox_border)

	// Scroll Buttons
	if this.is_mouse_rele {
		bounds := Bounds{x, y + this.height - 15, 15, 15}
		if is_in_bounds(ctx.win.mouse_x, ctx.win.mouse_y, bounds) {
			this.scroll_i += 4
			this.is_mouse_rele = false
		}

		bounds1 := Bounds{x, y, 15, 15}
		if is_in_bounds(ctx.win.mouse_x, ctx.win.mouse_y, bounds1) {
			this.scroll_i -= 4
			if this.scroll_i < 0 {
				this.scroll_i = 0
			}
			this.is_mouse_rele = false
		}
	}

	if this.is_mouse_down {
		sub := enh / 2
		bounds1 := Bounds{x, y + 15, 15, this.height - 30 - sub}

		if is_in_bounds(ctx.win.mouse_x, ctx.win.mouse_y, bounds1) || this.in_scroll {
			this.in_scroll = true
			cx := math.clamp(ctx.win.mouse_y - y - sub, 0, this.height)
			perr := (cx / this.height) * spl_len
			this.scroll_i = int(perr) / this.increment
		}
	} else {
		this.in_scroll = false
	}
}
