import gg
import iui as ui { debug }
import os
import gx

struct App {
mut:
	win  &ui.Window
	pane &ui.Panel
}

@[console]
fn main() {
	// Create Window
	mut window := ui.make_window(
		title:   'UI Demo'
		width:   700
		height:  480
		theme:   ui.get_system_theme()
		ui_mode: false
	)

	mut pane := ui.panel(
		layout: &ui.FlowLayout{
			hgap: 10
			vgap: 10
		}
	)
	mut app := &App{
		win:  window
		pane: pane
	}

	// Setup Menubar and items
	window.bar = ui.menu_bar()
	window.bar.add_child(ui.menu_item(text: 'File'))
	window.bar.add_child(ui.menu_item(text: 'Edit'))
	window.bar.add_child(create_help_menu())
	window.bar.add_child(create_theme_menu())
	window.add_child(window.bar)

	// app.make_button_section()
	// app.make_checkbox_section()
	// app.make_selectbox_section()
	// app.make_progress_section()

	// mut v_img := window.gg.create_image(os.resource_abs_path('v.png')) or { panic(err) }
	// mut img := ui.image(window, v_img)
	// img.set_bounds(5, 5, 50, 50)
	// mut title_box := ui.title_box('Image', [img])
	// title_box.set_bounds(0, 0, 100, 130)
	// pane.add_child(title_box)

	// app.make_tree_section()
	// app.make_tab_section()
	// app.make_edits_section()
	pane.set_pos(4, 10)

	pane.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		ws := e.ctx.gg.window_size()
		e.target.width = ws.width
		e.target.height = ws.height
	})

	mut tb := ui.tabbox(window)
	tb.set_pos(2, 30)
	tb.draw_event_fn = fn (mut win ui.Window, mut com ui.Component) {
		ws := win.gg.window_size()
		com.width = ws.width - 4
		com.height = ws.height - 32
	}
	tb.add_child('Overview', pane)

	// mut button_tab := app.make_button_tab()
	// tb.add_child('Buttons', button_tab)
	window.add_child(tb)

	window.gg.run()
}

fn (mut app App) icon_btn(data []u8) &ui.Button {
	mut gg_ := app.win.gg
	gg_im := gg_.create_image_from_byte_array(data) or { panic(err) }
	cim := gg_.cache_image(gg_im)
	mut btn := ui.button_with_icon(cim)

	btn.set_bounds(2, 4, 32, 32)
	return btn
}

// Make a 'Theme' menu item to select themes
fn create_theme_menu() &ui.MenuItem {
	mut theme_menu := ui.menu_item(
		text: 'Themes'
	)

	themes := ui.get_all_themes()
	for theme in themes {
		item := ui.menu_item(
			text:           theme.name
			click_event_fn: theme_click
		)
		theme_menu.add_child(item)
	}
	return theme_menu
}

// Make a 'Help' menu item
fn create_help_menu() &ui.MenuItem {
	help_menu := ui.menu_item(
		text:     'Help'
		children: [
			ui.menu_item(
				text: 'Item 1'
			),
			ui.menu_item(
				text: 'Item 2'
				// click_event_fn: menu_click
			),
			ui.menu_item(
				text: 'About iUI'
			),
		]
	)
	return help_menu
}

// MenuItem in the Theme section click event
fn theme_click(mut win ui.Window, com ui.MenuItem) {
	text := com.text
	theme := ui.theme_by_name(text)
	win.set_theme(theme)
}

fn test_page(mut e ui.MouseEvent) {
	mut page := ui.page(e.ctx.win, 'Page 1')
	e.ctx.win.add_child(page)

	debug('btn click')
}

fn btn_click(mut e ui.MouseEvent) {
	debug('btn click')
}
