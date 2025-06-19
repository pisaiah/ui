module iui

import gx
import math

const nill = unsafe { nil }

const no_bg = gx.rgba(0, 0, 0, 0)

// Layout
pub interface Layout {
	draw_kids(mut Panel, &GraphicsContext)
}

//	BorderLayout - A Layout with five areas. The Center gets a much of the
//	available Panel space as possible. The other areas expand only to their
//	respective size. It is possible to only use a few areas instead of all five.
//	(Ref: https://docs.oracle.com/javase/tutorial/uiswing/layout/border.html)
pub struct BorderLayout {
mut:
	// TODO
	north  ?&Component
	west   ?&Component
	east   ?&Component
	south  ?&Component
	center ?&Component
	hgap   int = 2
	vgap   int = 2
	style  int
}

//	Config for BorderLayout.new
//	hgap - The HGAP between Components
//	vgap - The VGAP between Components
//	style - (WIP) Layout style. (0 = NORTH/SOUTH First, 1 = Sides First)
@[params]
pub struct BorderLayoutConfig {
pub:
	hgap  int = 5
	vgap  int = 5
	style int
}

pub fn BorderLayout.new(c BorderLayoutConfig) BorderLayout {
	return BorderLayout{
		hgap:  c.hgap
		vgap:  c.vgap
		style: c.style
	}
}

pub const borderlayout_north = 0
pub const borderlayout_west = 1
pub const borderlayout_east = 2
pub const borderlayout_south = 3
pub const borderlayout_center = 4

pub const pos_north = 0
pub const pos_west = 1
pub const pos_east = 2
pub const pos_south = 3
pub const pos_center = 4

fn is_nil(a voidptr) bool {
	return isnil(a)
}

// North
fn (mut lay BorderLayout) draw_north(ctx &GraphicsContext, x int, y int, w int) int {
	mut north := lay.north or { return 0 }

	// Note: Options are broken in V, again.

	/*
	if lay.north != none {
		lay.north.width = w
		lay.north.draw_with_offset(ctx, x, y)
		return north.height + lay.vgap
	}
	*/

	north.width = w
	north.draw_with_offset(ctx, x, y)
	return north.height + lay.vgap

	// return 0
}

fn (mut lay BorderLayout) draw_layout(mut panel Panel, ctx &GraphicsContext) {
	mut x := panel.x + lay.hgap
	mut y := panel.y + lay.vgap
	mut cw := panel.width - (lay.hgap * 2)
	mut ch := panel.height - (lay.vgap * 2)

	if lay.style == 0 {
		// North
		if lay.north != none {
			nh := lay.draw_north(ctx, x, y, cw)
			y += nh
			ch -= nh
		}

		// South
		if lay.south != none {
			mut south := lay.south // or { unsafe { nil } }
			south.width = cw
			ch -= south.height
			south.draw_with_offset(ctx, x, y + ch)
			ch -= lay.vgap
		}
	}

	// East
	if lay.east != none {
		mut east := lay.east // or { unsafe { nil } }
		east.height = ch
		cw -= east.width
		east.draw_with_offset(ctx, x + cw, y)
		cw -= lay.hgap
	}

	// West
	if lay.west != none {
		mut west := lay.west // or { unsafe { nil } }
		west.height = ch
		west.draw_with_offset(ctx, x, y)
		x += west.width + lay.hgap
		cw -= west.width + lay.hgap
	}

	if lay.style == 1 {
		// North
		if lay.north != none {
			nh := lay.draw_north(ctx, x, y, cw)
			y += nh
			ch -= nh
		}

		// South
		if lay.south != none {
			mut south := lay.south // or { unsafe { nil } }
			south.width = cw
			ch -= south.height
			south.draw_with_offset(ctx, x, y + ch)
			ch -= lay.vgap
		}
	}

	// Center
	if lay.center != none {
		mut center := lay.center // or { return }
		center.height = ch
		center.width = cw
		center.draw_with_offset(ctx, x, y)
		x += center.width + lay.hgap
	}
}

fn (this &BorderLayout) draw_kids(mut panel Panel, ctx &GraphicsContext) {
	x := panel.x + this.hgap
	y := panel.y + this.vgap
	mut lay := panel.layout

	if panel.rh == 0 {
		for mut child in panel.children {
			child.draw_with_offset(ctx, x, y)
		}
		panel.rh = 1
	}

	if mut lay is BorderLayout {
		lay.draw_layout(mut panel, ctx)
	}

	// if panel.width == 0 {
	//	panel.width = x - panel.x
	//	panel.height = y - panel.y
	//}
}

/*
	BoxLayout - Layout Components in a horizontal or vertical row.
	(Ref: https://docs.oracle.com/javase/tutorial/uiswing/layout/box.html)
*/
pub struct BoxLayout {
pub mut:
	ori  int
	hgap int = 5
	vgap int = 5
}

@[params]
pub struct BoxLayoutConfig {
pub:
	ori  int
	hgap int = 5
	vgap int = 5
}

pub fn BoxLayout.new(c BoxLayoutConfig) BoxLayout {
	return BoxLayout{
		ori:  c.ori
		hgap: c.hgap
		vgap: c.vgap
	}
}

fn (this &BoxLayout) draw_kids(mut panel Panel, ctx &GraphicsContext) {
	mut x := panel.x + this.hgap
	mut y := panel.y + this.vgap
	for mut child in panel.children {
		child.draw_with_offset(ctx, x, y)
		if this.ori == 0 {
			x += child.width + this.hgap
			if panel.height < child.height {
				panel.height = child.height + (this.vgap * 2)
			}
		} else {
			y += child.height + this.vgap
			if panel.width < child.width {
				panel.width = child.width + (this.hgap * 2)
			}
		}
	}
	if panel.height == 0 {
		panel.height = y - panel.y + this.vgap
	}
	if panel.width == 0 {
		panel.width = x - panel.x
	}
}

// https://docs.oracle.com/javase/tutorial/uiswing/layout/flow.html
pub struct FlowLayout {
mut:
	hgap int = 5
	vgap int = 5
}

@[params]
pub struct FlowLayoutConfig {
pub:
	hgap int = 5
	vgap int = 5
}

pub fn FlowLayout.new(c FlowLayoutConfig) FlowLayout {
	return FlowLayout{
		hgap: c.hgap
		vgap: c.vgap
	}
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

	if panel.children.len == 0 {
		return
	}

	min_h := panel.children[0].height

	if panel.width == 0 {
		panel.width = x - panel.x
		if panel.height == 0 {
			panel.height = y - panel.y
			if panel.height < min_h {
				panel.height = min_h
			}
		}
	}
	if panel.height == this.vgap * 2 && min_h > 0 {
		panel.height = min_h + this.vgap * 2
	}
}

// https://docs.oracle.com/javase/tutorial/uiswing/layout/grid.html
pub struct GridLayout {
pub mut:
	rows int
	cols int
	hgap int = 5
	vgap int = 5
	zv   int
}

@[params]
pub struct GridLayoutConfig {
pub:
	rows int
	cols int
	hgap int = 5
	vgap int = 5
}

pub fn GridLayout.new(c GridLayoutConfig) GridLayout {
	return GridLayout{
		rows: c.rows
		cols: c.cols
		hgap: c.hgap
		vgap: c.vgap
	}
}

fn (this &GridLayout) draw_kids(mut panel Panel, ctx &GraphicsContext) {
	mut x := panel.x + this.hgap
	mut y := panel.y + this.vgap
	mut c := 0
	mut a := 0

	mut cols := this.cols
	if this.cols == 0 {
		if this.zv > 0 {
			cols = this.zv
		}
	}

	do_pack := panel.width == 0 && panel.height == 0

	// Pack Panel
	if do_pack {
		mut w := 0
		mut h := 0
		for mut child in panel.children {
			child.draw_with_offset(ctx, x, y)
			h += child.height
			w += child.width + this.hgap
		}

		if this.cols > 0 {
			w = w / this.cols
		}

		if this.rows > 0 {
			h = h / this.rows
		}

		if panel.width < w {
			panel.width = w
		}
		panel.height = h
	}

	for mut child in panel.children {
		child.draw_with_offset(ctx, x, y)

		if do_pack {
			a += child.width + (this.hgap * 2)
		}

		child.width = ((panel.width - this.hgap) / cols) - this.hgap
		if this.cols == 0 {
			child.height = ((panel.height - this.vgap) / this.rows) - this.vgap
		} else {
			child.height = ((panel.height - this.vgap) / this.zv) - this.vgap
		}

		x += child.width + this.hgap
		c += 1

		if c >= cols {
			if do_pack && panel.width < a {
				panel.width = a
			}
			c = 0
			x = panel.x + this.hgap
			y += child.height + this.vgap
			a = 0
		}
	}
}

// CardLayout - Layout Components in a horizontal or vertical row.
// https://docs.oracle.com/javase/tutorial/uiswing/layout/card.html
pub struct CardLayout {
pub mut:
	hgap     int = 5
	vgap     int = 5
	selected string
}

@[params]
pub struct CardLayoutConfig {
pub:
	hgap int = 5
	vgap int = 5
}

pub fn CardLayout.new(c CardLayoutConfig) CardLayout {
	return CardLayout{
		hgap: c.hgap
		vgap: c.vgap
	}
}

fn (this &CardLayout) draw_kids(mut panel Panel, ctx &GraphicsContext) {
	mut x := panel.x + this.hgap
	mut y := panel.y + this.vgap

	for mut child in panel.children {
		if child.id == this.selected {
			child.draw_with_offset(ctx, x, y)
		}
	}

	if panel.height == 0 {
		panel.height = y - panel.y + this.vgap
	}
	if panel.width == 0 {
		panel.width = x - panel.x
	}
}

pub fn (mut this CardLayout) show(p Panel, id string) {
	this.selected = id
}

// Panel
pub struct Panel implements Container {
	Component_A
pub mut:
	layout            Layout
	rh                int
	bg                gx.Color = no_bg
	container_pass_ev bool     = true
}

@[params]
pub struct PanelConfig {
pub:
	layout   Layout = FlowLayout{}
	children ?[]Component
	width    int
	height   int
}

pub fn Panel.new(cfg PanelConfig) &Panel {
	return panel(cfg)
}

pub fn panel(cfg PanelConfig) &Panel {
	return &Panel{
		layout:   cfg.layout
		children: cfg.children or { []Component{} }
		width:    cfg.width
		height:   cfg.height
	}
}

pub fn (mut p Panel) get_layout() Layout {
	return p.layout
}

pub fn (mut p Panel) get_layout_as[T]() T {
	return p.layout as T
}

// Set background color of this Panel. Default=none
pub fn (mut this Panel) set_background(bg gx.Color) {
	this.bg = bg
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

	if this.bg != no_bg {
		ctx.gg.draw_rect_filled(this.x, this.y, this.width, this.height, this.bg)
	}

	if ctx.win.debug_draw {
		ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, gx.green)
	}
	this.layout.draw_kids(mut this, ctx)
}

pub fn (mut this Panel) set_layout(layout Layout) {
	this.layout = layout
}

@[params]
pub struct Flag {
pub:
	value FlagValue
}

pub type FlagValue = int | string

pub fn (mut this Panel) add_child(com &Component, flag ?Flag) {
	if flag == none {
		this.children << com
		return
	}
	if flag != none {
		this.add_child_with_flag(com, flag.value)
	}
}

pub fn (mut this Panel) add_child_with_flag(com &Component, flag FlagValue) {
	this.children << com
	if mut this.layout is BorderLayout {
		unsafe {
			match flag as int {
				0 { this.layout.north = com }
				1 { this.layout.west = com }
				2 { this.layout.east = com }
				3 { this.layout.south = com }
				4 { this.layout.center = com }
				else {}
			}
		}
	}

	if mut this.layout is CardLayout {
		unsafe {
			// TODO
			com.id = flag as string
		}
		if this.children.len == 1 {
			this.layout.selected = flag as string
		}
	}
}
