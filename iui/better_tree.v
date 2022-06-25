// better_tree.v:
//	Test of improved Treeview component
module iui

import gg
import gx
import math
import os

//
// Tree:
//     Implementation Note: https://www.codejava.net/java-se/swing/jtree-basic-tutorial-and-examples
//
struct Tree2 {
	Component_A
pub mut:
	click_event_fn fn (voidptr, voidptr, voidptr)
	// nodes         []&TreeNode
	open          int
	min_y         int
	in_scroll     bool
	is_hover      bool
	padding_top   int
	parent_height int
}

// Children
pub struct TreeNode {
	Component_A
pub mut:
	text  string
	nodes []&TreeNode
	open  bool
}

pub fn tree2(text string) &Tree2 {
	return &Tree2{
		text: text
		click_event_fn: voidptr(0)
	}
}

pub fn (mut this Tree2) add_child(node &TreeNode) {
	this.children << node
}

fn (mut this Tree2) draw_scrollbar(ctx &GraphicsContext, cl int, spl_len int) {
	x := this.x + this.width - 15

	// Scroll Bar
	scroll := (this.scroll_i / 4)
	bar_height := this.height - 35

	sth := int((f32(scroll) / f32(spl_len)) * bar_height)
	enh := int((f32(cl) / f32(spl_len)) * bar_height)
	requires_scrollbar := (bar_height - enh) > 0

	// Draw Scroll
	if requires_scrollbar {
		wid := 15
		min := wid + 1

		ctx.win.draw_bordered_rect(x, this.y, wid, this.height, 2, ctx.theme.scroll_track_color,
			ctx.win.theme.button_bg_hover)

		ctx.win.gg.draw_rect_filled(x, this.y + 15 + sth, 14, enh - 6, ctx.win.theme.scroll_bar_color)
	} else {
		return
	}

	ctx.gg.draw_rect_empty(x, this.y, 15, this.height, ctx.theme.textbox_border)
	ctx.gg.draw_rect_empty(x, this.y + 15, 15, this.height - 30, ctx.theme.textbox_border)

	// Scroll Buttons
	if this.is_mouse_rele {
		bounds := Bounds{x, this.y + this.height - 15, 15, 15}
		if is_in_bounds(ctx.win.mouse_x, ctx.win.mouse_y, bounds) {
			this.scroll_i += 4
			this.is_mouse_rele = false
		}

		bounds1 := Bounds{x, this.y, 15, 15}
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
		bounds1 := Bounds{x, this.y + 15, 15, this.height - 30 - sub}

		if is_in_bounds(ctx.win.mouse_x, ctx.win.mouse_y, bounds1) || this.in_scroll {
			this.in_scroll = true
			cx := math.clamp(ctx.win.mouse_y - this.y - sub, 0, this.height)
			perr := (cx / this.height) * spl_len
			this.scroll_i = int(perr * 4)
		}
	} else {
		this.in_scroll = false
	}
}

fn (mut this TreeNode) draw(ctx &GraphicsContext) {
	if this.is_mouse_rele {
		this.is_mouse_rele = false
	}
}

fn (mut this TreeNode) draw_icon(ctx &GraphicsContext, x int, y int) {
	if this.nodes.len > 0 {
		ctx.gg.draw_image_with_config(gg.DrawImageConfig{
			img_id: ctx.icon_cache['tree_file']
			img_rect: gg.Rect{x, y, 16, 13}
			part_rect: gg.Rect{13, 3, 16, 13}
		})
	} else {
		ctx.gg.draw_image_with_config(gg.DrawImageConfig{
			img_id: ctx.icon_cache['tree_file']
			img_rect: gg.Rect{x, y, 13, 16}
			part_rect: gg.Rect{0, 0, 13, 16}
		})
	}
}

fn (mut this TreeNode) draw_content(ctx &GraphicsContext, xoff int, y int, mut tree Tree2) (bool, int, int) {
	cfg := gx.TextCfg{
		color: ctx.theme.text_color
		size: ctx.font_size
	}

	mut nodes := 1
	mut hid := 0

	if y < tree.y {
		hid += 1
		nodes -= 1
	}
	if y > tree.y + tree.height {
		hid += 1
		nodes -= 1
		return false, nodes, hid
	}

	if y >= tree.y {
		ctx.draw_text(xoff + this.height, y + 1, os.base(this.text), ctx.font, cfg)
		this.draw_icon(ctx, xoff, y)
	}

	wid := tree.width - (xoff - tree.x) - this.height
	bounds := Bounds{xoff, y, wid, this.height}

	if is_in_bounds(ctx.win.mouse_x, ctx.win.mouse_y, bounds) {
		ctx.gg.draw_rect_empty(xoff, y, wid, this.height, ctx.theme.button_border_hover)
	}

	if is_in_bounds(ctx.win.click_x, ctx.win.click_y, bounds) {
		if tree.is_mouse_rele {
			if tree.click_event_fn != voidptr(0) {
				tree.click_event_fn(ctx, tree, this)
			}
			if this.nodes.len > 0 {
				this.open = !this.open
			}
			tree.is_mouse_rele = false
			return true, nodes, hid
		}
	}

	if !this.open {
		return false, nodes, hid
	}

	mut ny := y + this.height

	for mut node in this.nodes {
		node.height = this.height
		_, nnodes, hidd := node.draw_content(ctx, xoff + this.height, ny, mut tree)
		nodes += nnodes
		hid += hidd
		ny += node.get_height()
	}
	return false, nodes, hid
}

fn (this &TreeNode) get_height() int {
	if !this.open {
		return this.height
	}
	mut height := this.height

	for node in this.nodes {
		if node.open {
			height += node.get_height()
		}
		height += this.height
	}
	return height
}

pub fn (this &Tree2) get_node_height(ctx &GraphicsContext) int {
	if ctx.line_height > 21 {
		return ctx.line_height
	}
	return 21
}

pub fn (mut this Tree2) draw(ctx &GraphicsContext) {
	cfg := gx.TextCfg{
		color: ctx.theme.text_color
		size: ctx.font_size
	}

	node_height := this.get_node_height(ctx)
	scroll := ((this.scroll_i / 4) * node_height)

	if scroll == 0 {
		ctx.gg.draw_image_with_config(gg.DrawImageConfig{
			img_id: ctx.icon_cache['tree_file']
			img_rect: gg.Rect{this.x + 4, this.y - scroll + 4, 16, 13}
			part_rect: gg.Rect{13, 3, 16, 13}
		})
		ctx.draw_text(this.x + 24, this.y - scroll + 4, os.base(this.text), ctx.font,
			cfg)
	}
	ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, ctx.theme.textbox_border)

	mut y := this.y + 5

	mut drawn := 0
	mut not_drawn := 0

	for mut node in this.children {
		if mut node is TreeNode {
			wid := this.width - (this.x + node_height) - 15
			node.set_bounds(this.x + node_height, y + node_height - scroll, wid, node_height)

			node.draw(ctx)
			change, draw, hide := node.draw_content(ctx, this.x + node_height, node.y, mut
				this)

			drawn += draw
			not_drawn += hide

			if change {
				this.is_mouse_rele = false
			}

			y += node.get_height()
		}
	}
	this.draw_scrollbar(ctx, drawn, drawn + not_drawn)

	max := (drawn + not_drawn) - (this.height / node_height) + 2

	if (this.scroll_i / 4) > max && max > 0 {
		this.scroll_i = max * 4
	}
}
