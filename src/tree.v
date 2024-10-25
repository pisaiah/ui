module iui

// import math
import gg
import gx
import os

// Tree (https://codejava.net/java-se/swing/jtree-basic-tutorial-and-examples
pub struct Tree2 {
	Component_A
pub mut:
	click_event_fn fn (voidptr, voidptr, voidptr) = unsafe { nil }
	open           int
	min_y          int
	is_hover       bool
	padding_top    int
	parent_height  int
	needs_pack     bool
	no_icon        bool
}

// Children
pub struct TreeNode {
	Component_A
pub mut:
	text  string
	nodes []&TreeNode
	open  bool
}

// new tree
pub fn Tree2.new() &Tree2 {
	return tree('')
}

// @[deprecated: 'Use Tree.new()']
pub fn tree(text string) &Tree2 {
	return &Tree2{
		text: text
	}
}

pub fn (mut this Tree2) add_child(node &TreeNode) {
	this.children << node
}

fn (mut this TreeNode) draw(ctx &GraphicsContext) {
	if this.is_mouse_rele {
		this.is_mouse_rele = false
	}
}

fn (mut this TreeNode) draw_icon(ctx &GraphicsContext, x int, y int) {
	if this.nodes.len > 0 {
		h := y + (this.height / 2) - (13 / 2)
		ctx.gg.draw_image_with_config(gg.DrawImageConfig{
			img_id:    ctx.get_icon_sheet_id()
			img_rect:  gg.Rect{x, h, 16, 13}
			part_rect: gg.Rect{13, 3, 16, 13}
		})
	} else {
		h := y + (this.height / 2) - (16 / 2)
		ctx.gg.draw_image_with_config(gg.DrawImageConfig{
			img_id:    ctx.get_icon_sheet_id()
			img_rect:  gg.Rect{x, h, 13, 16}
			part_rect: gg.Rect{0, 0, 13, 16}
		})
	}
}

fn (mut this TreeNode) draw_content(ctx &GraphicsContext, xoff int, y int, mut tree Tree2) bool {
	cfg := gx.TextCfg{
		color: ctx.theme.text_color
		size:  ctx.font_size
	}

	if y > tree.y + tree.height {
		return false
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
			if tree.click_event_fn != unsafe { nil } {
				tree.click_event_fn(ctx, tree, this)
			}
			if this.nodes.len > 0 {
				this.open = !this.open
			}
			tree.is_mouse_rele = false
			return true
		}
	}

	if !this.open {
		return false
	}

	mut ny := y + this.height

	for mut node in this.nodes {
		node.height = this.height
		_ := node.draw_content(ctx, xoff + this.height, ny, mut tree)

		ny += node.get_height()
	}
	return false
}

fn (this &TreeNode) get_height() int {
	if !this.open {
		return this.height
	}
	mut height := this.height

	for node in this.nodes {
		height += node.get_height()
	}
	return height
}

pub fn (this &Tree2) get_node_height(ctx &GraphicsContext) int {
	if ctx.line_height > 21 {
		return ctx.line_height + 4
	}
	return 22
}

pub fn (mut this Tree2) draw(ctx &GraphicsContext) {
	cfg := gx.TextCfg{
		color: ctx.theme.text_color
		size:  ctx.font_size
	}

	node_height := this.get_node_height(ctx)

	if !this.no_icon {
		h := this.y + (node_height / 2) - (13 / 2)
		ctx.gg.draw_image_with_config(gg.DrawImageConfig{
			img_id:    ctx.get_icon_sheet_id()
			img_rect:  gg.Rect{this.x + 4, h, 16, 13}
			part_rect: gg.Rect{13, 3, 16, 13}
		})
	}

	x := if this.no_icon { this.x + 4 } else { this.x + node_height }

	ctx.draw_text(x, this.y + 4, os.base(this.text), ctx.font, cfg)

	if this.parent == unsafe { nil } {
		ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, ctx.theme.textbox_border)
	}

	mut y := this.y + 2

	mut hei := node_height + 5
	for mut node in this.children {
		if mut node is TreeNode {
			wid := this.width - x - 15

			mut ptr := &node
			ptr.set_bounds(x, y + node_height, wid, node_height)

			node.draw(ctx)
			change := node.draw_content(ctx, x, node.y, mut this)

			if change {
				this.is_mouse_rele = false
			}

			y += node.get_height()
			hei += node.get_height()
		}
	}

	if this.needs_pack {
		this.height = hei
	}
}
