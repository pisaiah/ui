module iui

import gx
import math

// Layout
// TODO: Add BorderLayout, Box Layout, Flow Layout, Grid Layout,
interface Layout {
	draw_kids(mut Panel, &GraphicsContext)
}

// https://docs.oracle.com/javase/tutorial/uiswing/layout/border.html
pub struct BorderLayout {
	// TODO
}

// https://docs.oracle.com/javase/tutorial/uiswing/layout/box.html
pub struct BoxLayout {
mut:
	ori int
}

fn (this &BoxLayout) draw_kids(mut panel Panel, ctx &GraphicsContext) {
	mut x := panel.x
	mut y := panel.y
	for mut child in panel.children {
		child.draw_with_offset(ctx, x, y)
		if this.ori == 0 {
			x += child.width
		} else {
			y += child.height
		}
	}
}

// https://docs.oracle.com/javase/tutorial/uiswing/layout/flow.html
pub struct FlowLayout {
mut:
	hgap int = 5
	vgap int = 5
}

fn (this &FlowLayout) draw_kids(mut panel Panel, ctx &GraphicsContext) {
	mut x := panel.x + this.hgap
	mut y := panel.y + this.vgap
	for mut child in panel.children {
		if child.height > panel.rh {
			panel.rh = child.height
		}

		ex := x + child.width + this.hgap
		if ex > panel.x + panel.width {
			x = panel.x + this.hgap
			y += panel.rh + this.vgap
			panel.rh = 0
		}

		child.draw_with_offset(ctx, x, y)
		x += child.width + this.hgap
		if child.height > panel.rh {
			panel.rh = child.height
		}
	}
}

// https://docs.oracle.com/javase/tutorial/uiswing/layout/grid.html
pub struct GridLayout {
mut:
	rows int
	cols int
	hgap int = 5
	vgap int = 5
	zv   int
}

fn (this &GridLayout) draw_kids(mut panel Panel, ctx &GraphicsContext) {
	mut x := panel.x + this.hgap
	mut y := panel.y + this.vgap
	mut c := 0

	mut cols := this.cols
	if this.cols == 0 {
		if this.zv > 0 {
			cols = this.zv
		}
	}

	dump(cols)
	for mut child in panel.children {
		child.draw_with_offset(ctx, x, y)

		child.width = ((panel.width - this.hgap) / cols) - this.hgap
		if this.cols == 0 {
			child.height = ((panel.height - this.vgap) / this.rows) - this.vgap
		} else {
			child.height = ((panel.height - this.vgap) / this.zv) - this.vgap
		}

		x += child.width + this.hgap
		c += 1
		if c >= cols {
			c = 0
			x = panel.x + this.hgap
			y += child.height + this.vgap
		}
	}
}

// Panel
pub struct Panel {
	Component_A
mut:
	layout Layout
	rh     int
}

[params]
pub struct PanelConfig {
	layout Layout = FlowLayout{}
}

pub fn panel(cfg PanelConfig) &Panel {
	return &Panel{
		layout: cfg.layout
	}
}

fn (mut this Panel) draw(ctx &GraphicsContext) {
	if mut this.layout is GridLayout {
		if this.layout.cols == 0 {
			val := this.children.len / f32(this.layout.rows)
			r := math.round(val)
			if this.layout.zv != r {
				this.layout.zv = int(math.round(val))
			}
		}
		if this.layout.rows == 0 {
			val := this.children.len / f32(this.layout.cols)
			r := math.round(val)
			if this.layout.zv != r {
				this.layout.zv = int(math.round(val))
			}
		}
		if this.layout.zv == 0 {
			this.layout.zv = 1
		}
	}
	for mut kid in this.children {
		if kid.parent == unsafe { nil } {
			kid.parent = this
		}
	}
	if ctx.win.debug_draw {
		ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, gx.green)
	}
	this.layout.draw_kids(mut this, ctx)
}

pub fn (mut this Panel) set_layout(layout Layout) {
	this.layout = layout
}

pub fn (mut this Panel) add_child_with_flag(com &Component, flag int) {
	this.children << com
}
