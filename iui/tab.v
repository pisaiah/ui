module iui

import gg
import gx
import os

// Tabbox - implements Component interface
struct Tabbox {
	Component_A
pub mut:
	win            &Window
	text           string
	click_event_fn fn (mut Window, Tabbox)
	kids           map[string][]Component
	active_tab     string
	closable       bool = true
}

// Return new Progressbar
pub fn tabbox(win &Window) &Tabbox {
	return &Tabbox{
		win: win
		text: ''
	}
}

// TODO: Make this better
pub fn (mut tb Tabbox) change_title(old_title string, new_title string) {
    mut con := tb.kids[old_title]
    tb.kids[new_title] = con
    tb.active_tab = new_title
    tb.kids.delete(old_title)
}

// Draw this component
pub fn (mut tb Tabbox) draw() {
	t_heig := 22
	tb.win.gg.draw_rounded_rect_empty(tb.x, tb.y + t_heig - 1, tb.width, tb.height - (t_heig - 1),
		2, tb.win.theme.button_border_normal)
	mut mx := 0
	for key_, mut val in tb.kids {
		key := os.base(key_)
		mut theig := 20
		mut my := 2
		size := text_width(tb.win, key) / 2
		sizh := text_height(tb.win, key) / 2
		if tb.active_tab == key_ {
			theig = 22
			my = 0
		}

		mut tsize := (size * 2) + 14
		if tb.closable {
			tsize += 16
		}

		tb.win.draw_bordered_rect(tb.x + mx, tb.y + my, tsize, theig, 2, tb.win.theme.button_bg_normal,
			tb.win.theme.button_border_normal)

		// Draw Button Text
		tb.win.gg.draw_text((tb.x + mx) + 3, tb.y + my + (theig / 2) - sizh, ' ' + key,
			gx.TextCfg{
			size: tb.win.font_size
			color: tb.win.theme.text_color
		})

		if tb.closable {
			c_s := text_width(tb.win, 'x')
			csy := text_height(tb.win, 'x')
			c_x := (tb.x + mx + tsize) - c_s - 4
			c_y := tb.y + my + (theig / 2) - sizh
			tb.win.gg.draw_text(c_x, c_y, 'x', gx.TextCfg{
				size: tb.win.font_size
				color: tb.win.theme.text_color
			})

			mut mid := c_x + (c_s / 2)
			mut midy := c_y + (csy / 2)
			if (abs(mid - tb.win.click_x) < c_s) && (abs(midy - tb.win.click_y) < csy)
				&& tb.is_mouse_rele {
				tb.is_mouse_rele = false
				tb.kids.delete(key_)
				return
			}
		}

		mut mid := (tb.x + mx + (tsize / 2))
		mut midy := (tb.y + (theig / 2))
		if (abs(mid - tb.win.click_x) < (tsize / 2)) && (abs(midy - tb.win.click_y) < (theig / 2)) {
			tb.active_tab = key_
		}

		mx += tsize
		if tb.active_tab == key_ {
			for mut com in val {
				com.draw_event_fn(tb.win, &com)
				draw_with_offset(mut com, tb.x, tb.y + theig)
				com.after_draw_event_fn(tb.win, &com)
			}
		}
	}
}

pub fn (mut tb Tabbox) add_child(tab string, c Component) {
	if tb.active_tab == '' {
		tb.active_tab = tab
	}
	tb.kids[tab] << c
}
