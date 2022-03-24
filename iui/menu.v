module iui

import gg
import gx
import v.util.version { full_v_version }

[heap]
struct Menubar {
	Component_A
pub mut:
	app   &Window
	theme Theme
	items []MenuItem
	tik   int
}

pub fn (mut bar Menubar) add_child(com MenuItem) {
	bar.items << com
}

pub fn (mut bar Menubar) is_hovering() bool {
	for mut item in bar.items {
		if item.show_items {
			return true
		}
	}
	return false
}

[heap]
struct MenuItem {
	Component_A
pub mut:
	items          []MenuItem
	text           string
	icon           &Image
	shown          bool
	show_items     bool
	click_event_fn fn (mut Window, MenuItem)
}

pub fn (mut item MenuItem) add_child(com MenuItem) {
	item.items << com
}

pub fn menuitem(text string) &MenuItem {
	return &MenuItem{
		text: text
		shown: false
		show_items: false
		icon: 0
		click_event_fn: fn (mut win Window, item MenuItem) {}
	}
}

pub fn (mut com MenuItem) set_click(b fn (mut Window, MenuItem)) {
	com.click_event_fn = b
}

pub fn menubar(app &Window, theme Theme) &Menubar {
	return &Menubar{
		app: app
		theme: theme
	}
}

pub fn (mut bar Menubar) draw() {
	mut wid := gg.window_size().width
	if bar.width > 0 {
		wid = bar.width
	}

	bar.app.gg.draw_rounded_rect_filled(bar.x, bar.y, wid, 25, 2, bar.app.theme.menubar_background)
	bar.app.gg.draw_rounded_rect_empty(bar.x, bar.y, wid, 25, 2, bar.app.theme.menubar_border)

	mut mult := 0
	for mut item in bar.items {
		bar.app.draw_menu_button(mult, bar.y, 56, 25, mut item)
		if item.width > 0 {
			mult += item.width + 4
		} else {
			mult += 56
		}
	}
}

fn (mut app Window) get_bar() &Menubar {
	return app.bar
}

fn (mut app Window) draw_menu_button(x int, y int, width_ int, height int, mut item MenuItem) {
	size := text_width(app, item.text) / 2
	sizh := text_height(app, item.text) / 2

	mut width := width_
	if item.width > 0 {
		width = item.width + 4
	}

	mut bg := app.theme.menubar_background
	mut border := app.theme.menubar_border

	mut midx := (x + (width / 2))
	mut midy := (y + (height / 2))

	// Detect Hover
	if (abs(midx - app.mouse_x) < (width / 2)) && (abs(midy - app.mouse_y) < (height / 2)) {
		bg = app.theme.button_bg_hover
		border = app.theme.button_border_hover
	}

	// Detect Click
	mut clicked := ((abs(midx - app.click_x) < (width / 2))
		&& (abs(midy - app.click_y) < (height / 2)))
	if clicked && !item.show_items {
		bg = app.theme.button_bg_click
		border = app.theme.button_border_click
		item.show_items = true
		app.bar.tik = 0

		item.click_event_fn(app, *item)

		if item.text == 'About iUI' {
			mut about := modal(app, 'About iUI')
			about.in_height = 250
			about.in_width = 320

			mut title := label(app, 'iUI ')
			title.set_pos(40, 16)
			title.set_config(16, false, true)
			title.pack()
			about.add_child(title)

			mut lbl := label(app, "Isaiah's UI Toolkit for V.\nVersion: " + version +
				'\nCompiled with ' + full_v_version(false))
			lbl.set_pos(40, 70)
			about.add_child(lbl)

			mut gh := button(app, 'Github')
			gh.set_pos(40, 135)
			gh.set_click(fn (mut win Window, com Button) {
				open_url('https://github.com/isaiahpatton/ui')
			})
			gh.pack()
			about.add_child(gh)

			mut copy := label(app, 'Copyright © 2021-2022 Isaiah.')
			copy.set_pos(40, 185)
			copy.set_config(12, true, false)
			about.add_child(copy)

			app.add_child(about)
		}
	}

	if item.show_items && item.items.len > 0 {
		bg = app.theme.button_bg_click
		border = app.theme.button_border_click
		app.bar.tik = 0
		mut wid := 100

		for mut sub in item.items {
			sub_size := text_width(app, sub.text + '...')
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

	if item.show_items && (item.items.len == 0 || (app.click_x != -1 && app.click_y != -1))
		&& !clicked {
		item.show_items = false
		item.is_mouse_rele = true
	}
	if !item.show_items && app.bar.tik < 99 {
		app.bar.tik++
	}

	// Draw Button Background & Border
	app.gg.draw_rounded_rect_filled(x, y, width, height, 2, bg)
	app.gg.draw_rounded_rect_empty(x, y, width, height, 2, border)

	// Draw Button Text
	if item.icon != 0 {
		draw_with_offset(mut item.icon, x + (width / 2) - (item.icon.width / 2), y)
	} else {
		app.gg.draw_text((x + (width / 2)) - size, y + (height / 2) - sizh, item.text,
			gx.TextCfg{
			size: app.font_size
			color: app.theme.text_color
		})
	}

	mut com := &Component(item)
	com.draw_event_fn(app, com)
}
