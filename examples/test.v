import gg
import iui as ui { debug }
import os

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.get_system_theme(), 'My Window', 520, 500)

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)
	window.bar.add_child(ui.menuitem('File'))
	window.bar.add_child(ui.menuitem('Edit'))

	window.bar.add_child(create_help_menu())
	window.bar.add_child(create_theme_menu())

	btn := ui.button(window, 'A Button', ui.ButtonConfig{
		bounds: ui.Bounds{30, 40, 100, 25}
		click_event_fn: btn_click
	})

	window.add_child(btn)

	btn2 := ui.button(window, 'This is a Button', ui.ButtonConfig{
		bounds: ui.Bounds{30, 70, 0, 0}
		should_pack: true
	})

	window.add_child(btn2)

	mut tbox := ui.textbox(window, 'This is a Textbox.\nIt has an multiline mode that\ncan support\nmultiple lines\nIt also can scroll and stuff')

	for i := 0; i < 6; i++ {
		tbox.text += '\nExtra line #' + i.str()
	}

	tbox.set_bounds(30, 110, 270, 100)

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
	sel.set_bounds(30, 230, 100, 25)

	for i := 0; i < 4; i++ {
		sel.items << (25 * (i + 1)).str() + '%'
	}
	sel.set_change(sel_change)
	window.add_child(sel)

	mut pb := ui.progressbar(window, 30)
	pb.set_bounds(140, 230, 100, 20)
	window.add_child(pb)

	mut pb2 := ui.progressbar(window, 75)
	pb2.set_bounds(250, 230, 100, 20)
	window.add_child(pb2)

	window.add_child(create_tree(window))

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
	code_box.set_bounds(30, 270, 320, 120)

	window.add_child(code_box)

	mut v_img := window.gg.create_image(os.resource_abs_path('v.png'))
	mut img := ui.image(window, v_img)
	img.set_bounds(30, 400, 50, 50)
	window.add_child(img)

	mut hbox := ui.hbox(window)

	mut btn_ := ui.button(window, 'Button in HBox')
	btn_.set_bounds(0, 0, 120, 30)

	mut btn3 := ui.button(window, 'Button 2')
	btn3.set_bounds(0, 0, 80, 30)

	hbox.add_child(btn_)
	hbox.add_child(btn3)

	hbox.set_pos(100, 400)
	hbox.set_bounds(100, 400, 250, 100)
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
fn create_tree(window &ui.Window) ui.Tree {
	mut tree := ui.tree(window, 'Beverages')
	tree.set_bounds(355, 220, 150, 200)

	mut subtree := ui.tree(window, 'Water')
	subtree.set_bounds(4, 4, 100, 25)
	tree.childs << subtree

	mut subtree2 := ui.tree(window, 'Coke')
	subtree2.set_bounds(4, 4, 100, 25)
	tree.childs << subtree2

	mut subtree3 := ui.tree(window, 'Tea')
	subtree3.set_bounds(4, 4, 100, 25)
	tree.childs << subtree3

	mut subtree4 := ui.tree(window, 'Black Tea')
	subtree4.set_bounds(4, 4, 100, 25)
	subtree3.childs << subtree4

	mut subtree5 := ui.tree(window, 'Green Tea')
	subtree5.set_bounds(4, 4, 100, 25)
	subtree3.childs << subtree5
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

fn btn_click(win voidptr, btn voidptr, data voidptr) {
	debug('btn click')
}
