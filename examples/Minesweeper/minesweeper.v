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

[heap]
struct App {
mut:
	win   &ui.Window
	icons []int
}

fn (mut app App) setup_icons() {
	img_0_file := $embed_file('assets/empty.png')
	app.icons << icon(app.win, img_0_file.to_bytes())

	img_1_file := $embed_file('assets/1.png')
	app.icons << icon(app.win, img_1_file.to_bytes())

	img_2_file := $embed_file('assets/2.png')
	app.icons << icon(app.win, img_2_file.to_bytes())

	img_3_file := $embed_file('assets/3.png')
	app.icons << icon(app.win, img_3_file.to_bytes())

	img_4_file := $embed_file('assets/4.png')
	app.icons << icon(app.win, img_4_file.to_bytes())

	img_5_file := $embed_file('assets/5.png')
	app.icons << icon(app.win, img_5_file.to_bytes())

	img_6_file := $embed_file('assets/6.png')
	app.icons << icon(app.win, img_6_file.to_bytes())

	img_7_file := $embed_file('assets/7.png')
	app.icons << icon(app.win, img_7_file.to_bytes())

	img_8_file := $embed_file('assets/8.png')
	app.icons << icon(app.win, img_8_file.to_bytes())

	img_mine_file := $embed_file('assets/mine.png')
	app.icons << icon(app.win, img_mine_file.to_bytes())
}

[console]
fn main() {
	btn_size := 28
	width := btn_size * 9

	win_width := width + 8

	mut win := ui.make_window(
		theme: ui.theme_default()
		title: 'Minesweeper'
		width: win_width
		height: 330
	)

	win.bar = ui.menubar(win, win.theme)
	win.bar.add_child(ui.menuitem('Game'))

	mut app := &App{
		win: win
	}

	app.setup_icons()

	mut help := ui.menuitem('Help')

	mut about := ui.menuitem('About iUI')
	mut about_calc := ui.menuitem('About Minesweeper')
	about_calc.set_click(about_click)
	help.add_child(about_calc)
	help.add_child(about)
	win.bar.add_child(help)

	mut vbox := ui.vbox(win)
	vbox.set_bounds(4, 32, width, 343)

	for yy in 0 .. 9 {
		mut hbox := ui.hbox(win)
		hbox.set_bounds(0, 0, width, 25)
		for xx in 0 .. 9 {
			img_blank_file := $embed_file('assets/blank.png')
			mut btn := icon_btn(win, img_blank_file.to_bytes())

			// mut btn := ui.button(win, ' ')
			btn.set_bounds(0, 0, btn_size, btn_size)
			hbox.add_child(btn)

			randi := rand.intn(16) or { -1 }

			if randi == 0 {
				btn.text = '   '
			}

			info := &ClickInfo{
				x: xx
				y: yy
				hbox: hbox
				vbox: vbox
			}

			btn.set_click_fn(app.btn_click, info)
		}
		vbox.add_child(hbox)
	}

	win.add_child(vbox)
	win.gg.run()
}

fn icon(win &ui.Window, data []u8) int {
	mut gg := win.gg
	gg_im := gg.create_image_from_byte_array(data)
	cim := gg.cache_image(gg_im)

	return cim
}

fn icon_btn(win &ui.Window, data []u8) &ui.Button {
	mut gg := win.gg
	gg_im := gg.create_image_from_byte_array(data)
	cim := gg.cache_image(gg_im)
	mut btn := ui.button_with_icon(cim)

	return btn
}

fn (mut app App) btn_click(win_ptr voidptr, btn_ptr voidptr, info_ptr voidptr) {
	mut win := &ui.Window(win_ptr)
	info := &ClickInfo(info_ptr)
	mut btn := info.hbox.children[info.x]

	mut hbox := info.hbox

	if btn.text == '   ' {
		if mut btn is ui.Button {
			ico := app.icons[9]
			btn.icon = ico
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
			dump(pbtn.text.len)
			if pbtn.text == ' ' || pbtn.text.len == 0 {
				app.btn_click(win, pbtn, infoo)
			}
		}
		btn.text = '  '
	} else {
		btn.text = around.str()
	}

	if mut btn is ui.Button {
		btn.icon = app.icons[around]
	}
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'About Mines')
	modal.in_height = 210
	modal.in_width = 250
	modal.top_off = 20

	mut title := ui.label(win, 'Mines')
	title.set_config(28, true, true)
	title.bold = true
	title.pack()

	mut label := ui.label(win, 'Minesweeper-clone made in\nthe V Programming Language.\n\nVersion: 0.1, UI: $ui.version,\n\nBy Isaiah.')

	label.set_pos(4, -2)
	label.pack()

	mut can := ui.button(win, 'OK')
	can.set_bounds(16, 175, 216, 25)
	can.set_click(fn (mut win ui.Window, btn ui.Button) {
		win.components = win.components.filter(mut it !is ui.Modal)
	})
	modal.needs_init = false
	modal.add_child(can)

	mut vbox := ui.vbox(win)
	vbox.set_pos(20, 8)

	vbox.add_child(title)
	vbox.add_child(label)
	modal.add_child(vbox)

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
