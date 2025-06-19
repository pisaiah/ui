module main

import iui as ui { debug }
import iui.themes
import os
import gx

const img_file = $embed_file('v.png')

@[heap]
struct App {
mut:
	win   &ui.Window
	pane  &ui.Panel
	icons []int
	dp    &ui.DesktopPane
}

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title:           'UI Demo'
		width:           700
		height:          480
		theme:           ui.get_system_theme()
		ui_mode:         true
		custom_titlebar: true
	)

	mut pane := ui.Panel.new(
		layout: ui.FlowLayout.new(hgap: 10, vgap: 10)
	)
	mut app := &App{
		win:  window
		pane: pane
		dp:   ui.DesktopPane.new()
	}

	// Setup Menubar and items
	window.bar = ui.Menubar.new()
	window.bar.set_padding(4)
	window.bar.set_animate(true)
	window.bar.add_child(ui.MenuItem.new(text: 'File'))
	window.bar.add_child(ui.MenuItem.new(text: 'Edit'))
	window.bar.add_child(create_help_menu())

	mut theme_menu := window.make_theme_menu()

	window.bar.add_child(theme_menu)
	// window.add_child(window.bar)

	app.make_button_section()
	app.make_checkbox_section()
	app.make_selectbox_section()
	app.make_progress_section()

	mut img := ui.Image.new(
		file: 'v.png'
	)
	img.set_bounds(5, 5, 50, 50)
	mut title_box := ui.Titlebox.new(text: 'Image', children: [img])
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

	mut tb := ui.Tabbox.new(
		closable: false
	)

	button_tab := app.make_button_tab()
	frame_tab := app.make_frame_tab()
	slider_tab := app.make_slider_tab()
	selector_tab := app.make_selector_tab()
	svg_tab := app.make_svg_tab()

	tb.add_child('Overview', pane)
	tb.add_child('Buttons', button_tab)
	tb.add_child('Frames', frame_tab)
	tb.add_child('Slider', slider_tab)
	tb.add_child('Selector', selector_tab)
	tb.add_child('SVG (New!)', svg_tab)

	window.add_child(tb)

	// Add Extra Themes
	window.add_theme(themes.theme_dark_rgb())
	window.add_theme(themes.theme_seven())
	window.add_theme(themes.theme_seven_dark())

	// Run/Show The Window
	window.run()
}

fn (mut app App) make_selector_tab() &ui.Panel {
	mut list := []string{}

	for i in 0 .. 10 {
		list << 'Item ${i}'
	}

	mut sel := ui.Selectbox.new(
		text:  'Selectbox'
		items: list // ['Item A', 'Item B']
	)

	// Can either add items as string (above) or via new_item
	sel.add_child(sel.new_item(
		uicon: '\ue949'
		text:  'with uicon'
	))

	return ui.Panel.new(
		children: [
			ui.Titlebox.new(
				text:     'Selectbox'
				children: [
					sel,
				]
			),
		]
	)
}

fn draw_custom_themed(name string, mut e ui.DrawEvent) {
	if name !in e.ctx.icon_cache {
		ui.ocean_setup(mut e.ctx.win)
		// ui.seven_setup(mut e.ctx.win)
	}
	is_hover := ui.is_in(e.target, e.ctx.win.mouse_x, e.ctx.win.mouse_y)
	mut btn := e.target
	if mut btn is ui.Button {
		btn.override_bg_color = if is_hover { ui.blank_bg } else { gx.rgba(0, 0, 0, 1) }
	}
	if !is_hover {
		e.ctx.gg.draw_image_by_id(btn.x, btn.y, btn.width, btn.height, e.ctx.icon_cache[name])
	}
}

fn (mut app App) icon_btn(data []u8) &ui.Button {
	mut gg_ := app.win.gg
	gg_im := gg_.create_image_from_byte_array(data) or { panic(err) }
	cim := gg_.cache_image(gg_im)
	mut btn := ui.Button.new(icon: cim)

	btn.set_bounds(2, 4, 32, 32)
	return btn
}

// Make a 'Theme' menu item to select themes
@[deprecated: 'Replaced by ui thememanager']
fn create_theme_menu() {
}

fn (mut app App) make_hbox_section() {
	mut hbox := ui.Panel.new()

	mut btn_ := ui.Button.new(text: 'Button in HBox')
	btn_.pack()

	mut btn3 := ui.Button.new(text: 'Button 2')
	btn3.set_pos(4, 0)
	btn3.pack()

	hbox.add_child(btn_)
	hbox.add_child(btn3)

	mut hbox_title_box := ui.Titlebox.new(text: 'HBox layout', children: [hbox])

	hbox.set_bounds(0, 0, 150, 0)
	hbox_title_box.set_bounds(0, 0, 200, 150)
	app.pane.add_child(hbox_title_box)
}

fn (mut app App) make_edits_section() {
	mut code_box := ui.Textbox.new(lines: ['module main', '', 'fn main() {', '}'])
	code_box.set_bounds(0, 0, 175, 100)

	mut edits_title_box := ui.Titlebox.new(
		text:     'TextField / TextBox'
		children: [
			ui.TextField.new(
				text:   'This is a TextField'
				bounds: ui.Bounds{2, 5, 175, 30}
			),
			ui.ScrollView.new(
				view:    code_box
				bounds:  ui.Bounds{2, 44, 175, 100}
				padding: 0
			),
		]
	)
	edits_title_box.set_bounds(0, 0, 200, 150)
	app.pane.add_child(edits_title_box)
}

fn (mut app App) make_progress_section() {
	mut p := ui.Panel.new(
		layout:   ui.GridLayout.new(cols: 1)
		children: [
			ui.Progressbar.new(val: 30),
			ui.Progressbar.new(val: 50),
			ui.Progressbar.new(val: 70),
		]
	)
	p.set_bounds(0, 0, 120, 90)

	mut title_box := ui.Titlebox.new(text: 'Progressbar', children: [p])
	title_box.set_bounds(0, 0, 120, 130)
	app.pane.add_child(title_box)
}

fn (mut app App) make_tree_section() {
	mut tree := create_tree(app.win)
	mut tree_view := ui.scroll_view(
		bounds: ui.Bounds{0, 0, 170, 145}
		view:   tree
	)

	mut title_box := ui.Titlebox.new(text: 'Treeview', children: [tree_view])
	title_box.set_bounds(0, 0, 190, 180)

	app.pane.add_child(title_box)
}

fn (mut app App) make_checkbox_section() {
	cbox := ui.Checkbox.new(
		text:   'Check me!'
		bounds: ui.Bounds{0, 0, 50, 25}
	)

	cbox2 := ui.Switch.new(
		text:     'Switch'
		bounds:   ui.Bounds{0, 30, 50, 25}
		selected: true
	)

	mut title_box := ui.Titlebox.new(
		text:     'Checkbox/Switch'
		children: [cbox, cbox2]
	)
	title_box.set_bounds(0, 0, 130, 130)

	app.pane.add_child(title_box)
}

fn (mut app App) make_selectbox_section() {
	mut sel := ui.Selectbox.new(text: 'Selectbox')

	for i in 0 .. 3 {
		sel.items << (25 * (i + 1)).str() + '%'
	}

	mut slid := ui.Slider.new(
		min: 0
		max: 100
		dir: .hor
	)
	slid.set_bounds(0, 30, 90, 30)

	mut title_box := ui.Titlebox.new(text: 'Selector/Slider', children: [sel, slid])

	title_box.set_bounds(0, 0, 120, 130)
	app.pane.add_child(title_box)
}

fn (mut app App) make_button_section() {
	btn := ui.Button.new(
		text:   'A Button'
		bounds: ui.Bounds{0, 0, 1, 64}
	)

	btn2 := ui.Button.new(
		text:     'New Page'
		on_click: test_page
	)

	mut btn3 := app.icon_btn(img_file.to_bytes())
	btn3.icon_width = 32
	btn3.icon_height = 32

	mut p := ui.Panel.new(
		layout:   ui.GridLayout.new(
			rows: 2
			vgap: 4
			hgap: 4
		)
		children: [btn, btn2, btn3]
	)

	p.set_bounds(0, 0, 150, 80)

	mut title_box := ui.Titlebox.new(text: 'Button', children: [p])
	title_box.set_bounds(0, 0, 150, 130)

	app.pane.add_child(title_box)
}

fn (mut app App) make_tab_section() {
	mut tb := ui.Tabbox.new(
		stretch: true
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

	mut title_box := ui.Titlebox.new(text: 'Tabbox', children: [tb])
	title_box.set_bounds(0, 0, 180, 180)

	app.pane.add_child(title_box)
}

// Make a 'Help' menu item
fn create_help_menu() &ui.MenuItem {
	help_menu := ui.MenuItem.new(
		text:     'Help'
		children: [
			ui.MenuItem.new(
				text:  'Item 1'
				uicon: '\ue946'
			),
			ui.MenuItem.new(
				text: 'Item 2'
			),
			ui.MenuItem.new(
				text:  'About iUI'
				uicon: '\ue946'
			),
		]
	)
	return help_menu
}

// click_event_fn: menu_click

// Create the tree demo
fn create_tree(window &ui.Window) &ui.Tree2 {
	mut tree := ui.tree('My Tree')
	tree.set_bounds(0, 0, 170, 200)

	// tree.pack()
	tree.needs_pack = true

	tree.add_child(&ui.TreeNode{
		text:  'Veggies'
		open:  true
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
		text:  'Fruits'
		open:  true
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

fn test_page(mut e ui.MouseEvent) {
	mut page := ui.Page.new(title: 'Page 1')
	e.ctx.win.add_child(page)

	debug('btn click')
}

fn btn_click(mut e ui.MouseEvent) {
	debug('btn click')
}

// Code Textbox
fn make_code_box(file_name string) &ui.ScrollView {
	file := os.resource_abs_path(file_name)

	lines := os.read_lines(file) or { ['// Error: Unable to read ${file}'] }

	mut box := ui.Textbox.new(
		lines:        lines
		not_editable: true
	)

	box.set_bounds(0, 0, 450, 200)
	box.no_line_numbers = true

	p := ui.ScrollView.new(
		view:   box
		bounds: ui.Bounds{0, 0, 250, 200}
	)

	return p
}
