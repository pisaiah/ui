module iui

import gg

// SplitView Component
// Details: https://docs.oracle.com/javase/8/docs/api/javax/swing/JSplitPane.html
pub struct SplitView {
	Component_A
pub mut:
	is_scroll   bool
	min_percent int = 30
	h1          int = 50
	h2          int = 50
	bar_size    int = 8
}

@[params]
pub struct SplitViewConfig {
pub mut:
	bounds      Bounds
	first       &Component
	second      &Component
	min_percent int = 30
	h1          int = 50
	h2          int = 50
}

pub fn SplitView.new(c SplitViewConfig) &SplitView {
	return &SplitView{
		x:           c.bounds.x
		y:           c.bounds.y
		width:       c.bounds.width
		height:      c.bounds.height
		children:    [c.first, c.second]
		min_percent: c.min_percent
		h1:          c.h1
		h2:          c.h2
	}
}

@[deprecated: 'Use SplitView.new']
pub fn split_view(cfg SplitViewConfig) &SplitView {
	return SplitView.new(cfg)
}

// Set height of children in percentage
pub fn (mut this SplitView) set_heights(h1 int, h2 int) {
	this.h1 = h1
	this.h2 = h2
}

// Draw
pub fn (mut this SplitView) draw(ctx &GraphicsContext) {
	mut y_pos := this.y
	x_pos := this.x
	mut height := 0

	h1 := (this.h1 * this.height) / 100
	h2 := (this.h2 * this.height) / 100

	if h1 > 0 && h2 > 0 {
		this.children[0].height = h1 - this.bar_size / 2
		this.children[1].height = h2 - this.bar_size / 2
	}

	mut win := ctx.win
	for mut child in this.children {
		if child.parent == unsafe { nil } {
			child.set_parent(this)
		}

		child.draw_event_fn(mut win, child)
		child.draw_with_offset(ctx, x_pos, y_pos)

		// child.after_draw_event_fn(mut win, child)
		y_pos += child.y + child.height

		if height == 0 {
			this.draw_splitbar(ctx, x_pos, y_pos)
			y_pos += this.bar_size
		}

		height += child.y + child.height
	}
}

fn (mut this SplitView) draw_splitbar(ctx &GraphicsContext, xp int, yp int) {
	color := ctx.theme.button_border_normal
	ss := this.bar_size
	ctx.gg.draw_rect_filled(this.x, yp, this.width, ss, ctx.theme.button_bg_normal)

	extra := 5

	in_start := ctx.win.mouse_x > xp && ctx.win.mouse_y >= yp - (extra * 2)
	in_enddd := ctx.win.mouse_x < xp + this.width && ctx.win.mouse_y <= yp + ss + extra

	mut mouse_down := this.is_mouse_down

	for mut child in this.children {
		if child.is_mouse_down {
			mouse_down = true
		}
	}

	if in_start && in_enddd {
		ctx.gg.draw_rect_empty(xp, yp, this.width, ss, ctx.theme.button_border_hover)

		if mouse_down {
			this.is_scroll = true
		}
	} else {
		ctx.gg.draw_rect_empty(xp, yp, this.width, ss, color)
	}
	if !mouse_down {
		this.is_scroll = false
	}

	if this.is_scroll {
		this.do_size(yp, ctx.win.mouse_y - yp)
	}

	min := this.min_percent
	if this.h1 <= min {
		this.h1 = min + 1
		this.h2 = 100 - this.h1
	}
	if this.h2 <= min {
		this.h2 = min + 1
		this.h1 = 100 - this.h2
	}

	dl := gg.PenConfig{
		color:     color
		line_type: .dotted
		thickness: 1
	}

	ctx.gg.draw_line_with_config(xp, yp + 2, xp + this.width, yp + 2, dl)
	ctx.gg.draw_line_with_config(xp + 2, yp + 5, xp + this.width, yp + 5, dl)
}

fn (mut this SplitView) do_size(y_pos int, diff int) {
	if !(diff > 8 || diff < -8) {
		return
	}

	min := this.min_percent
	d := (diff * 100) / this.height

	if this.h1 > min && this.h2 > min {
		this.h1 += d
		this.h2 -= d
	} else {
		if this.h1 <= min {
			this.h1 = min + 1
			this.h2 = 100 - this.h1
		}
		if this.h2 <= min {
			this.h2 = min + 1
			this.h1 = 100 - this.h2
		}
	}
}
