module iui

import gg
import gx
import math

// Tabbox - implements Component interface
struct Tabbox {
pub mut:
	win            &Window
	text           string
	x              int
	y              int
	width          int
	height         int
	last_click     f64
	click_event_fn fn (mut Window, Tabbox)
	is_selected    bool
	carrot_index   int = 1
	z_index        int
	scroll_i       int
	kids		   map[string][]Component
	active_tab	   string
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
	theig := 20
	tb.win.gg.draw_empty_rounded_rect(tb.x, tb.y + theig - 1, tb.width, tb.height - (theig-1), 2, tb.win.theme.button_border_normal)
	mut mx := 0
	for key, mut val in tb.kids {
		size := text_width(tb.win, key) / 2
		sizh := text_height(tb.win, key) / 2

		tsize := (size*2) + 10
		tb.win.draw_bordered_rect(tb.x + mx, tb.y, tsize, theig, 2, tb.win.theme.button_bg_normal, tb.win.theme.button_border_normal)
		
		// Draw Button Text
		tb.win.gg.draw_text((tb.x + mx + (tsize / 2)) - size, tb.y + (theig / 2) - sizh, key, gx.TextCfg{
			size: 14
			color: tb.win.theme.text_color
		})

		mut mid := (tb.x + mx + (tsize / 2))
		mut midy := (tb.y + (theig / 2))
		if (math.abs(mid - tb.win.click_x) < (tsize / 2)) && (math.abs(midy - tb.win.click_y) < (theig / 2)) {
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
