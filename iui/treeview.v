module iui

import gg
import gx
import time
import os

// Treeview
struct Tree {
	Component_A
pub mut:
	app            &Window
	click_event_fn fn (mut Window, Tree)
	childs         []Component
	open           int
	min_y          int
	is_hover       bool
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

pub fn (mut tr Tree) draw() {
	mut mult := 20
	mut app := tr.app
	mut bg := app.theme.button_bg_normal
	bord := if tr.is_selected && tr.childs.len > 0 { app.theme.button_bg_hover } else { bg } 

    half_wid := tr.width / 2

	y := tr.y - (tr.scroll_i * 2)
	mid := tr.x + half_wid
	midy := tr.y + 10

	if tr.y >= tr.min_y {
		tr.app.draw_bordered_rect(tr.x, tr.y + 3, tr.width - 4, tr.height, 2, bg, bg)
	}
	if (abs(mid - app.mouse_x) < half_wid) && (abs(midy - app.mouse_y) < 10) {
		bg = app.theme.button_bg_hover
	}

	total_h := tr.height + (tr.open - 20)
	if (abs(mid - app.mouse_x) < half_wid) && (abs(midy - app.mouse_y) < (total_h / 2)) {
		bg = app.theme.button_bg_hover
		tr.is_hover = true
	} else {
		tr.is_hover = false
	}

	if (abs(mid - app.click_x) < half_wid) && (abs(midy - app.click_y) < 10
		&& app.bar.tik > 98 && app.click_y > 25) {
		now := time.now().unix_time_milli()

		if now - tr.last_click > 100 {
			tr.is_selected = !tr.is_selected
			tr.click_event_fn(app, *tr)

			bg = app.theme.button_bg_click
			tr.last_click = time.now().unix_time_milli()
		}
	}

	if tr.is_selected {
		if tr.childs.len <= 0 {
			tr.is_selected = false
		}
	}

	if y >= tr.min_y {
		tr.app.draw_bordered_rect(tr.x, y + 3, tr.width - 8, 20, 2, bg, bord)

		if tr.is_selected {
			tr.app.gg.draw_triangle_filled(tr.x + 5, y + 8, tr.x + 12, y + 8, tr.x + 8,
				y + 14, app.theme.text_color)
		} else if tr.childs.len > 0 {
			tr.app.gg.draw_triangle_filled(tr.x + 7, y + 6, tr.x + 12, y + 11, tr.x + 7,
				y + 16, app.theme.text_color)
		}

		tr.app.gg.draw_text(tr.x + 16, y + 4, os.base(tr.text), gx.TextCfg{
			size: tr.app.font_size
			color: tr.app.theme.text_color
		})
	}

	if tr.is_selected {
		for mut child in tr.childs {
			child.width = tr.width - 4

			draw_with_offset(mut child, tr.x, y + mult)

			if mut child is Tree {
				mult += child.open + 4
			} else {
				mult += child.height
			}
		}
	}
	tr.open = mult
}
