import gg
import iui as ui { debug }
import time
import os

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.get_system_theme(), 'My Window', 520, 500)

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
	btn.set_click(btn_click)
	btn.set_bounds(30, 40, 100, 25)
	btn.set_click(on_click)

	window.add_child(btn)

	mut btn2 := ui.button(window, 'This is a Button')
	btn2.set_pos(30, 70)
	// window.id_map['btn2'] = &btn2
	// btn2.set_id(mut window, 'btn2')
	btn2.pack() // Auto set width & height

	// Testing code; ignore.
	/*
	btn.draw_event_fn = fn (mut win ui.Window, com &ui.Component) {
        ptr := win.id_map['btn2']
        mut btn := &ui.Button(ptr)
        mut this := *com

        this.text = btn.text
        btn.text = 'hellooooo'
    }*/

	window.add_child(btn2)

	mut tbox := ui.textbox(window, 'This is a Textbox.\nIt has an multiline mode that\ncan support\nmultiple lines\nIt also can scroll and stuff')

	for i := 0; i < 6; i++ {
		tbox.text += '\nExtra line #' + i.str()
	}

	tbox.set_bounds(30, 110, 270, 100)

	window.add_child(tbox)

	mut cbox := ui.checkbox(window, 'Check me!')
	cbox.set_bounds(170, 40, 90, 25)

	mut cbox2 := ui.checkbox(window, 'Check me!')
	cbox2.set_bounds(170, 70, 90, 25)
	cbox2.is_selected = true

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

	// go test(mut &pb2)

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

	window.add_child(tree)

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

	mut code_box := ui.textbox(window, 'module main\n\nfn main() {\n\tmut val := 0\n}')
	code_box.set_bounds(30, 270, 320, 120)
	code_box.set_codebox(true)
	window.add_child(code_box)

	mut v_img := window.gg.create_image(os.resource_abs_path('v.png'))
	mut img := ui.image(window, v_img)
	img.set_bounds(30, 400, 50, 50)
	window.add_child(img)

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
	// debug(text)
	mut theme := ui.theme_by_name(text)
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

fn btn_click(mut win ui.Window, com ui.Button) {
	debug('btn click')
}
