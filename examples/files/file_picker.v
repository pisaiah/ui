module main

import gg
import iui as ui
import os

// File Picker
struct FilePicker {
pub mut:
	dir_input &ui.TextEdit
	file_list &ui.VBox
	file_name &ui.HBox
}

fn create_file_picker(mut window ui.Window, in_modal bool, dir string) &FilePicker {
	mut dir_input := ui.textedit(window, dir)
	dir_input.code_syntax_on = false
	dir_input.padding_y = 4

	mut file_input := ui.textedit(window, '')
	file_input.code_syntax_on = false
	file_input.padding_y = 4

	padding := if in_modal { 10 } else { 30 }

	dir_input.set_bounds(4, padding, 491, 25)
	dir_input.set_id(mut window, 'dir-input')
	dir_input.before_txtc_event_fn = before_txt_change

	mut res_box := ui.vbox(window)
	res_box.set_id(mut window, 'edit')
	res_box.set_bounds(4, 28 + padding, 0, 0)
	res_box.draw_event_fn = vbtn_draw
	res_box.overflow = false

	fi_y := (33 * 10) + 30
	file_input.set_bounds(24, 0, 391, 25)
	file_input.set_id(mut window, 'file-input')

	mut hbox := ui.hbox(window)

	mut lbl := ui.label(window, 'File name:')
	lbl.set_bounds(10, 4, 0, 0)
	lbl.pack()
	hbox.add_child(lbl)

	hbox.set_bounds(0, padding + fi_y, 491, 25)
	hbox.add_child(file_input)

	return &FilePicker{dir_input, res_box, hbox}
}

fn before_txt_change(mut win ui.Window, tb ui.TextEdit) bool {
	mut is_enter := tb.last_letter == 'enter'
	if is_enter {
		mut txt := tb.lines[0]
		mut vbox := win.get_from_id('edit')
		if os.is_dir(txt) {
			load_directory(txt, vbox)
		}
		return true
	}
	return false
}

fn load_directory(dir string, com voidptr) {
	mut vbox := &ui.VBox(com)
	mut input := &ui.TextEdit(vbox.win.get_from_id('dir-input'))
	real_dir := os.real_path(dir)
	input.lines[0] = real_dir
	input.carrot_left = real_dir.len
	mut files := os.ls(dir) or { [] }

	vbox.children = []

	files.insert(0, '..')

	for file in files {
		mut hbox := create_file_box(vbox.win, dir, file)
		vbox.add_child(hbox)
	}
}

fn create_file_box(win &ui.Window, dir string, file string) &ui.HBox {
	mut hbox := ui.hbox(win)
	full_path := os.join_path(dir, file)

	mut img := &gg.Image(0)
	if os.is_dir(full_path) {
		img = &gg.Image(win.id_map['img_folder'])
	} else {
		img = &gg.Image(win.id_map['img_blank'])
	}

	mut img1 := ui.image(win, img)
	img1.pack()

	mut lbl := ui.label(win, file)
	lbl.set_bounds(50, 0, 300, 32)
	lbl.draw_event_fn = lbl_draw_ev

	file_size := os.file_size(full_path)
	mut size := ui.label(win, format_size(file_size))
	size.draw_event_fn = lbl_draw_ev
	size.set_bounds(0, 0, 130, 32)

	hbox.add_child(img1)
	hbox.add_child(lbl)
	hbox.add_child(size)

	hbox.draw_event_fn = hbox_draw_ev
	hbox.text = os.real_path(full_path)

	hbox.set_bounds(1, 1, 490, 32)
	hbox.set_min_height(32)
	return hbox
}

fn format_size(size f64) string {
	if size == 0 {
		return ''
	}

	if size < 1024 {
		return size.str().substr_ni(0, 3) + ' bytes'
	}

	kb := size / 1024
	mb := kb / 1024

	if kb < 1024 {
		return round(kb.str()) + ' KB'
	}
	return round(mb.str()) + ' MB'
}

fn round(str string) string {
	spl := str.split('.')
	if spl.len == 1 {
		return spl[0]
	}
	if spl[1].len == 0 {
		return spl[0]
	}

	return spl[0] + '.' + spl[1].substr_ni(0, 2)
}

fn lbl_draw_ev(mut win ui.Window, com &ui.Component) {
	mut this := *com
	if mut this is ui.Label {
		this.app.gg.draw_rect_empty(this.rx - 10, this.ry, this.width - 4, this.height - 2,
			win.theme.button_border_normal)
	}
}

fn hbox_draw_ev(mut win ui.Window, com &ui.Component) {
	if com.is_mouse_rele {
		mut vbox := win.get_from_id('edit')
		if os.is_dir(com.text) {
			load_directory(com.text, vbox)
		} else {
			mut input := &ui.TextEdit(win.get_from_id('file-input'))
			file_name := os.base(com.text)
			input.lines[0] = file_name
			input.carrot_left = file_name.len
		}
	}
}

fn vbtn_draw(mut win ui.Window, com &ui.Component) {
	mut this := *com

	this.height = (33 * 10) - 1

	if mut this is ui.VBox {
		draw_bg(this)
		draw_scrollbar(mut this, this.height / 33, this.children.len)
	}
}

fn draw_bg(this &ui.VBox) {
	x := if this.rx != 0 { this.rx } else { this.x }
	y := if this.ry != 0 { this.ry } else { this.y }

	this.win.draw_filled_rect(x, y, this.width, this.height, 0, this.win.theme.textbox_background,
		this.win.theme.textbox_border)
}

fn draw_scrollbar(mut com ui.VBox, cl int, spl_len int) {
	// Calculate postion for scroll
	if com.scroll_i > spl_len - cl {
		com.scroll_i = spl_len - cl
	}

	sth := int((f32((com.scroll_i)) / f32(spl_len)) * com.height)
	enh := int((f32(cl) / f32(spl_len)) * com.height)
	requires_scrollbar := ((com.height - enh) > 0)

	// Draw Scroll
	if requires_scrollbar {
		x := if com.rx != 0 { com.rx } else { com.x }
		y := if com.ry != 0 { com.ry } else { com.y }

		wid := 16
		wido := wid + 1

		com.win.draw_bordered_rect(x + com.width - wido, y + 1, wid, com.height - 2, 2,
			com.win.theme.scroll_track_color, com.win.theme.button_bg_hover)
		com.win.draw_bordered_rect(x + com.width - wido, y + sth + 1, wid, enh - 2, 2,
			com.win.theme.scroll_bar_color, com.win.theme.scroll_track_color)
	}
}
