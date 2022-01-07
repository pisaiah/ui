module iui

import gg
import gx
import math

// Tabbox - implements Component interface
struct Tabbox {
	Component_A
pub mut:
	win            &Window
	text           string
	click_event_fn fn (mut Window, Tabbox)
	kids           map[string][]Component
	active_tab     string
}

pub fn (mut tb Tabbox) down(x int, y int) {
	//if com is Tabbox {
	//	println(com.kids.val)
	//}
	for key, mut val in tb.kids {
		for mut com in val {
			println(com.x)
		}
	}
}

// Return new Progressbar
pub fn tabbox(win &Window) Tabbox {
	return Tabbox{
		win: win
		text: ''
	}
}

// Draw this component
pub fn (mut tb Tabbox) draw() {
	t_heig := 22
	tb.win.gg.draw_empty_rounded_rect(tb.x, tb.y + t_heig - 1, tb.width, tb.height - (t_heig - 1),
		2, tb.win.theme.button_border_normal)
	mut mx := 0
	for key, mut val in tb.kids {
		mut theig := 20
		mut my := 2
		size := text_width(tb.win, key) / 2
		sizh := text_height(tb.win, key) / 2
		if tb.active_tab == key {
			theig = 22
			my = 0
		}

		tsize := (size * 2) + 14
		tb.win.draw_bordered_rect(tb.x + mx, tb.y + my, tsize, theig, 2, tb.win.theme.button_bg_normal,
			tb.win.theme.button_border_normal)

		// Draw Button Text
		tb.win.gg.draw_text((tb.x + mx + (tsize / 2)) - size, tb.y + my + (theig / 2) - sizh,
			key, gx.TextCfg{
			size: 14
			color: tb.win.theme.text_color
		})

		mut mid := (tb.x + mx + (tsize / 2))
		mut midy := (tb.y + (theig / 2))
		if (math.abs(mid - tb.win.click_x) < (tsize / 2))
			&& (math.abs(midy - tb.win.click_y) < (theig / 2)) {
			tb.active_tab = key
		}

		mx += tsize
		if tb.active_tab == key {
			for mut com in val {
				draw_with_offset(mut com, tb.x, tb.y + theig)
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
