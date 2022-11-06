module iui

import gg
import gx
import os

// Treeview
[deprecated]
pub struct Tree {
	Component_A
pub mut:
	app            &Window
	click_event_fn fn (mut Window, Tree)
	childs         []Component
	open           int
	min_y          int
	is_child       bool
	is_hover       bool
	padding_top    int
	parent_height  int
}

pub fn (mut tree Tree) set_click(myfn fn (mut Window, Tree)) {
	tree.click_event_fn = myfn
}

pub fn tree(app &Window, text string) Tree {
	return Tree{
		text: text
		app: app
		click_event_fn: fn (mut a Window, b Tree) {}
	}
}

fn (mut com Tree) draw_scrollbar(cl int, spl_len int) {
	// Calculate postion for scroll
	height := com.height - 4
	sth := int((f32((com.scroll_i)) / f32(spl_len - 1)) * height) + com.padding_top
	enh := int((f32(cl) / f32(spl_len)) * height) - (com.padding_top * 2) - com.padding_top
	requires_scrollbar := (height - enh) > 0

	// Draw Scroll
	if requires_scrollbar {
		wid := 10
		min := wid + 1

		com.app.draw_bordered_rect(com.x + com.width - min, com.y + 1, wid, height - 2,
			2, com.app.theme.scroll_track_color, com.app.theme.button_bg_hover)
		com.app.draw_bordered_rect(com.x + com.width - min, com.y + sth + 1, wid, enh - 2,
			2, com.app.theme.scroll_bar_color, com.app.theme.scroll_track_color)
	}
}

pub fn (mut tr Tree) draw(ctx &GraphicsContext) {
	mut mult := 20
	mut app := tr.app
	bord := if tr.is_selected && tr.childs.len > 0 {
		ctx.theme.button_bg_hover
	} else {
		ctx.theme.button_bg_normal
	}

	half_wid := tr.width / 2

	scroll_height := 25 // text_height(app, 'A') / 2
	y := tr.y - (tr.scroll_i * scroll_height) + tr.padding_top
	mid := tr.x + half_wid
	midy := tr.y + 10

	if tr.y >= tr.min_y {
		bg := ctx.theme.button_bg_normal
		ctx.gg.draw_rect_filled(tr.x, tr.y + 3, tr.width - 4, tr.height, bg)
	}

	if (abs(mid - app.mouse_x) < half_wid) && (abs(midy - app.mouse_y) < tr.height / 2) {
		tr.is_hover = true
	} else {
		tr.is_hover = false
	}

	if (abs(mid - app.mouse_x) < half_wid) && (abs(midy - app.mouse_y) < 10) {
		bg := ctx.theme.button_bg_hover
		if y >= tr.min_y {
			tr.app.draw_bordered_rect(tr.x, y + 3, tr.width - 8, 20, 2, bg, bord)
		}
	}

	if (abs(mid - app.click_x) < half_wid) && (abs(midy - app.click_y) < 10 && app.bar.tik > 98
		&& app.click_y > 25) && tr.is_mouse_rele {
		tr.is_mouse_rele = false

		tr.is_selected = !tr.is_selected
		tr.click_event_fn(mut app, *tr)

		bg := app.theme.button_bg_click
		tr.app.draw_bordered_rect(tr.x, y + 3, tr.width - 8, 20, 2, bg, bord)
	}

	if tr.is_selected {
		if tr.childs.len <= 0 {
			tr.is_selected = false
		}
	}

	if y >= tr.min_y {
		if tr.is_selected {
			tr.app.gg.draw_triangle_filled(tr.x + 5, y + 8, tr.x + 12, y + 8, tr.x + 8,
				y + 14, app.theme.text_color)
		} else if tr.childs.len > 0 {
			tr.app.gg.draw_triangle_filled(tr.x + 7, y + 6, tr.x + 12, y + 11, tr.x + 7,
				y + 16, app.theme.text_color)
		}

		ctx.draw_text(tr.x + 16, y + 4, os.base(tr.text), ctx.font, gx.TextCfg{
			size: tr.app.font_size
			color: tr.app.theme.text_color
		})
	}

	if tr.is_selected {
		for mut child in tr.childs {
			child.width = tr.width - 8
			child.is_mouse_down = tr.is_mouse_down
			child.is_mouse_rele = tr.is_mouse_rele

			if mut child is Tree {
				if !tr.is_child {
					child.parent_height = tr.height
				} else {
					child.parent_height = tr.parent_height
				}
				child.is_child = true
			}

			child.draw_with_offset(ctx, tr.x, y + mult)

			tr.is_mouse_rele = child.is_mouse_rele

			if mut child is Tree {
				mult += child.open + 5
			} else {
				mult += child.height
			}
		}
	}

	tr.open = mult

	if !tr.is_child {
		tr.draw_scrollbar((tr.height / 25) - 1, ((tr.open) / 25) + 1)
	}
}
