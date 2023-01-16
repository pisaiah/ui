module iui

import gg

// SplitView Component
// Details: https://docs.oracle.com/javase/8/docs/api/javax/swing/JSplitPane.html
pub struct SplitView {
	Component_A
pub mut:
	is_scroll   bool
	min_percent int = 30
	h1          f32 = 50
	h2          f32 = 50
}

[params]
pub struct SplitViewConfig {
pub mut:
	bounds      Bounds
	first       &Component
	second      &Component
	min_percent int = 30
	h1          int = 50
	h2          int = 50
}

pub fn split_view(cfg SplitViewConfig) &SplitView {
	split_view := &SplitView{
		x: cfg.bounds.x
		y: cfg.bounds.y
		width: cfg.bounds.width
		height: cfg.bounds.height
		children: [cfg.first, cfg.second]
		min_percent: cfg.min_percent
		h1: cfg.h1
		h2: cfg.h2
	}
	return split_view
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
		this.children[0].height = int(h1) - 8
		this.children[1].height = int(h2) - 8
	}

	mut win := ctx.win
	for mut child in this.children {
		if child.parent == unsafe { nil } {
			child.parent = this
		}

		child.draw_event_fn(mut win, child)
		child.draw_with_offset(ctx, x_pos, y_pos)
		child.after_draw_event_fn(mut win, child)

		y_pos += child.y + child.height

		if height == 0 {
			this.draw_splitbar(ctx, x_pos, y_pos)
			y_pos += 16
		}

		height += child.y + child.height
	}
}

fn (mut this SplitView) draw_splitbar(ctx &GraphicsContext, x_pos int, y_pos int) {
	color := ctx.theme.scroll_bar_color
	ctx.gg.draw_rect_filled(this.x, y_pos, this.width, 15, ctx.theme.button_bg_normal)

	dl := gg.PenConfig{
		color: color
		line_type: .dotted
		thickness: 2
	}

	in_start := ctx.win.mouse_x > x_pos && ctx.win.mouse_y > y_pos
	in_enddd := ctx.win.mouse_x < x_pos + this.width && ctx.win.mouse_y < y_pos + 15

	if in_start && in_enddd {
		ctx.gg.draw_rect_empty(x_pos, y_pos, this.width, 15, ctx.theme.button_border_hover)
		if this.is_mouse_down {
			this.is_scroll = true
		}
	} else {
		ctx.gg.draw_rect_empty(x_pos, y_pos, this.width, 15, color)
	}
	if !this.is_mouse_down {
		this.is_scroll = false
	}

	if this.is_scroll {
		this.do_size(y_pos, ctx.win.mouse_y - y_pos)
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

	ctx.gg.draw_line_with_config(x_pos, y_pos + 4, x_pos + this.width, y_pos + 4, dl)
	ctx.gg.draw_line_with_config(x_pos + 2, y_pos + 7, x_pos + this.width, y_pos + 7,
		dl)
}

fn (mut this SplitView) do_size(y_pos int, diff int) {
	if !(diff > 8 || diff < -8) {
		return
	}

	mut fir := this.children[0]
	mut sec := this.children[1]

	min := this.min_percent

	res := (f32(diff) / this.height) * 100
	d := int(res)

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
