module iui

import gg
import gx
import time
import math

// Select - implements Component interface
struct Select {
	Component_A
pub mut:
	app             &Window
	text            string
	click_event_fn  fn (mut Window, Select)
	change_event_fn fn (mut Window, Select, string, string)
	items           []string
	shown           bool
	show_items      bool
}

pub fn selector(app &Window, text string) &Select {
	return &Select{
		text: text
		app: app
		click_event_fn: fn (mut win Window, a Select) {}
		change_event_fn: fn (mut win Window, a Select, old string, neww string) {}
		z_index: 1
	}
}

pub fn (mut com Select) set_click(b fn (mut Window, Select)) {
	com.click_event_fn = b
}

pub fn (mut com Select) set_change(b fn (mut Window, Select, string, string)) {
	com.change_event_fn = b
}

pub fn (mut item Select) draw() {
	x := item.x
	y := item.y
	app := item.app
	width := item.width
	height := item.height
	size := text_width(app, item.text) / 2
	sizh := text_height(app, item.text) / 2

	mut bg := app.theme.button_bg_normal
	mut border := app.theme.button_border_normal

	mut midx := (x + (width / 2))
	mut midy := (y + (height / 2))

	// Detect Hover
	if (math.abs(midx - app.mouse_x) < (width / 2)) && (math.abs(midy - app.mouse_y) < (height / 2)) {
		bg = app.theme.button_bg_hover
		border = app.theme.button_border_hover
	}

	// Detect Click
	mut clicked := ((math.abs(midx - app.click_x) < (width / 2))
		&& (math.abs(midy - app.click_y) < (height / 2)))

	if clicked && !item.show_items {
		bg = app.theme.button_bg_click
		border = app.theme.button_border_click
		item.show_items = true

		item.click_event_fn(app, *item)
	}

	if item.show_items && item.items.len > 0 {
		bg = app.theme.button_bg_click
		border = app.theme.button_border_click
		mut wid := 100

		for mut sub in item.items {
			sub_size := text_width(app, sub + '...')
			if wid < sub_size {
				wid = sub_size
			}
		}

		app.draw_bordered_rect(x, y + height, wid, (item.items.len * 26) + 2, 2, app.theme.dropdown_background,
			app.theme.dropdown_border)

		mut mult := 0
		for mut sub in item.items {
			// app.draw_menu_button(x + 1, y + height + mult + 1, wid - 2, 25, mut sub)
			mut subb := button(app, sub)
			app.draw_button_2(x + 1, y + height + mult + 1, wid - 2, 25, mut subb, mut
				item)

			mult += 26
		}
	}

	if item.show_items && app.click_x != -1 && app.click_y != -1 && !clicked {
		item.show_items = false
	}

	// Draw Button Background & Border
	app.gg.draw_rounded_rect_filled(x, y, width, height, 2, bg)
	app.gg.draw_rounded_rect_empty(x, y, width, height, 2, border)

	// Draw Button Text
	app.gg.draw_text((x + (width / 2)) - size - 4, y + (height / 2) - sizh, item.text,
		gx.TextCfg{
		size: app.font_size
		color: app.theme.text_color
	})

	// Draw down arrow
	char_height := app.gg.text_height('.') / 2
	app.gg.draw_triangle_filled(x + width - 20, y + (height / 2) - char_height, x + width - 15,
		y + (height / 2) + 5 - char_height, x + width - 10, y + (height / 2) - char_height,
		app.theme.text_color)
}

fn (app &Window) draw_button_2(x int, y int, width int, height int, mut btn Button, mut sel Select) {
	mut y1 := y
	if !app.show_menu_bar {
		y1 = y1 - 25
	}

	text := btn.text
	size := text_width(app, text) / 2
	sizh := text_height(app, text) / 2

	mut bg := app.theme.button_bg_normal
	mut border := app.theme.button_border_normal

	mut mid := (x + (width / 2))
	mut midy := (y1 + (height / 2))

	// Detect Hover
	if (math.abs(mid - app.mouse_x) < (width / 2)) && (math.abs(midy - app.mouse_y) < (height / 2)) {
		bg = app.theme.button_bg_hover
		border = app.theme.button_border_hover
	}

	// Detect Click
	// if btn.is_mouse_down {
	if (math.abs(mid - app.click_x) < (width / 2)) && (math.abs(midy - app.click_y) < (height / 2)) {
		now := time.now().unix_time_milli()

		// TODO: Better click time
		if now - btn.last_click > 100 {
			btn.click_event_fn(app, *btn)
			btn.is_selected = true

			old_text := sel.text
			sel.text = btn.text
			sel.change_event_fn(sel.app, *sel, old_text, sel.text)

			bg = app.theme.button_bg_click
			border = app.theme.button_border_click
			btn.last_click = time.now().unix_time_milli()
		}
	} else {
		btn.is_selected = false
	}

	// Draw Button Background & Border
	app.gg.draw_rounded_rect_filled(x, y1, width, height, 4, bg)
	app.gg.draw_rounded_rect_empty(x, y1, width, height, 4, border)

	// Draw Button Text
	app.gg.draw_text((x + (width / 2)) - size, y1 + (height / 2) - sizh, text, gx.TextCfg{
		size: app.font_size
		color: app.theme.text_color
	})
}
