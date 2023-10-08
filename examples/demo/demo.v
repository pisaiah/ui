import gg
import iui as ui { debug }
import os
import gx

struct App {
mut:
	win  &ui.Window
	pane &ui.Panel
}

[console]
fn main() {
	// Create Window
	mut window := ui.make_window(
		title: 'UI Demo'
		width: 700
		height: 480
		theme: ui.get_system_theme()
		ui_mode: true
	)

	mut pane := ui.panel(
		layout: &ui.FlowLayout{
			hgap: 10
			vgap: 10
		}
	)
	mut app := &App{
		win: window
		pane: pane
	}

	// Setup Menubar and items
	window.bar = ui.menu_bar()
	window.bar.add_child(ui.menu_item(text: 'File'))
	window.bar.add_child(ui.menu_item(text: 'Edit'))
	window.bar.add_child(create_help_menu())
	window.bar.add_child(create_theme_menu())
	window.add_child(window.bar)

	app.make_button_section()
	app.make_checkbox_section()
	app.make_selectbox_section()
	app.make_progress_section()

	mut img := ui.Image.new(
		file: 'v.png'
	)
	img.set_bounds(5, 5, 50, 50)
	mut title_box := ui.title_box('Image', [img])
	title_box.set_bounds(0, 0, 100, 130)
	pane.add_child(title_box)

	app.make_tree_section()
	app.make_tab_section()

	app.make_edits_section()

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

	mut button_tab := app.make_button_tab()
	tb.add_child('Buttons', button_tab)

	window.add_child(tb)

	window.gg.run()
}

fn (mut app App) make_button_tab() &ui.Panel {
	mut hbox := ui.Panel.new()
	hbox.set_pos(12, 12)

	mut btn := ui.button(
		text: 'Button'
	)

	mut btn2 := ui.button(
		text: 'Round Button'
	)
	btn2.border_radius = 100

	mut sq_btn := ui.button(
		text: 'Square Button'
	)
	sq_btn.border_radius = 0

	mut tbtn := ui.button(
		text: 'Button'
	)
	tbtn.override_bg_color = gx.rgba(0, 0, 0, 0)
	tbtn.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		draw_custom_themed('ocean-btn', mut e)
	})

	mut sbtn := ui.button(
		text: 'Button'
	)
	sbtn.override_bg_color = gx.rgba(0, 0, 0, 0)
	sbtn.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		draw_custom_themed('seven-btn', mut e)
	})

	img_file := $embed_file('v.png')
	mut btn3 := app.icon_btn(img_file.to_bytes())
	btn3.set_bounds(0, 0, 45, 32)
	btn3.icon_width = 28
	btn3.icon_height = 28

	hbox.add_child(btn)
	hbox.add_child(btn2)
	hbox.add_child(sq_btn)
	hbox.add_child(btn3)
	hbox.add_child(tbtn)
	hbox.add_child(sbtn)

	// hbox.pack()
	hbox.set_bounds(12, 12, 400, 500)
	return hbox
}

fn draw_custom_themed(name string, mut e ui.DrawEvent) {
	if name !in e.ctx.icon_cache {
		ui.ocean_setup(mut e.ctx.win)
		ui.seven_setup(mut e.ctx.win)
	}
	is_hover := ui.is_in(e.target, e.ctx.win.mouse_x, e.ctx.win.mouse_y)
	mut btn := e.target
	if mut btn is ui.Button {
		btn.override_bg = !is_hover
	}
	if !is_hover {
		e.ctx.gg.draw_image_by_id(btn.x, btn.y, btn.width, btn.height, e.ctx.icon_cache[name])
	}
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
			text: theme.name
			click_event_fn: theme_click
		)
		theme_menu.add_child(item)
	}
	return theme_menu
}

fn (mut app App) make_hbox_section() {
	mut hbox := ui.hbox(app.win)

	mut btn_ := ui.button(text: 'Button in HBox')
	btn_.pack()

	mut btn3 := ui.button(text: 'Button 2')
	btn3.set_pos(4, 0)
	btn3.pack()

	hbox.add_child(btn_)
	hbox.add_child(btn3)

	mut hbox_title_box := ui.title_box('HBox layout', [hbox])

	hbox.set_bounds(0, 0, 150, 0)
	hbox_title_box.set_bounds(0, 0, 200, 150)
	app.pane.add_child(hbox_title_box)
}

fn (mut app App) make_edits_section() {
	tbox := ui.text_field(
		text: 'This is a TextField'
		bounds: ui.Bounds{2, 5, 175, 30}
	)

	mut code_box := ui.text_box(['module main', '', 'fn main() {', '}'])
	code_box.set_bounds(0, 0, 175, 100)

	mut sv := ui.scroll_view(
		view: code_box
		bounds: ui.Bounds{2, 44, 175, 100}
		padding: 0
	)

	mut edits_title_box := ui.title_box('TextField / TextBox', [tbox, sv])
	edits_title_box.set_bounds(0, 0, 200, 150)
	app.pane.add_child(edits_title_box)
}

fn (mut app App) make_progress_section() {
	mut pb := ui.Progressbar.new(val: 30)
	pb.set_bounds(0, 0, 110, 24)

	mut pb2 := ui.Progressbar.new(val: 50)
	pb2.set_bounds(0, 30, 110, 24)

	mut pb3 := ui.Progressbar.new(val: 70)
	pb3.set_bounds(0, 60, 110, 24)

	mut title_box := ui.title_box('Progressbar', [pb, pb2, pb3])
	title_box.set_bounds(0, 0, 120, 130)
	app.pane.add_child(title_box)
}

fn (mut app App) make_tree_section() {
	mut tree := create_tree(app.win)
	mut tree_view := ui.scroll_view(
		bounds: ui.Bounds{0, 0, 170, 145}
		view: tree
	)

	mut title_box := ui.title_box('Treeview', [tree_view])
	title_box.set_bounds(0, 0, 190, 180)

	app.pane.add_child(title_box)
}

fn (mut app App) make_checkbox_section() {
	cbox := ui.Checkbox.new(
		text: 'Check me!'
		bounds: ui.Bounds{0, 0, 50, 25}
	)

	cbox2 := ui.Switch.new(
		text: 'Switch'
		bounds: ui.Bounds{0, 30, 50, 25}
		selected: true
	)

	mut title_box := ui.Titlebox.new(
		text: 'Checkbox/Switch'
		children: [cbox, cbox2]
	)
	title_box.set_bounds(0, 0, 130, 130)

	app.pane.add_child(title_box)
}

fn (mut app App) make_selectbox_section() {
	mut sel := ui.select_box(text: 'Selectbox')

	for i in 0 .. 3 {
		sel.items << (25 * (i + 1)).str() + '%'
	}

	mut title_box := ui.title_box('Selector', [sel])
	title_box.set_bounds(0, 0, 120, 130)
	app.pane.add_child(title_box)
}

fn (mut app App) make_button_section() {
	mut btn := ui.button(
		text: 'Button'
		bounds: ui.Bounds{0, 0, 80, 32}
	)

	mut btn2 := ui.button(
		text: 'Open Page'
		bounds: ui.Bounds{0, 38, 130, 30}
		should_pack: false
		// click_event_fn: test_page
	)
	btn2.subscribe_event('mouse_up', test_page)

	img_file := $embed_file('v.png')
	mut btn3 := app.icon_btn(img_file.to_bytes())
	btn3.set_bounds(85, 0, 45, 32)
	btn3.icon_width = 28
	btn3.icon_height = 28

	mut title_box := ui.title_box('Button', [btn, btn2, btn3])
	title_box.set_bounds(0, 0, 150, 130)
	app.pane.add_child(title_box)
}

fn (mut app App) make_tab_section() {
	mut tb := ui.Tabbox.new(
		compact: true
	)
	tb.set_bounds(2, 2, 155, 140)

	mut tbtn := ui.Button.new(text: 'In Tab A')
	tbtn.set_pos(10, 10)
	tbtn.pack()
	tb.add_child('Tab A', tbtn)

	mut tbtn1 := ui.Label.new(text: 'Now in Tab B')
	tbtn1.set_pos(10, 10)
	tbtn1.pack()
	tb.add_child('Tab B', tbtn1)

	mut title_box := ui.title_box('Tabbox', [tb])
	title_box.set_bounds(0, 0, 180, 180)

	app.pane.add_child(title_box)
}

// Make a 'Help' menu item
fn create_help_menu() &ui.MenuItem {
	help_menu := ui.menu_item(
		text: 'Help'
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

// Create the tree demo
fn create_tree(window &ui.Window) &ui.Tree2 {
	mut tree := ui.tree('My Tree')
	tree.set_bounds(0, 0, 170, 200)

	// tree.pack()
	tree.needs_pack = true

	tree.add_child(&ui.TreeNode{
		text: 'Veggies'
		open: true
		nodes: [
			&ui.TreeNode{
				text: 'Carrot'
			},
			&ui.TreeNode{
				text: 'Tomato'
			},
			&ui.TreeNode{
				text: 'Green Bean'
			},
			&ui.TreeNode{
				text: 'Onion'
			},
			&ui.TreeNode{
				text: 'Corn'
			},
			&ui.TreeNode{
				text: 'Mixed'
			},
		]
	})
	tree.add_child(&ui.TreeNode{
		text: 'Fruits'
		open: true
		nodes: [
			&ui.TreeNode{
				text: 'Apple'
			},
			&ui.TreeNode{
				text: 'Pear'
			},
			&ui.TreeNode{
				text: 'Strawberry'
			},
		]
	})
	return tree
}

// Button click
fn on_click(mut win ui.Window, com ui.Button) {
	debug('on_click')
}

// MenuItem in the Theme section click event
fn theme_click(mut win ui.Window, com ui.MenuItem) {
	text := com.text
	theme := ui.theme_by_name(text)
	win.set_theme(theme)
}

fn test_page(mut e ui.MouseEvent) {
	mut page := ui.Page.new(title: 'Page 1')
	e.ctx.win.add_child(page)

	debug('btn click')
}

fn btn_click(mut e ui.MouseEvent) {
	debug('btn click')
}
