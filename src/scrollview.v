module iui

import math { clamp }

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
	noborder    bool
	xbar_width  int = 16
	ybar_height int = 16
	scroll_x    int
	always_show bool
	padding     int = 20
	radius      int = 16
}

@[params]
pub struct ScrollViewConfig {
pub mut:
	bounds      Bounds
	view        &Component
	increment   int = 4
	always_show bool
	padding     int = 20
}

pub fn ScrollView.new(c ScrollViewConfig) &ScrollView {
	return &ScrollView{
		x:           c.bounds.x
		y:           c.bounds.y
		width:       c.bounds.width
		height:      c.bounds.height
		children:    [c.view]
		increment:   c.increment
		always_show: c.always_show
		padding:     c.padding
	}
}

pub fn scroll_view(cfg ScrollViewConfig) &ScrollView {
	return ScrollView.new(cfg)
}

// Notes: https://bit.ly/javadoc-JScrollPane-setViewportView-Component
pub fn (mut this ScrollView) set_view(com &Component) {
	this.add_child(com)
}

// Notes: JScrollPane.setUnitIncrement
pub fn (mut this ScrollView) set_increment(value int) {
	this.increment = value
}

pub fn (mut this ScrollView) set_border_painted(val bool) {
	this.noborder = !val
}

// Draw
pub fn (mut sv ScrollView) draw(ctx &GraphicsContext) {
	if sv.width < 0 {
		return
	}

	// Set Scissor
	ctx.gg.scissor_rect(sv.x - 1, sv.y - 1, sv.width + 2, sv.height + 1)

	total_height, total_width := sv.draw_children(ctx)

	sv.clamp_scroll_index(total_height + sv.padding)
	sv.clamp_scroll_x(total_width + sv.padding)

	if !sv.noborder {
		ctx.gg.draw_rect_empty(sv.x, sv.y, sv.width, sv.height, ctx.theme.textbox_border)
	}
	sv.draw_scrollbar(ctx, sv.height, total_height + sv.padding)
	sv.draw_scrollbar2(ctx, sv.width, total_width + sv.padding)

	// Reset Scissor
	ws := ctx.gg.window_size()
	ctx.gg.scissor_rect(0, 0, ws.width, ws.height)
}

// Draw the children
pub fn (mut this ScrollView) draw_children(ctx &GraphicsContext) (int, int) {
	mut y_pos := this.y - (this.scroll_i * this.increment)
	x_pos := this.x - (this.scroll_x * this.increment)
	mut total_height := 0 // this.padding
	mut total_width := 0 // this.padding
	for mut child in this.children {
		if child.parent == unsafe { nil } {
			child.set_parent(this)
		}

		// Override child's scroll index;
		// TODO: Not do this. Need to improve components
		// that used scroll (ex TextArea) before ScrollView
		child.scroll_i = 0

		mut win := ctx.win
		child.draw_event_fn(mut win, child)
		child.draw_with_offset(ctx, x_pos, y_pos)

		// child.after_draw_event_fn(mut win, child)
		y_pos += child.y + child.height
		total_height += child.y + child.height
		total_width += child.x + child.width
	}
	return total_height, total_width
}

fn (mut this ScrollView) clamp_scroll_index(total_height_max int) {
	if total_height_max > this.height {
		current := this.height + (this.scroll_i * this.increment)
		if current > total_height_max {
			a := total_height_max / this.increment
			b := this.height / this.increment
			this.scroll_i = a - b
		}
	} else {
		this.scroll_i = 0
	}
}

fn (mut this ScrollView) clamp_scroll_x(total_width_max int) {
	if total_width_max > this.width {
		scroll := (this.scroll_x * this.increment)
		current := this.width + scroll

		if current > total_width_max {
			a := total_width_max / this.increment
			b := this.width / this.increment
			this.scroll_x = a - b
		}
	} else {
		this.scroll_x = 0
	}
}

pub fn is_in_bar(com &ScrollView, px int, py int) bool {
	x := if com.rx == 0 { com.x } else { com.rx }
	y := if com.ry == 0 { com.y } else { com.ry }

	xx := x + com.width - com.xbar_width

	midx := xx + (com.xbar_width / 2)
	midy := y + (com.height / 2)

	return abs(midx - px) < (com.xbar_width / 2) && abs(midy - py) < (com.height / 2)
}

fn (mut this ScrollView) draw_scrollbar(ctx &GraphicsContext, cl int, spl_len int) {
	xx := if this.rx != 0 { this.rx } else { this.x }
	y := if this.rx != 0 { this.ry } else { this.y } + 2

	wid := this.xbar_width
	height := this.height - (2 * 2) // - wid
	x := xx + this.width - wid

	// Scroll Bar
	scroll := this.scroll_i * this.increment
	bar_height := height - 35

	if spl_len == 0 {
		return
	}

	sth := (scroll * bar_height) / spl_len
	enh := (cl * bar_height) / spl_len
	requires_scrollbar := this.always_show || (bar_height - enh - this.padding) > 0

	// Draw Scroll
	if requires_scrollbar {
		ctx.win.gg.draw_rounded_rect_filled(x, y, wid, height, this.radius, ctx.theme.scroll_track_color)
		ctx.theme.bar_fill_fn(x + 2, y + 17 + sth, wid - 4, enh - 3, false, ctx)
	} else {
		return
	}

	ctx.gg.draw_rounded_rect_empty(x, y, wid, height, this.radius, ctx.theme.textbox_border)

	triangle_color := ctx.theme.scroll_bar_color

	tx := x + (wid / 2) - 5
	ctx.gg.draw_triangle_filled(tx, y + 10, tx + 5, y + 5, tx + 10, y + 10, triangle_color)

	ty := y + height - 10
	ctx.gg.draw_triangle_filled(tx, ty, tx + 5, ty + 5, tx + 10, ty, triangle_color)

	// Scroll Buttons
	if this.is_mouse_rele {
		bounds := Bounds{x, y + height - 15, wid, 15}
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
		bounds1 := Bounds{x, y + 15, wid, height - 30}

		if is_in_bounds(ctx.win.mouse_x, ctx.win.mouse_y, bounds1) || this.in_scroll {
			this.in_scroll = true
			cx := clamp(ctx.win.mouse_y - y - sub, 0, height)
			perr := (cx / height) * spl_len
			this.scroll_i = int(perr) / this.increment
		}
	} else {
		this.in_scroll = false
	}
}

fn (mut this ScrollView) draw_scrollbar2(ctx &GraphicsContext, cl int, spl_len int) {
	x := if this.rx != 0 { this.rx } else { this.x } + 2
	yy := if this.ry != 0 { this.ry } else { this.y }

	wid := this.xbar_width
	width := this.width - wid - 4

	y := yy + this.height - wid

	// Scroll Bar
	scroll := this.scroll_x * this.increment
	bar_height := width - 35

	if spl_len == 0 {
		return
	}

	sth := (scroll * bar_height) / spl_len
	enh := (cl * bar_height) / spl_len
	requires_scrollbar := this.always_show || (bar_height - enh - this.padding) > 0

	// Draw Scroll
	if requires_scrollbar {
		ctx.win.gg.draw_rounded_rect_filled(x, y, width, wid, this.radius, ctx.theme.scroll_track_color)
		ctx.theme.bar_fill_fn(int(x + 17 + sth), y + 2, int(enh - 3), wid - 3, true, ctx)
	} else {
		return
	}

	ty := y + (wid / 2) - 5

	ctx.gg.draw_triangle_filled(x + 5, ty + 5, x + 10, ty + 10, x + 10, ty, ctx.theme.scroll_bar_color)

	tx := x + width - 10
	ctx.gg.draw_triangle_filled(tx + 5, ty + 5, tx + 0, ty + 10, tx + 0, ty - 1, ctx.theme.scroll_bar_color)

	// Scroll Buttons
	if this.is_mouse_rele {
		bounds := Bounds{x + width - 15, y, wid, 15}
		if is_in_bounds(ctx.win.mouse_x, ctx.win.mouse_y, bounds) {
			this.scroll_x += 4
			this.is_mouse_rele = false
		}

		bounds1 := Bounds{x, y, wid, 15}
		if is_in_bounds(ctx.win.mouse_x, ctx.win.mouse_y, bounds1) {
			this.scroll_x -= 4
			if this.scroll_x < 0 {
				this.scroll_x = 0
			}
			this.is_mouse_rele = false
		}
	}

	if this.is_mouse_down {
		sub := enh / 2
		bounds1 := Bounds{x + 15, y, width - 30, wid}

		if is_in_bounds(ctx.win.mouse_x, ctx.win.mouse_y, bounds1) || this.in_scroll_x {
			this.in_scroll_x = true
			cx := clamp(ctx.win.mouse_x - x - sub, 0, width)
			perr := (cx / width) * spl_len
			this.scroll_x = int(perr) / this.increment
		}
	} else {
		this.in_scroll_x = false
	}
}
