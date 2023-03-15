import gg
import iui as ui { debug }
import os

struct App {
mut:
	win  &ui.Window
	pane &ui.HBox
}

[console]
fn main() {
	// Create Window
	mut window := ui.make_window(
		title: 'UI Demo'
		width: 700
		height: 480
		theme: ui.get_system_theme()
		ui_mode: false
	)

	mut pane := ui.hbox(window)
	mut app := &App{
		win: window
		pane: pane
	}

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)
	window.bar.add_child(ui.menu_item(text: 'File'))
	window.bar.add_child(ui.menu_item(text: 'Edit'))
	window.bar.add_child(create_help_menu())
	window.bar.add_child(create_theme_menu())

	app.make_button_section()
	app.make_checkbox_section()
	app.make_selectbox_section()
	app.make_progress_section()

	mut v_img := window.gg.create_image(os.resource_abs_path('v.png'))
	mut img := ui.image(window, v_img)
	img.set_bounds(5, 5, 50, 50)
	mut title_box := ui.title_box('Image', [img])
	title_box.set_bounds(8, 8, 100, 150)
	pane.add_child(title_box)

	app.make_tree_section()
	app.make_tab_section()

	// app.make_hbox_section()
	app.make_edits_section()

	pane.set_pos(4, 10)

	pane.draw_event_fn = fn (mut win ui.Window, mut com ui.Component) {
		ws := win.gg.window_size()
		com.width = 700 // ws.width - 100
		if mut com is ui.HBox {
			com.min_height = ws.height - 50
		}
	}

	mut tb := ui.tabbox(window)
	tb.set_pos(2, 25)
	tb.draw_event_fn = fn (mut win ui.Window, mut com ui.Component) {
		ws := win.gg.window_size()
		com.width = ws.width - 4
		com.height = ws.height - 30
	}
	tb.add_child('Overview', pane)
	window.add_child(tb)

	window.gg.run()
}

fn (mut app App) icon_btn(data []u8) &ui.Button {
	mut gg_ := app.win.gg
	gg_im := gg_.create_image_from_byte_array(data)
	cim := gg_.cache_image(gg_im)
	mut btn := ui.button_with_icon(cim)

	btn.set_bounds(2, 4, 32, 32)
	return btn
}

// Make a 'Theme' menu item to select themes
fn create_theme_menu() &ui.MenuItem {
	mut theme_menu := ui.menuitem('Themes')

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
	hbox_title_box.set_bounds(8, 8, 200, 150)
	app.pane.add_child(hbox_title_box)
}

fn (mut app App) make_edits_section() {
	tbox := ui.text_field(
		text: 'This is a TextField'
		bounds: ui.Bounds{2, 8, 200, 30}
	)

	mut code_box := ui.text_box(['module main', '', 'fn main() {', '}'])
	code_box.set_bounds(2, 48, 200, 100)

	mut edits_title_box := ui.title_box('TextField / TextArea', [tbox, code_box])
	edits_title_box.set_bounds(18, 8, 200, 210)
	app.pane.add_child(edits_title_box)
}

fn (mut app App) make_progress_section() {
	mut pb := ui.progressbar(30)
	pb.set_bounds(0, 0, 110, 24)

	mut pb2 := ui.progressbar(50)
	pb2.set_bounds(0, 30, 110, 24)

	mut pb3 := ui.progressbar(70)
	pb3.set_bounds(0, 60, 110, 24)

	mut title_box := ui.title_box('Progressbar', [pb, pb2, pb3])
	title_box.set_bounds(8, 8, 120, 150)
	app.pane.add_child(title_box)
}

fn (mut app App) make_tree_section() {
	mut tree := create_tree(app.win)
	mut tree_view := ui.scroll_view(
		bounds: ui.Bounds{0, 0, 180, 170}
		view: tree
	)

	mut title_box := ui.title_box('Treeview', [tree_view])
	title_box.set_bounds(8, 8, 180, 210)
	app.pane.add_child(title_box)
}

fn (mut app App) make_checkbox_section() {
	cbox := ui.check_box(
		text: 'Check me!'
		bounds: ui.Bounds{0, 0, 50, 25}
	)

	cbox2 := ui.check_box(
		text: 'Check me!'
		bounds: ui.Bounds{0, 30, 50, 25}
		selected: true
	)

	mut title_box := ui.title_box('Checkbox', [cbox, cbox2])
	title_box.set_bounds(8, 8, 130, 150)
	app.pane.add_child(title_box)
}

fn (mut app App) make_selectbox_section() {
	mut sel := ui.selector(app.win, 'Selectbox')
	sel.set_bounds(0, 0, 100, 25)

	for i := 0; i < 3; i++ {
		sel.items << (25 * (i + 1)).str() + '%'
	}
	sel.set_change(sel_change)

	mut title_box := ui.title_box('Selector', [sel])
	title_box.set_bounds(8, 8, 120, 150)
	app.pane.add_child(title_box)
}

fn (mut app App) make_button_section() {
	mut btn := ui.button(
		text: 'A Button'
		bounds: ui.Bounds{0, 0, 120, 30}
		click_event_fn: btn_click
	)

	mut btn2 := ui.button(
		text: 'Open Page'
		bounds: ui.Bounds{0, 35, 120, 30}
		should_pack: false
		// click_event_fn: test_page
	)
	btn2.subscribe_event('mouse_up', test_page)

	img_file := $embed_file('v.png')
	mut btn3 := app.icon_btn(img_file.to_bytes())
	btn3.set_bounds(0, 70, 120, 32)
	btn3.icon_width = 30
	btn3.icon_height = 30

	mut title_box := ui.title_box('Button', [btn, btn2, btn3])
	title_box.set_bounds(8, 8, 150, 150)
	app.pane.add_child(title_box)
}

fn (mut app App) make_tab_section() {
	mut tb := ui.tabbox(app.win)
	tb.set_bounds(5, 5, 170, 140)
	tb.compact = true

	mut tbtn := ui.button(text: 'In Tab A')
	tbtn.set_pos(10, 10)
	tbtn.pack()
	tb.add_child('Tab A', tbtn)

	mut tbtn1 := ui.label(app.win, 'Now in Tab B')
	tbtn1.set_pos(10, 10)
	tbtn1.pack()
	tb.add_child('Tab B', tbtn1)

	mut title_box := ui.title_box('Tabbox', [tb])
	title_box.set_bounds(18, 8, 200, 210)
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
	mut tree := ui.tree2('My Tree')
	tree.set_bounds(0, 0, 180, 210)

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

fn sel_change(mut win ui.Window, com ui.Select, old_val string, new_val string) {
	debug('OLD: ' + old_val + ', NEW: ' + new_val)
	mut a := new_val.replace('%', '')

	for mut kid in win.components {
		if mut kid is ui.Progressbar {
			kid.text = a
		}
	}
}

fn test_page(mut e ui.MouseEvent) {
	mut page := ui.page(e.ctx.win, 'Page 1')
	e.ctx.win.add_child(page)

	debug('btn click')
}

fn btn_click(win voidptr, btn voidptr, data voidptr) {
	debug('btn click')
}
