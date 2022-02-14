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
	is_hover	   bool
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
	//println(tr.scroll_i)
	mut mult := 20
	mut app := tr.app
	mut bg := app.theme.button_bg_normal
	mut bord := bg

	y := tr.y - tr.scroll_i
	mut mid := (tr.x + (tr.width / 2))
	mut midy := ((tr.y) + 3 + (20 / 2))

	tr.app.draw_bordered_rect(tr.x + 4, tr.y + 3, tr.width - 8, tr.height, 2, bg, bord)
	if (abs(mid - app.mouse_x) < (tr.width / 2)) && (abs(midy - app.mouse_y) < (20 / 2)) {
		bg = app.theme.button_bg_hover
	}

	total_h := tr.height + (tr.open-20)
	if (abs(mid - app.mouse_x) < (tr.width / 2)) && (abs(midy - app.mouse_y) < (total_h / 2)) {
		bg = app.theme.button_bg_hover
		tr.is_hover = true
	} else {
		tr.is_hover = false
	}

	if (abs(mid - app.click_x) < (tr.width / 2)) && (abs(midy - app.click_y) < (20 / 2)
		&& app.bar.tik > 50) {
		now := time.now().unix_time_milli()

		if now - tr.last_click > 100 {
			tr.is_selected = !tr.is_selected
			tr.click_event_fn(app, *tr)

			bg = app.theme.button_bg_click

			// border = app.theme.button_border_click
			tr.last_click = time.now().unix_time_milli()
		}
	}

	if tr.is_selected {
		if tr.childs.len > 0 {
			// bg = app.theme.button_bg_hover
			bord = app.theme.button_bg_hover
		} else {
			tr.is_selected = false
		}
	}

	tr.app.draw_bordered_rect(tr.x + 4, y + 3, tr.width - 8, 20, 2, bg, bord)

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

	mut multx := 4
	if tr.is_selected {
		for mut child in tr.childs {
			child.width = tr.width - (multx * 2)
			draw_with_offset(mut child, tr.x + multx, y + mult)

			if mut child is Tree {
				mult += child.open + 4
			} else {
				mult += child.height
			}
		}
	}
	tr.open = mult
}