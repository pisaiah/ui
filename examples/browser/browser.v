module main

import iui as ui
import os

[console]
fn main() {
	println('Browser - Alpha Test')

	mut win := ui.window(ui.get_system_theme(), 'Browser', 800, 600)
	mut bar := ui.menubar(win, win.theme)

	help_menu := ui.menu_item(
		text: 'Help'
		children: [
			ui.menu_item(
				text: 'About Browser'
				click_event_fn: about_click
			),
			ui.menu_item(
				text: 'About iUI'
			),
		]
	)

	bar.add_child(help_menu)
	win.bar = bar

	mut tb := ui.tabbox(win)
	tb.set_id(mut win, 'tabbar')
	tb.set_bounds(0, 30, 0, 0)
	tb.draw_event_fn = tabs_draw
	win.add_child(tb)

	create_tab(mut win, mut tb)

	win.gg.run()
}

// Make menu bar look like url bar.
fn menu_bar_status_theme(cur ui.Theme) ui.Theme {
	return ui.Theme{
		...cur
		menubar_background: cur.button_bg_normal
		menubar_border: cur.button_bg_normal
	}
}

// Create tab
fn create_tab(mut win ui.Window, mut tb ui.Tabbox) {
	mut lbl := ui.label(win, 'Hello world!')

	lbl.pack()

	menubar_has_tab_color := menu_bar_status_theme(win.theme)

	mut bar := ui.menubar(win, menubar_has_tab_color)

	// Back Button
	mut back := ui.menuitem('<')
	back.width = 30
	back.no_paint_bg = true
	bar.add_child(back)

	// Forward Buttom
	mut forward := ui.menuitem('>')
	forward.width = 30
	forward.no_paint_bg = true
	bar.add_child(forward)

	// default_page_url := 'http://frogfind.com'
	default_page_url := 'file://' + os.resource_abs_path('test.html')

	mut urlbar := ui.textedit(win, default_page_url)
	urlbar.draw_line_numbers = false
	urlbar.code_syntax_on = false
	urlbar.padding_y = 5
	urlbar.z_index = 5
	urlbar.set_bounds(140, 0, 600, 25)
	urlbar.before_txtc_event_fn = before_txt_change

	tb.add_child('Test Tab', lbl)
	tb.add_child('Test Tab', bar)
	tb.add_child('Test Tab', urlbar)

	mut status := ui.menubar(win, menubar_has_tab_color)
	status.z_index = 20
	status.draw_event_fn = status_bar_draw

	mut item := ui.menu_item(text: ' ')
	item.no_paint_bg = true
	item.draw_event_fn = status_item_draw
	status.add_child(item)

	tb.add_child('Test Tab', status)

	set_status(mut win, 'Loading...')

	load_url(mut win, default_page_url)
	// load_url(mut win, 'http://frogfind.com')
}

fn set_status(mut win ui.Window, text string) {
	win.extra_map['browser-status'] = text
}

fn status_item_draw(mut win ui.Window, com &ui.Component) {
	mut this := *com
	this.text = win.extra_map['browser-status']
	this.width = ui.text_width(win, this.text)
}

fn before_txt_change(mut win ui.Window, tb ui.TextEdit) bool {
	mut is_enter := tb.last_letter == 'enter'

	if is_enter {
		txt := tb.lines[tb.carrot_top]
		load_url(mut win, txt)
		return true
	}
	return false
}

fn box_draw_fn(mut win ui.Window, com &ui.Component) {
	size := win.gg.window_size()
	mut this := *com
	this.width = size.width
	if this.height > 40 {
		this.height = size.height
	}
}

fn width_draw_fn(mut win ui.Window, com &ui.Component) {
	size := win.gg.window_size()
	mut this := *com
	this.width = size.width
	if this.height > 40 {
		this.height = size.height - 102
	}
}

fn status_bar_draw(mut win ui.Window, com &ui.Component) {
	size := win.gg.window_size()
	mut this := *com
	this.y = (size.height - 25) - 30 - 22
}

fn add_child(mut box ui.Component, child &ui.Component) {
	if mut box is ui.VBox {
		box.add_child(child)
	}
	if mut box is ui.HBox {
		box.add_child(child)
	}
}

fn tabs_draw(mut win ui.Window, com &ui.Component) {
	mut this := *com
	if mut this is ui.Tabbox {
		size := win.gg.window_size()
		this.width = size.width
		this.height = size.height - 30
	}
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut about := ui.modal(win, 'About FrogBrowser')
	about.in_height = 350
	about.in_width = 670

	mut title := ui.label(win, 'Frog Browser')
	title.set_pos(80, 8)
	title.set_config(16, false, true)
	title.pack()
	about.add_child(title)

	mut lbl := ui.label(win,
		'Version 0.1\nFrogbrowser is a simple web browser designed for Frogfind.com / 68k.news' +
		'\n\nThis program is free software licensed under\nthe GNU General Public License v2.\n\nIcons by Icons8')
	lbl.set_pos(80, 80)
	about.add_child(lbl)

	mut copy := ui.label(win, 'Copyright © 2021-2022 Isaiah. All Rights Reserved')
	copy.set_pos(80, 210)
	copy.set_config(12, true, false)
	about.add_child(copy)

	win.add_child(about)
}
