module iui

import math

// ScrollView Component
//
// Implementation Details:
//	https://docs.oracle.com/javase/8/docs/api/javax/swing/JScrollPane.html
//	https://docs.oracle.com/javase/tutorial/uiswing/components/scrollpane.html
pub struct ScrollView {
	Component_A
pub mut:
	increment   int = 4
	in_scroll   bool
	in_scroll_x bool
	xbar_width  int = 15
	ybar_height int = 15
	scroll_x    int
	always_show bool
}

[params]
pub struct ScrollViewConfig {
pub mut:
	bounds      Bounds
	view        &Component
	increment   int = 4
	always_show bool
}

pub fn scroll_view(cfg ScrollViewConfig) &ScrollView {
	scroll_view := &ScrollView{
		x: cfg.bounds.x
		y: cfg.bounds.y
		width: cfg.bounds.width
		height: cfg.bounds.height
		children: [cfg.view]
		increment: cfg.increment
		always_show: cfg.always_show
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
	ctx.gg.scissor_rect(x - 1, y - 1, this.width + 2, this.height + 2)

	total_height, total_width := this.draw_children(ctx)

	this.clamp_scroll_index(total_height)
	this.clamp_scroll_x(total_width)

	ctx.gg.draw_rect_empty(x, y, this.width, this.height, ctx.theme.scroll_bar_color)
	this.draw_scrollbar(ctx, this.height, total_height)
	this.draw_scrollbar_hor(ctx, this.width, total_width)

	// Reset Scissor
	ws := ctx.gg.window_size()
	ctx.gg.scissor_rect(0, 0, ws.width, ws.height)
}

// Draw the children
pub fn (mut this ScrollView) draw_children(ctx &GraphicsContext) (int, int) {
	mut y_pos := this.y - (this.scroll_i * this.increment)
	x_pos := this.x - (this.scroll_x * this.increment)
	mut total_height := 0
	mut total_width := 0

	for mut child in this.children {
		if child.parent == unsafe { nil } {
			child.parent = this
		}

		// Override child's scroll index;
		// TODO: Not do this. Need to improve components
		// that used scroll (ex TextArea) before ScrollView
		child.scroll_i = 0

		mut win := ctx.win
		child.draw_event_fn(mut win, child)
		child.draw_with_offset(ctx, x_pos, y_pos)
		child.after_draw_event_fn(mut win, child)

		y_pos += child.y + child.height
		total_height += child.y + child.height
		total_width += child.x + child.width
	}
	return total_height, total_width
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

fn (mut this ScrollView) clamp_scroll_x(total_width int) {
	if total_width > this.width {
		scroll := (this.scroll_x * this.increment)
		current := this.width + scroll
		max := total_width

		if current > max {
			a := total_width / this.increment
			b := this.width / this.increment
			this.scroll_x = a - b
		}
	} else {
		this.scroll_x = 0
	}
}

fn (mut this ScrollView) draw_scrollbar(ctx &GraphicsContext, cl int, spl_len int) {
	xx := if this.rx != 0 { this.rx } else { this.x }
	y := if this.rx != 0 { this.ry } else { this.y }

	wid := 16
	x := xx + this.width - wid

	// Scroll Bar
	scroll := this.scroll_i * this.increment
	bar_height := this.height - 35

	sth := int((f32(scroll) / f32(spl_len)) * bar_height)
	enh := int((f32(cl) / f32(spl_len)) * bar_height)
	requires_scrollbar := this.always_show || (bar_height - enh) > 0

	// Draw Scroll
	if requires_scrollbar {
		ctx.win.gg.draw_rect_filled(x, y, wid, this.height, ctx.theme.scroll_track_color)
		ctx.win.gg.draw_rect_filled(x + 2, y + 17 + sth, wid - 5, enh - 3, ctx.win.theme.scroll_bar_color)
	} else {
		return
	}

	ctx.gg.draw_rect_empty(x, y, wid, this.height, ctx.theme.textbox_border)
	ctx.gg.draw_rect_empty(x, y + 15, wid, this.height - 30, ctx.theme.textbox_border)

	tx := x + (wid / 2) - 5
	ctx.gg.draw_triangle_filled(tx, y + 10, tx + 5, y + 5, tx + 10, y + 10, ctx.theme.scroll_bar_color)

	ty := y + this.height - 10
	ctx.gg.draw_triangle_filled(tx, ty, tx + 5, ty + 5, tx + 10, ty, ctx.theme.scroll_bar_color)

	// Scroll Buttons
	if this.is_mouse_rele {
		bounds := Bounds{x, y + this.height - 15, wid, 15}
		if is_in_bounds(ctx.win.mouse_x, ctx.win.mouse_y, bounds) {
			this.scroll_i += 4
			this.is_mouse_rele = false
		}

		bounds1 := Bounds{x, y, wid, 15}
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
		bounds1 := Bounds{x, y + 15, wid, this.height - 30 - sub}

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

fn (mut this ScrollView) draw_scrollbar_hor(ctx &GraphicsContext, cl int, spl_len int) {
	x := if this.rx != 0 { this.rx } else { this.x }
	yy := if this.rx != 0 { this.ry } else { this.y }

	wid := this.ybar_height
	y := yy + this.height - wid

	// Scroll Bar
	scroll := this.scroll_x * this.increment

	sth := int((f32(scroll) / f32(spl_len)) * this.width)
	enh := int((f32(cl) / f32(spl_len)) * this.width)
	requires_scrollbar := (this.width - enh) > 0

	// Draw Scroll
	if requires_scrollbar {
		ctx.win.gg.draw_rect_filled(x, y, this.width - (this.xbar_width), wid, ctx.theme.scroll_track_color)
		ctx.win.gg.draw_rect_filled(x + wid + sth, y + 2, enh, wid - 5, ctx.win.theme.scroll_bar_color)
	} else {
		return
	}

	ctx.gg.draw_rect_empty(x, y, wid, this.height, ctx.theme.textbox_border)
	ctx.gg.draw_rect_empty(x, y + wid, wid, this.height - (wid * 2), ctx.theme.textbox_border)

	if this.is_mouse_down {
		sub := enh / 2
		bounds1 := Bounds{x, y, this.width - (wid * 2) - sub, wid}

		if is_in_bounds(ctx.win.mouse_x, ctx.win.mouse_y, bounds1) || this.in_scroll_x {
			this.in_scroll_x = true
			cx := math.clamp(ctx.win.mouse_x - x - sub, 0, this.width)
			perr := (cx / this.width) * spl_len
			this.scroll_x = int(perr) / this.increment
		}
	} else {
		this.in_scroll_x = false
	}
}
