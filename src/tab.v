module iui

import gx
import os

// Tabbox - implements Component interface
pub struct Tabbox {
	Component_A
pub mut:
	text                string
	kids                map[string][]Component
	active_tab          string
	closable            bool = true
	tab_height_active   int
	tab_height_inactive int
	compact             bool
	stretch             bool
	rows                int
}

@[params]
pub struct TabboxConfig {
pub:
	compact  bool
	stretch  bool
	closable bool = true
}

// Return new Tabbox
pub fn Tabbox.new(c TabboxConfig) &Tabbox {
	return &Tabbox{
		compact:  c.compact
		stretch:  c.stretch
		closable: c.closable
		text:     ''
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

	line_height := ctx.line_height + 8

	val := 25
	if line_height > val {
		return line_height
	}
	return val
}

pub fn (tb &Tabbox) get_tab_width(ctx &GraphicsContext, key string) int {
	if tb.stretch {
		return tb.width / tb.kids.len
	}
	if tb.compact {
		return ctx.text_width(key) + 15
	}
	return ctx.text_width(key) + 20
}

// Draw tab
fn (mut tb Tabbox) draw_tab(ctx &GraphicsContext, key_ string, mx int, my int) int {
	key := os.base(key_)
	is_active := tb.active_tab == key_

	theig := tb.get_active_tab_height(ctx)

	size := tb.get_tab_width(ctx, key)
	sizh := ctx.gg.text_height(key) / 2

	tsize := if tb.closable && !tb.stretch { size + 15 } else { size }

	ty := (theig / 2) - sizh

	if tb.active_tab == key_ {
		tab_color := tb.get_tab_color(ctx, is_active)
		xx := tb.x + mx
		r := 4
		ctx.draw_rounded_rect_filled_top(xx, tb.y + my, tsize, theig, r, ctx.theme.button_border_normal)
		ctx.draw_rounded_rect_filled_top(xx + 1, tb.y + my, tsize - 2, theig - 1, r, ctx.theme.accent_fill)
		ctx.draw_rounded_rect_filled_top(xx + 1, tb.y + my + 2, tsize - 2, theig - 1,
			r, tab_color)
	}

	// Draw Button Text
	tx := tb.x + mx + 8
	ctx.draw_text(tx, tb.y + my + ty, key, ctx.font, gx.TextCfg{
		size:  ctx.font_size
		color: ctx.theme.text_color
	})

	if tb.closable {
		tb.draw_close_btn(ctx, mx, my, tsize, theig, sizh, key_)
	}

	mid := tb.x + mx + (tsize / 2)
	midy := tb.y + my + (theig / 2)

	if abs(mid - ctx.win.click_x) < (tsize / 2) && abs(midy - ctx.win.click_y) < (theig / 2) {
		if tb.is_mouse_rele || tb.is_mouse_down {
			tb.active_tab = key_
			tb.is_mouse_rele = false
		}
	}

	return tsize
}

pub fn (mut tb Tabbox) draw_close_btn(ctx &GraphicsContext, mx int, my int, tsize int, theig int, sizh int, key_ string) {
	c_s := ctx.text_width('x')
	csy := ctx.line_height
	c_x := (tb.x + mx + tsize) - c_s - 6
	c_y := tb.y + my + (theig / 2) - (sizh / 2)

	x_size := 6

	mid := c_x + (c_s / 2)
	midy := c_y + (csy / 2)

	if abs(mid - ctx.win.click_x) < c_s && abs(midy - ctx.win.click_y) < csy {
		if tb.is_mouse_rele {
			tb.is_mouse_rele = false
			tb.kids.delete(key_)
			if tb.kids.len > 0 {
				tb.active_tab = tb.kids.keys()[tb.kids.len - 1]
			}
			return
		}
	}

	hover := abs(mid - ctx.win.mouse_x) < c_s && abs(midy - ctx.win.mouse_y) < csy

	if hover {
		offset := 3
		widhei := x_size + (offset * 2)
		ctx.draw_rounded_rect(c_x - offset, c_y - offset, widhei, widhei, 8, ctx.theme.accent_fill_third,
			ctx.theme.accent_fill_second)
	}

	color := if hover { ctx.theme.accent_text } else { ctx.theme.text_color }

	ctx.gg.draw_line(c_x, c_y, c_x + x_size, c_y + x_size, color)
	ctx.gg.draw_line(c_x, c_y + x_size, c_x + x_size, c_y, color)
}

// Draw this component
pub fn (mut tb Tabbox) draw(ctx &GraphicsContext) {
	t_heig := tb.get_active_tab_height(ctx)
	ctx.gg.draw_rect_empty(tb.x, tb.y + t_heig, tb.width, tb.height - (t_heig - 1), ctx.theme.button_border_normal)
	mut mx := 0
	mut my := 0

	if tb.scroll_i > tb.kids.len - 1 {
		tb.scroll_i = tb.kids.len - 1
	}

	tb_keys := tb.kids.keys()

	if tb_keys.len == 0 {
		return
	}

	if tb.active_tab !in tb_keys {
		tb.active_tab = tb_keys[tb_keys.len - 1]
	}

	mut rows := 0

	for i in tb.scroll_i .. tb_keys.len {
		key := tb_keys[i]
		mut val := tb.kids[key]
		if val.len == 1 {
			val[0].width = tb.width - (val[0].x * 2)
			val[0].height = tb.height - tb.get_active_tab_height(ctx) - (val[0].y * 2)
		}
		if mx + 30 > tb.width {
			mx = 0
			my += tb.get_active_tab_height(ctx)
			rows += 1
		}
		mx += tb.draw_tab(ctx, key, mx, my)
	}
	tb.rows = rows

	my += tb.get_active_tab_height(ctx)

	mut val := tb.kids[tb.active_tab]
	val.sort(a.z_index < b.z_index)

	for mut com in val {
		if !isnil(com.draw_event_fn) {
			mut win := ctx.win
			com.draw_event_fn(mut win, com)
		}
		com.draw_with_offset(ctx, tb.x, tb.y + my)
	}
}

pub fn (mut tb Tabbox) add_child(tab string, c Component) {
	if tb.active_tab == '' {
		tb.active_tab = tab
	}
	tb.kids[tab] << c
}
