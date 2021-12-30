import gg
import iui as ui { debug }
import time

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.get_system_theme())
	window.init('My Window')

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)
	window.bar.add_child(ui.menuitem('File'))
	window.bar.add_child(ui.menuitem('Edit'))

	mut help := ui.menuitem('Help')
	mut theme_menu := ui.menuitem('Themes')
	mut about := ui.menuitem('About iUI')

	for i := 0; i < 3; i++ {
		mut item := ui.menuitem('Item ' + i.str())
		help.add_child(item)
	}

	mut themes := [ui.theme_default(), ui.theme_dark(), ui.theme_dark_hc(),
		ui.theme_black_red(), ui.theme_minty()]
	for theme2 in themes {
		mut item := ui.menuitem(theme2.name)
		item.set_click(theme_click)
		theme_menu.add_child(item)
	}

	help.add_child(about)
	window.bar.add_child(help)
	window.bar.add_child(theme_menu)

	mut btn := ui.button(window, 'A Button')
	ui.set_bounds(mut btn, 30, 40, 100, 25)

	btn.set_click(on_click)

	window.add_child(btn)

	mut btn2 := ui.button(window, 'This is a Button')
	ui.set_pos(mut btn2, 30, 70)
	btn2.pack() // Auto set width & height

	window.add_child(btn2)

	mut tbox := ui.textbox(window, 'This is a Textbox.\nIt has an multiline mode that\ncan support\nmultiple lines\nIt also can scroll and stuff')
    
    for i := 0; i < 6; i++ {
		tbox.text += "\nExtra line #" + i.str()
	}
    
	ui.set_bounds(mut tbox, 30, 110, 320, 100)

	window.add_child(tbox)

	mut cbox := ui.checkbox(window, 'Check me!')
	ui.set_bounds(mut cbox, 150, 40, 90, 25)

	mut cbox2 := ui.checkbox(window, 'Check me!')
	ui.set_bounds(mut cbox2, 150, 70, 90, 25)
	cbox2.is_selected = true

	window.add_child(cbox)
	window.add_child(cbox2)

	mut sel := ui.selector(window, 'Selectbox')
	ui.set_bounds(mut sel, 30, 230, 100, 25)

	for i := 0; i < 4; i++ {
		sel.items << (25 * (i + 1)).str() + '%'
	}
	sel.set_change(sel_change)
	window.add_child(sel)

	mut pb := ui.progressbar(window, 50)
	ui.set_bounds(mut pb, 140, 230, 100, 20)
	window.add_child(pb)

	mut pb2 := ui.progressbar(window, 50)
	ui.set_bounds(mut pb2, 250, 230, 100, 20)
	window.add_child(pb2)

	//go test(mut &pb2)

	mut tree := ui.tree(window, 'Beverages')
	tree.x = 30
	tree.y = 280
	tree.width = 150
	tree.height = 200

	mut subtree := ui.tree(window, 'Water')
	ui.set_bounds(mut subtree, 4, 4, 100, 25)
	tree.childs << subtree

	mut subtree2 := ui.tree(window, 'Coke')
	ui.set_bounds(mut subtree2, 4, 4, 100, 25)
	tree.childs << subtree2

	mut subtree3 := ui.tree(window, 'Tea')
	ui.set_bounds(mut subtree3, 4, 4, 100, 100)
	tree.childs << subtree3

	mut subtree4 := ui.tree(window, 'Black Tea')
	ui.set_bounds(mut subtree4, 4, 4, 100, 25)
	subtree3.childs << subtree4

	mut subtree5 := ui.tree(window, 'Green Tea')
	ui.set_bounds(mut subtree5, 4, 4, 100, 25)
	subtree3.childs << subtree5

	window.add_child(tree)

	mut tb := ui.tabbox(window)
	ui.set_bounds(mut tb, 200, 280, 250, 200)

	mut tbtn := ui.button(window, 'Tab 1 content')
	ui.set_pos(mut tbtn, 30, 10)
	tbtn.pack()
	tb.add_child('Tab 1', tbtn)

	mut tbtn1 := ui.button(window, 'This in a button inside Tab #2')
	ui.set_pos(mut tbtn1, 30, 30)
	tbtn1.pack()
	tb.add_child('Tab 2', tbtn1)

	window.add_child(tb)

	window.gg.run()
}

fn test(mut pb ui.Progressbar) {
	for true {
		mut val := pb.text.f32()
		if val < 100 {
			val++
		} else {
			val = 5
		}
		pb.text = val.str().replace('.', '')
		time.sleep(80 * time.millisecond)
	}
}

fn on_click(mut win ui.Window, com ui.Button) {
	debug('on_click')
}

fn theme_click(mut win ui.Window, com ui.MenuItem) {
	text := com.text
	debug(text)
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
