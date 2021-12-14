module iui

import gg
import gx
import math

[heap]
struct Menubar {
pub mut:
	app   &Window
	theme Theme
	items []MenuItem
}

pub fn (mut bar Menubar) add_child(com MenuItem) {
	bar.items << com
}

[heap]
struct MenuItem {
pub mut:
	items          []MenuItem
	text           string
	shown          bool
	show_items     bool
	click_event_fn fn (mut Window, MenuItem)
}

pub fn (mut item MenuItem) add_child(com MenuItem) {
	item.items << com
}

pub fn menuitem(text string) MenuItem {
	return MenuItem{
		text: text
		shown: false
		show_items: false
		click_event_fn: blank_event_mi
	}
}

fn blank_event_mi(mut win Window, item MenuItem) {
}

pub fn (mut com MenuItem) set_click(b fn (mut Window, MenuItem)) {
	com.click_event_fn = b
}

pub fn menubar(app &Window, theme Theme) Menubar {
	return Menubar{
		app: app
		theme: theme
	}
}

fn (mut mb Menubar) draw() {
	mut wid := gg.window_size().width
	mb.app.gg.draw_rounded_rect(0, 0, wid, 25, 2, mb.app.theme.menubar_background)
	mb.app.gg.draw_empty_rounded_rect(0, 0, wid, 25, 2, mb.app.theme.menubar_border)

	mut mult := 0
	for mut item in mb.items {
		mb.app.draw_menu_button(50 * mult, 0, 50, 25, mut item)
		mult++
	}
}

fn (mut app Window) get_bar() Menubar {
	return app.bar
}

fn (mut app Window) draw_menu_button(x int, y int, width int, height int, mut item MenuItem) {
	size := app.gg.text_width(item.text) / 2
	sizh := app.gg.text_height(item.text) / 2

	mut bg := app.theme.menubar_background
	mut border := app.theme.menubar_border

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

		if item.text == 'About iUI' {
			app.message_box('About iUI', "Isaiah's UI Toolkit for V.\nVersion: " + version +
				'\n\nCopyright (c) 2021-2022 Isaiah.\nAll Rights Reserved.')
		}
	}

	if item.show_items && item.items.len > 0 {
		bg = app.theme.button_bg_click
		border = app.theme.button_border_click
		mut wid := 100

		for mut sub in item.items {
			sub_size := app.gg.text_width(sub.text + '...')
			if wid < sub_size {
				wid = sub_size
			}
		}

		app.draw_bordered_rect(x, y + height, wid, (item.items.len * 26) + 2, 2, app.theme.dropdown_background,
			app.theme.dropdown_border)

		mut mult := 0
		for mut sub in item.items {
			app.draw_menu_button(x + 1, y + height + mult + 1, wid - 2, 25, mut sub)
			mult += 26
		}
	}

	if item.show_items && app.click_x != -1 && app.click_y != -1 && !clicked {
		item.show_items = false
	}

	// Draw Button Background & Border
	app.gg.draw_rounded_rect(x, y, width, height, 2, bg)
	app.gg.draw_empty_rounded_rect(x, y, width, height, 2, border)

	// Draw Button Text
	app.gg.draw_text((x + (width / 2)) - size, y + (height / 2) - sizh, item.text, gx.TextCfg{
		size: 14
		color: app.theme.text_color
	})
}
