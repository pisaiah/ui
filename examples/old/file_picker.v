import gg
import iui as ui { debug }
import time
import os

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.get_system_theme(), 'My Window', 800, 520)

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

	mut themes := [ui.theme_default(), ui.theme_dark(), ui.theme_minty()]
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
	window.add_child(btn2)

	mut sel := ui.selector(window, 'Selectbox')
	sel.set_bounds(30, 230, 100, 25)

	for i := 0; i < 4; i++ {
		sel.items << (25 * (i + 1)).str() + '%'
	}
	sel.set_change(sel_change)
	window.add_child(sel)

	mut modal := ui.modal(window, 'Select Folder')
	modal.set_id(mut window, 'file_modal')
	modal.needs_init = false

	mut tree := ui.tree(window, 'C:/')
	tree.childs = make_tree(mut window, 'C:/', tree, 1)
	tree.set_bounds(0, 0, 200, 290)
	tree.set_id(mut window, 'fold.tree')

	mut path_box := ui.runebox(mut window, os.home_dir())
	path_box.set_id(mut window, 'pbox')
	window.extra_map['ppath'] = 'C://'

	mut up_arrow := ui.button(window, 'Up')
	up_arrow.set_id(mut window, 'up_btn')
	up_arrow.pack()
	up_arrow.click_event_fn = fn (mut win ui.Window, com ui.Button) {
		mut pbox := &ui.TextField(win.get_from_id('pbox'))
		pbox.text = os.dir(pbox.text)
	}

	modal.in_width += 120
	modal.in_height += 135

	modal.after_draw_event_fn = fn (mut win ui.Window, com &ui.Component) {
		mut tree := &ui.Tree(win.get_from_id('fold.tree'))
		mut mydata := &MyData(win.get_from_id('mydata'))
		mut pbox := &ui.TextField(win.get_from_id('pbox'))
		mut up_btn := &ui.TextField(win.get_from_id('up_btn'))
		mut this := *com

		if mut this is ui.Modal {
			size := gg.window_size()

			// this.in_width = size.width - 20
			// this.in_height = gg.window_size().height - 32
			this.top_off = 5
			tree.height = this.in_height - 10

			if tree.is_hover && tree.width < 200 {
				tree.width += 18
			}

			if !tree.is_hover && tree.width > 50 {
				tree.width -= 18
			}

			up_btn.x = tree.width + 8
			up_btn.y = 5
			up_btn.height = 25

			pbox.x = tree.width + 12 + up_btn.width
			pbox.y = 5
			pbox.width = this.in_width - tree.width - 25 - up_btn.width
			pbox.height = 25

			path := pbox.text
			list := os.ls(pbox.text) or { [] }
			mut yp := 70
			mut xp := 0

			image_size := ui.text_height(win, 'A0{')

			win.gg.draw_rect_filled(up_btn.rx + xp, yp, pbox.width + up_btn.width,
				this.in_height - yp + image_size, win.theme.textbox_background)
			win.gg.draw_rect_empty(up_btn.rx + xp, yp, pbox.width + up_btn.width,
				this.in_height - yp + image_size, win.theme.button_border_normal)

			mut max_len := 0
			for file in list {
				full_path := pbox.text + '/' + file
				short_name := file.substr_ni(0, 22)

				text_width := ui.text_width(win, short_name) + 4
				if max_len < text_width {
					max_len = text_width
				}

				if os.is_writable(full_path) && os.is_readable(full_path) {
					mut img := &gg.Image(0)
					if os.is_dir(full_path) {
						img = &gg.Image(win.id_map['img_folder'])
					} else {
						img = &gg.Image(win.id_map['img_blank'])
					}

					x_val := up_btn.rx + xp

					half_wid := (max_len + image_size) / 2
					half_hei := (image_size + 1) / 2
					if ui.abs(win.mouse_x - (x_val + half_wid)) < half_wid {
						if ui.abs(win.mouse_y - (yp + half_hei)) < half_hei {
							win.gg.draw_rect_filled(x_val, yp, half_wid * 2, image_size + 1,
								win.theme.button_bg_hover)
							win.gg.draw_rect_empty(x_val, yp, half_wid * 2, image_size + 1,
								win.theme.button_border_hover)
							win.gg.draw_text(x_val + (half_hei * 2), yp, file)

							if this.is_mouse_rele {
								this.is_mouse_rele = false
								pbox.text = full_path
							}
						}
					}

					win.gg.draw_image(x_val, yp, image_size, image_size, img)
					win.gg.draw_text(x_val + (half_hei * 2), yp, short_name)

					yp += image_size + 2
					if yp > (this.in_height - 30) {
						yp = 70
						max_len = 0
						xp += half_wid * 2
					}
				}
			}
			this.is_mouse_rele = false
		}
	}

	mut v_img := window.gg.create_image(os.resource_abs_path('folder.png'))
	window.id_map['img_folder'] = &v_img

	mut v_img2 := window.gg.create_image(os.resource_abs_path('blankfile.png'))
	window.id_map['img_blank'] = &v_img2

	// mut img := ui.image(window, v_img)
	// img.set_bounds(200, 250, 50, 50)
	// modal.add_child(img)
	modal.add_child(tree)
	modal.add_child(path_box)
	modal.add_child(up_arrow)

	window.add_child(modal)

	window.gg.run()
}

struct MyData {
pub mut:
	icons []&MyIcon
}

struct MyIcon {
	ui.Component_A
pub mut:
	win      &ui.Window
	image_id int
	text     string
}

fn (mut this MyIcon) draw() {
	this.win.gg.draw_text(this.x, this.y, this.text)
}

// Make an Tree list from files from dir
fn make_tree(mut window ui.Window, fold string, tree ui.Tree, depth int) []ui.Component {
	mut files := os.ls(fold) or { [] }

	mut arr := []ui.Component{}
	for fi in files {
		if fi.contains('.') {
			continue
		}
		mut sub := ui.tree(window, fold + '/' + fi)
		sub.min_y = 25
		sub.set_bounds(4, 4, 100, 25)
		sub.set_click(tree_click)
		sub.set_id(mut window, sub.text)

		cl := os.ls(fold + '/' + fi) or { [] }
		if cl.len > 0 {
			sub.childs << ui.label(window, '')
		}

		if depth > 0 {
			// sub.childs = make_tree(mut window, fold + '/' + fi, sub, 0)
		}

		// tree.childs << sub
		arr << sub
	}
	return arr // tree
}

// Refresh Tree list
fn refresh_tree(mut window ui.Window, fold string, mut tree ui.Tree) ui.Tree {
	// TODO: Remember open-trees
	// tree.childs.clear()
	return tree // return make_tree(mut window, fold, mut tree)
}

// If file is .v open in new tab
fn tree_click(mut win ui.Window, tree ui.Tree) {
	if tree.childs.len <= 1 {
		// tree.set_id(mut win, tree.text)
		mut tree_ := &ui.Tree(win.get_from_id(tree.text))
		tree_.childs = make_tree(mut win, tree.text, tree, 1)
	}
	txt := tree.text
	println(txt)

	// mut modal := &ui.Modal(win.get_from_id('file_modal'))
	mut pbox := &ui.TextField(win.get_from_id('pbox'))
	pbox.text = os.real_path(tree.text)

	win.extra_map['ppath'] = os.real_path(tree.text)
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
