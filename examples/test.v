import gg
import iui as ui { debug }
import os

[console]
fn main() {
	// Create Window
	mut window := ui.window_with_config(ui.get_system_theme(), 'My Window', 520, 500,
		ui.WindowConfig{
		ui_mode: false
	})

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)
	window.bar.add_child(ui.menuitem('File'))
	window.bar.add_child(ui.menuitem('Edit'))

	window.bar.add_child(create_help_menu())
	window.bar.add_child(create_theme_menu())

	btn := ui.button(window, 'A Button', ui.ButtonConfig{
		bounds: ui.Bounds{18, 40, 100, 25}
		click_event_fn: btn_click
	})

	window.add_child(btn)

	btn2 := ui.button(window, 'Open Page', ui.ButtonConfig{
		bounds: ui.Bounds{18, 70, 0, 0}
		should_pack: true
		click_event_fn: test_page
	})

	window.add_child(btn2)

	mut tbox := ui.textfield(window, 'This is a TextField')

	tbox.set_bounds(18, 110, 270, 25)
	window.add_child(tbox)

	cbox := ui.checkbox(window, 'Check me!', ui.CheckboxConfig{
		bounds: ui.Bounds{170, 40, 90, 25}
	})

	cbox2 := ui.checkbox(window, 'Check me!', ui.CheckboxConfig{
		bounds: ui.Bounds{170, 70, 90, 25}
		selected: true
	})

	window.add_child(cbox)
	window.add_child(cbox2)

	mut sel := ui.selector(window, 'Selectbox')
	sel.set_bounds(18, 145, 100, 25)

	for i := 0; i < 4; i++ {
		sel.items << (25 * (i + 1)).str() + '%'
	}
	sel.set_change(sel_change)
	window.add_child(sel)

	mut pb := ui.progressbar(30)
	pb.set_bounds(122, 145, 160, 24)
	window.add_child(pb)

	mut tree := create_tree(window)
	mut tree_view := ui.scroll_view(
		bounds: ui.Bounds{330, 220, 180, 210}
		view: tree
	)

	window.add_child(tree_view)

	mut tb := ui.tabbox(window)
	tb.set_bounds(310, 38, 200, 172)

	mut tbtn := ui.button(window, 'In Tab A')
	tbtn.set_pos(10, 10)
	tbtn.pack()
	tb.add_child('Tab A', tbtn)

	mut tbtn1 := ui.label(window, 'Now in Tab B')
	tbtn1.set_pos(10, 10)
	tbtn1.pack()
	tb.add_child('Tab B', tbtn1)

	window.add_child(tb)

	mut code_box := ui.textarea(window, ['module main', '', 'fn main() {', '\tmut val := 0', '}'])
	code_box.set_bounds(18, 230, 300, 120)

	window.add_child(code_box)

	mut v_img := window.gg.create_image(os.resource_abs_path('v.png'))
	mut img := ui.image(window, v_img)
	img.set_bounds(30, 400, 50, 50)
	window.add_child(img)

	mut hbox := ui.hbox(window)

	mut btn_ := ui.button(window, 'Button in HBox')
	btn_.set_bounds(0, 0, 120, 27)

	mut btn3 := ui.button(window, 'Button 2 in HBox')
	btn3.set_bounds(4, 0, 120, 27)

	hbox.add_child(btn_)
	hbox.add_child(btn3)

	hbox.set_bounds(18, 182, 250, 100)
	window.add_child(hbox)

	window.gg.run()
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
		if kid is ui.Progressbar {
			kid.text = a
		}
	}
}

fn test_page(win_ptr voidptr, btn voidptr, data voidptr) {
	mut win := &ui.Window(win_ptr)

	mut page := ui.page(win, 'Page 1')
	win.add_child(page)

	debug('btn click')
}

fn btn_click(win voidptr, btn voidptr, data voidptr) {
	debug('btn click')
}
