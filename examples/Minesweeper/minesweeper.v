module main

import iui as ui
import gx
import rand

struct ClickInfo {
	x    int
	y    int
	hbox &ui.HBox
	vbox &ui.VBox
}

fn main() {
	mut win := ui.window(ui.theme_default(), 'Minesweeper', 264, 330)

    win.bar = ui.menubar(win, win.theme)
    win.bar.add_child(ui.menuitem('Game'))

    mut help := ui.menuitem('Help')

    mut about := ui.menuitem('About iUI')
	mut about_calc := ui.menuitem('About Minesweeper')
    about_calc.set_click(about_click)
	help.add_child(about_calc)
	help.add_child(about)
    win.bar.add_child(help)

	mut vbox := ui.vbox(win)
	vbox.set_bounds(4, 32, 256, 343)

	for yy in 0 .. 9 {
		mut hbox := ui.hbox(win)
		hbox.set_bounds(0, 0, 256, 25)
		for xx in 0 .. 8 {
			mut btn := ui.button(win, ' ')
			btn.set_bounds(0, 0, 32, 32)
			hbox.add_child(btn)

			randi := rand.intn(5) or { -1 }

			if randi == 0 {
				btn.text = '   '
			}

			info := &ClickInfo{
				x: xx
				y: yy
				hbox: hbox
				vbox: vbox
			}

			btn.set_click_fn(btn_click, info)
		}
		vbox.add_child(hbox)
	}

	win.add_child(vbox)
	win.gg.run()
}

fn btn_click(win_ptr voidptr, btn_ptr voidptr, info_ptr voidptr) {
	mut win := &ui.Window(win_ptr)
	info := &ClickInfo(info_ptr)
	mut btn := info.hbox.children[info.x]

	mut hbox := info.hbox

	if btn.text == '   ' {
		if mut btn is ui.Button {
			btn.set_background(gx.red)
            game_over(win)
        }
		return
	} else {
		btn.text = '0'
	}

	if info.x < 0 {
		return
	}

	mut possibles := []ClickInfo{}

	mut vbox := info.vbox

	mut has_left := info.x - 1 >= 0
	mut has_right := info.x + 1 < hbox.children.len

	if has_left {
		possibles << &ClickInfo{info.x - 1, info.y, hbox, vbox}
	}
	if has_right {
		possibles << &ClickInfo{info.x + 1, info.y, hbox, vbox} // hbox.children[info.x + 1]
	}

	has_top := info.y - 1 >= 0

	if has_top {
		mut hbox_above := vbox.children[info.y - 1]
		if mut hbox_above is ui.HBox {
			possibles << &ClickInfo{info.x, info.y - 1, hbox_above, vbox}

			if has_left {
				possibles << &ClickInfo{info.x - 1, info.y - 1, hbox_above, vbox}
			}
			if has_right {
				possibles << &ClickInfo{info.x + 1, info.y - 1, hbox_above, vbox}
			}
		}
	}

	has_below := info.y < vbox.children.len - 1

	if has_below {
		mut hbox_below := vbox.children[info.y + 1]
		if mut hbox_below is ui.HBox {
			possibles << &ClickInfo{info.x, info.y + 1, hbox_below, vbox}

			if has_left {
				possibles << &ClickInfo{info.x - 1, info.y + 1, hbox_below, vbox}
			}
			if has_right {
				possibles << &ClickInfo{info.x + 1, info.y + 1, hbox_below, vbox}
			}
		}
	}

	mut around := 0
	for infoo in possibles {
		mut pbtn := infoo.hbox.children[infoo.x]
		if pbtn.text == '   ' {
			around += 1
		}
	}

	if around == 0 {
		for infoo in possibles {
			mut pbtn := infoo.hbox.children[infoo.x]
			if pbtn.text == ' ' {
				btn_click(win, pbtn, infoo)
			}
		}
		btn.text = '  '
	} else {
		btn.text = around.str()
	}

	if mut btn is ui.Button {
		btn.set_background(gx.yellow)
	}
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'About Mines')
	modal.in_height = 210
	modal.in_width = 250
	modal.top_off = 20

	mut title := ui.label(win, 'Mines')
	title.set_pos(20, 4)
	title.set_config(28, true, true)
	title.bold = true
	title.pack()

	mut label := ui.label(win,
		'Minesweeper-clone made in\nthe V Programming Language.\n\nVersion: 0.1\nUI Version: ' +
		ui.version)

	label.set_pos(22, 14)
	label.pack()

	mut can := ui.button(win, 'OK')
	can.set_bounds(10, 170, 70, 25)
	can.set_click(fn (mut win ui.Window, btn ui.Button) {
		win.components = win.components.filter(mut it !is ui.Modal)
	})
	modal.needs_init = false
	modal.add_child(can)

	modal.add_child(title)
	modal.add_child(label)

	win.add_child(modal)
}

fn game_over(win_ptr voidptr) &ui.Modal {
    mut win := &ui.Window(win_ptr)
	mut modal := ui.modal(win, 'You Lost')
	modal.in_height = 210
	modal.in_width = 250
	modal.top_off = 20

	mut title := ui.label(win, 'GAME OVER')
	title.set_pos(20, 42)
	title.set_config(34, true, true)
	title.bold = true
	title.pack()

	mut can := ui.button(win, 'OK')
	can.set_bounds(10, 170, 230, 25)
	can.set_click(fn (mut win ui.Window, btn ui.Button) {
		win.components = win.components.filter(mut it !is ui.Modal)
	})
	modal.needs_init = false
    modal.add_child(can)

	modal.add_child(title)


	win.add_child(modal)
    return modal
}
