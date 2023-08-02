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
mut:
	// TODO
	north  &Component
	west   &Component
	east   &Component
	south  &Component
	center &Component
	hgap   int = 2
	vgap   int = 2
}

pub const (
	borderlayout_north  = 0
	borderlayout_west   = 1
	borderlayout_east   = 2
	borderlayout_south  = 3
	borderlayout_center = 4
)

fn (this &BorderLayout) draw_kids(mut panel Panel, ctx &GraphicsContext) {
	mut x := panel.x + this.hgap
	mut y := panel.y + this.vgap
	mut lay := panel.layout

	if panel.rh == 0 {
		for mut child in panel.children {
			child.draw_with_offset(ctx, x, y)
		}
		panel.rh = 1
	}

	if mut lay is BorderLayout {
		mut cw := panel.width - (lay.hgap * 2)
		mut ch := panel.height - (lay.vgap * 2)

		if !isnil(lay.north) {
			lay.north.width = panel.width - (this.hgap * 2)
			lay.north.draw_with_offset(ctx, x, y)
			y += lay.north.height + lay.vgap
			ch -= lay.north.height + lay.vgap
		}

		if !isnil(lay.south) {
			lay.south.width = cw
			ch -= lay.south.height
			lay.south.draw_with_offset(ctx, x, y + ch)
			ch -= lay.vgap
		}

		if !isnil(lay.east) {
			lay.east.height = ch
			cw -= lay.east.width
			lay.east.draw_with_offset(ctx, x + cw, y)
			cw -= lay.hgap
		}

		if !isnil(lay.west) {
			lay.west.height = ch
			lay.west.draw_with_offset(ctx, x, y)
			x += lay.west.width + lay.hgap
			cw -= lay.west.width + lay.hgap
		}

		lay.center.height = ch
		lay.center.width = cw
		lay.center.draw_with_offset(ctx, x, y)
		x += lay.center.width + lay.hgap
	}
	// if panel.width == 0 {
	//	panel.width = x - panel.x
	//	panel.height = y - panel.y
	//}
}

// https://docs.oracle.com/javase/tutorial/uiswing/layout/box.html
pub struct BoxLayout {
mut:
	ori  int
	hgap int = 5
	vgap int = 5
}

fn (this &BoxLayout) draw_kids(mut panel Panel, ctx &GraphicsContext) {
	mut x := panel.x + this.hgap
	mut y := panel.y + this.vgap
	for mut child in panel.children {
		child.draw_with_offset(ctx, x, y)
		if this.ori == 0 {
			x += child.width + this.hgap
		} else {
			y += child.height + this.vgap
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

	panel.rh = 0

	for mut child in panel.children {
		ex := x + child.width + this.hgap
		if ex > panel.x + panel.width {
			x = panel.x + this.hgap
			y += panel.rh + this.vgap
			panel.rh = 0
		} else {
			if child.height > panel.rh {
				panel.rh = child.height
			}
		}

		child.draw_with_offset(ctx, x, y)

		x += child.width + this.hgap
		if child.height > panel.rh {
			panel.rh = child.height
		}
	}
	if panel.width == 0 {
		panel.width = x - panel.x
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

pub fn Panel.new(cfg PanelConfig) &Panel {
	return panel(cfg)
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
			kid.set_parent(this)
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
	if mut this.layout is BorderLayout {
		unsafe {
			match flag {
				0 { this.layout.north = com }
				1 { this.layout.west = com }
				2 { this.layout.east = com }
				3 { this.layout.south = com }
				4 { this.layout.center = com }
				else {}
			}
		}
	}
}
