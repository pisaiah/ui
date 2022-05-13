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

// Draw tab
fn (mut tb Tabbox) draw_tab(ctx &GraphicsContext, key_ string, mut val []Component, mx int) int {
	key := os.base(key_)
	is_active := tb.active_tab == key_

	theig := if is_active { 30 } else { 25 }
	my := if is_active { 0 } else { 4 }

	size := text_width(tb.win, key) + 4
	sizh := text_height(tb.win, key) / 2

	tsize := if tb.closable { size + 30 } else { size + 14 }

	tb.win.draw_filled_rect(tb.x + mx, tb.y + my, tsize, theig, 2, tb.win.theme.button_bg_normal,
		tb.win.theme.button_border_normal)

	if tb.active_tab == key_ {
		ctx.gg.draw_line(tb.x + mx + 1, tb.y + my + theig, tb.x + mx + tsize, tb.y + my + theig,
			ctx.theme.button_bg_normal)
	}

	// Draw Button Text
	ctx.draw_text((tb.x + mx) + 3, tb.y + my + (theig / 2) - sizh, ' ' + key, ctx.font,
		gx.TextCfg{
		size: tb.win.font_size
		color: tb.win.theme.text_color
	})

	if tb.closable {
		tb.draw_close_btn(ctx, mx, my, tsize, theig, sizh, key_)
	}

	mid := (tb.x + mx + (tsize / 2))
	midy := (tb.y + (theig / 2))
	if (abs(mid - tb.win.click_x) < (tsize / 2)) && (abs(midy - tb.win.click_y) < (theig / 2)) {
		tb.active_tab = key_
	}

	// mx += tsize
	if tb.active_tab == key_ {
		val.sort(a.z_index < b.z_index)
		for mut com in val {
			com.draw_event_fn(tb.win, com)
			com.draw_with_offset(ctx, tb.x, tb.y + theig)
			com.after_draw_event_fn(tb.win, com)
		}
	}
	return tsize
}

pub fn (mut tb Tabbox) draw_close_btn(ctx &GraphicsContext, mx int, my int, tsize int, theig int, sizh int, key_ string) {
	ctx.set_cfg(gx.TextCfg{
		size: tb.win.font_size - 3
		color: ctx.theme.text_color
	})

	c_s := text_width(tb.win, 'X')
	csy := text_height(tb.win, 'X')
	c_x := (tb.x + mx + tsize) - c_s - 4
	c_y := tb.y + my + (theig / 2) - sizh

	mid := c_x + (c_s / 2)
	midy := c_y + (csy / 2)

	hover := (abs(mid - tb.win.mouse_x) < c_s) && (abs(midy - tb.win.mouse_y) < csy)

	if (abs(mid - tb.win.click_x) < c_s) && (abs(midy - tb.win.click_y) < csy) {
		if tb.is_mouse_rele {
			tb.is_mouse_rele = false
			tb.kids.delete(key_)
			tb.active_tab = tb.kids.keys()[tb.kids.len - 1]
			return
		}
	}

	if hover {
		ctx.gg.draw_rounded_rect_filled(c_x - 3, c_y, c_s + 4, csy + 2, 16, ctx.theme.button_border_hover)
	}

	ctx.draw_text(c_x, c_y, 'x', ctx.font, gx.TextCfg{
		size: tb.win.font_size - 3
		color: ctx.theme.text_color
	})

	ctx.set_cfg(gx.TextCfg{
		size: tb.win.font_size
		color: ctx.theme.text_color
	})
}

// Draw this component
pub fn (mut tb Tabbox) draw(ctx &GraphicsContext) {
	t_heig := 30
	ctx.gg.draw_rect_empty(tb.x, tb.y + t_heig - 1, tb.width, tb.height - (t_heig - 1),
		ctx.theme.button_border_normal)
	mut mx := 0

	if tb.scroll_i > tb.kids.len - 1 {
		tb.scroll_i = tb.kids.len - 1
	}

	tb_keys := tb.kids.keys()
	for i in tb.scroll_i .. tb_keys.len {
		key := tb_keys[i]
		mut val := tb.kids[key]
		mx += tb.draw_tab(ctx, key, mut val, mx)
	}
}

pub fn (mut tb Tabbox) add_child(tab string, c Component) {
	if tb.active_tab == '' {
		tb.active_tab = tab
	}
	tb.kids[tab] << c
}
