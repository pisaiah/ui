module iui

import gg
import gx
import os

// Tabbox - implements Component interface
pub struct Tabbox {
	Component_A
pub mut:
	win                 &Window
	text                string
	click_event_fn      fn (mut Window, Tabbox)
	kids                map[string][]Component
	active_tab          string
	closable            bool = true
	tab_height_active   int
	tab_height_inactive int
	active_offset       int
	inactive_offset     int = 4
	compact             bool
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

fn (tb &Tabbox) get_tab_color(ctx &GraphicsContext, active bool) gx.Color {
	if active {
		return ctx.theme.button_bg_normal
	}
	bg := ctx.theme.button_bg_normal
	return gx.rgba(bg.r, bg.g, bg.b, 10)
}

pub fn (this &Tabbox) get_active_tab_height(ctx &GraphicsContext) int {
	if this.tab_height_active != 0 {
		return this.tab_height_active
	}

	line_height := ctx.line_height + 5

	val := 40
	if line_height > val {
		return line_height
	}
	return val
}

[deprecated]
pub fn (this &Tabbox) get_inactive_tab_height(ctx &GraphicsContext) int {
	return this.get_active_tab_height(ctx)
}

pub fn (tb &Tabbox) get_tab_width(ctx &GraphicsContext, key string) int {
	if tb.compact {
		return text_width(tb.win, key)
	}
	return text_width(tb.win, key) + 45
}

// Draw tab
fn (mut tb Tabbox) draw_tab(ctx &GraphicsContext, key_ string, mut val []Component, mx int) int {
	key := os.base(key_)
	is_active := tb.active_tab == key_

	theig := tb.get_active_tab_height(ctx)
	my := tb.active_offset

	size := tb.get_tab_width(ctx, key)
	sizh := ctx.line_height / 2

	tsize := if tb.closable { size + 30 } else { size + 14 }

	tab_color := tb.get_tab_color(ctx, is_active)
	tb.win.draw_filled_rect(tb.x + mx, tb.y + my, tsize, theig, 2, tab_color, tb.win.theme.button_border_normal)

	// Draw Button Text
	ctx.draw_text((tb.x + mx) + 3, tb.y + (theig / 2) - (sizh - 2), ' ' + key, ctx.font,
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
			com.draw_event_fn(mut tb.win, com)
			com.draw_with_offset(ctx, tb.x, tb.y + theig)
			com.after_draw_event_fn(mut tb.win, com)
		}

		line_x := if mx == 0 { tb.x + mx } else { tb.x + mx - 1 }

		ctx.gg.draw_line(line_x, tb.y + my + theig, tb.x + mx + tsize, tb.y + my + theig,
			tb.win.theme.button_bg_normal)

		ctx.gg.draw_rect_filled(line_x, tb.y + my, tsize, 4, tb.win.theme.checkbox_selected)
	}

	return tsize
}

pub fn (mut tb Tabbox) draw_close_btn(ctx &GraphicsContext, mx int, my int, tsize int, theig int, sizh int, key_ string) {
	c_s := text_width(tb.win, 'x')
	csy := text_height(tb.win, 'x')
	c_x := (tb.x + mx + tsize) - c_s - 4
	c_y := tb.y + my + (theig / 2) - (sizh / 2)

	c_yy := c_y + 4
	x_size := 6

	mid := c_x + (c_s / 2)
	midy := c_yy + (csy / 2)

	if (abs(mid - tb.win.click_x) < c_s) && (abs(midy - tb.win.click_y) < csy) {
		if tb.is_mouse_rele {
			tb.is_mouse_rele = false
			tb.kids.delete(key_)
			tb.active_tab = tb.kids.keys()[tb.kids.len - 1]
			return
		}
	}

	hover := (abs(mid - tb.win.mouse_x) < c_s) && (abs(midy - tb.win.mouse_y) < csy)

	if hover {
		offset := 4
		widhei := x_size + (offset * 2)
		ctx.gg.draw_rounded_rect_filled(c_x - offset, c_yy - offset, widhei, widhei, 32,
			ctx.theme.button_border_hover)
		ctx.gg.draw_rounded_rect_empty(c_x - offset, c_yy - offset, widhei, widhei, 32,
			gx.red)
	}

	color := get_close_btn_color(ctx, hover)

	ctx.gg.draw_line(c_x, c_yy, c_x + x_size, c_yy + x_size, color)
	ctx.gg.draw_line(c_x, c_yy + x_size, c_x + x_size, c_yy, color)
}

fn get_close_btn_color(ctx &GraphicsContext, hover bool) gx.Color {
	/*
	if hover {
		return ctx.theme.button_border_hover
	}*/
	return ctx.theme.text_color
}

// Draw this component
pub fn (mut tb Tabbox) draw(ctx &GraphicsContext) {
	t_heig := tb.get_active_tab_height(ctx)
	ctx.gg.draw_rect_empty(tb.x, tb.y + t_heig, tb.width, tb.height - (t_heig - 1), ctx.theme.button_border_normal)
	mut mx := 0

	if tb.scroll_i > tb.kids.len - 1 {
		tb.scroll_i = tb.kids.len - 1
	}

	tb_keys := tb.kids.keys()

	if tb.active_tab !in tb_keys {
		tb.active_tab = tb_keys[tb_keys.len - 1]
	}

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