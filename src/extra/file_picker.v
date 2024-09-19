module extra

import gg
import iui as ui
import os

// File Picker
pub struct FilePicker {
pub mut:
	dir_input      &ui.TextField
	file_list      &ui.VBox
	file_name      &ui.HBox
	ok_btn         &ui.Button
	path_change_fn fn (voidptr, voidptr) = unsafe { nil }
}

pub fn (this &FilePicker) get_full_path() string {
	dir := this.dir_input.text
	mut te := this.file_name.children[1]
	if mut te is ui.TextField {
		return os.join_path(dir, te.text)
	}
	return dir
}

pub fn (this &FilePicker) get_dir() string {
	dir := this.dir_input.text
	return dir
}

pub fn (this &FilePicker) get_file_name() string {
	mut te := this.file_name.children[1]
	if mut te is ui.TextField {
		return te.text
	}
	return ''
}

@[parms]
pub struct FilePickerConfig {
pub:
	in_modal       bool
	path           string                = os.home_dir()
	path_change_fn fn (voidptr, voidptr) = unsafe { nil }
	show_icons     bool
}

pub fn create_file_picker(mut window ui.Window, conf FilePickerConfig) &FilePicker {
	dir := os.dir(conf.path)
	file_name := if os.is_dir(conf.path) { '' } else { os.base(conf.path) }

	mut dir_input := ui.TextField.new(text: dir)
	mut file_input := ui.TextField.new(text: file_name)

	padding := if conf.in_modal { 10 } else { 30 }

	dir_input.set_bounds(11, padding, 480, 25)
	dir_input.set_id(mut window, 'dir-input')
	dir_input.text_change_event_fn = before_txt_change

	mut res_box := ui.VBox.new()
	res_box.set_id(mut window, 'edit')
	res_box.set_bounds(4, 34 + padding, 0, 0)
	res_box.draw_event_fn = vbtn_draw
	res_box.overflow = false

	fi_y := (36 * 10) + 35
	file_input.set_bounds(24, 0, 300, 25)
	file_input.set_id(mut window, 'file-input')

	mut hbox := ui.HBox.new()
	hbox.set_bounds(0, 16, 0, 0)
	hbox.pack()

	mut lbl := ui.Label.new(text: 'File name:')
	lbl.set_bounds(10, 4, 0, 0)
	lbl.pack()
	hbox.add_child(lbl)

	hbox.set_bounds(0, padding + fi_y, 491, 25)
	hbox.add_child(file_input)

	mut btn := ui.Button.new(text: 'OK')
	btn.set_bounds(8, 0, 64, 25)
	hbox.add_child(btn)

	return &FilePicker{dir_input, res_box, hbox, btn, conf.path_change_fn}
}

fn before_txt_change(winA voidptr, tbA voidptr) {
	win := unsafe { &ui.Window(winA) }
	tb := unsafe { &ui.TextField(tbA) }
	mut is_enter := tb.last_letter == 'enter'
	if is_enter {
		mut txt := tb.text
		mut vbox := win.get[ui.VBox]('edit')
		if os.is_dir(txt) {
			load_directory(win, txt, vbox)
		}
	}
}

fn load_directory(win ui.Window, dir string, com voidptr) {
	mut vbox := unsafe { &ui.VBox(com) }
	mut input := win.get[&ui.TextField]('dir-input')
	real_dir := os.real_path(dir)
	input.text = real_dir
	input.carrot_left = real_dir.len
	mut files := os.ls(dir) or { [] }

	if 'file_picker_accept' in win.extra_map {
		accept := win.extra_map['file_picker_accept']
		if accept.len > 1 {
			files = files.filter(it.contains(accept))
		}
	}

	vbox.children = []

	files.insert(0, '..')

	for file in files {
		mut hbox := create_file_box(win, dir, file)
		vbox.add_child(hbox)
	}
}

fn create_file_box(win &ui.Window, dir string, file string) &ui.HBox {
	mut hbox := ui.HBox.new()
	full_path := os.join_path(dir, file)

	mut img := &gg.Image(unsafe { nil })
	if os.is_dir(full_path) {
		img_candidate := win.get[&gg.Image]('img_folder')
		if !isnil(img_candidate) {
			img = img_candidate
		}
	} else {
		img_candidate := win.get[&gg.Image]('img_blank')
		if !isnil(img_candidate) {
			img = img_candidate
		}
	}

	mut img1 := ui.Image.new(img: img)
	img1.pack()

	mut lbl := ui.Button.new(text: file)
	lbl.set_bounds(50, 0, 295, 32)
	lbl.draw_event_fn = lbl_draw_ev

	file_size := os.file_size(full_path)
	mut size := ui.Label.new(text: format_size(file_size))
	size.draw_event_fn = lbl_draw_ev
	size.set_bounds(5, 0, 130, 32)

	if 'img_folder' in win.id_map {
		hbox.add_child(img1)
	} else {
		lbl.x -= 32
		lbl.width += 32
	}
	hbox.add_child(lbl)
	hbox.add_child(size)

	hbox.draw_event_fn = hbox_draw_ev
	hbox.text = os.real_path(full_path)

	hbox.set_bounds(1, 2, 490, 42)
	hbox.z_index = 18

	// hbox.set_min_height(32)
	return hbox
}

pub fn format_size(size f64) string {
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

pub fn round(str string) string {
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

	if com.is_mouse_rele {
		mut vbox := win.get[ui.VBox]('edit')
		if os.is_dir(com.text) {
			load_directory(win, com.text, vbox)
		} else {
			mut input := win.get[&ui.TextField]('file-input')
			file_name := os.base(com.text)
			input.text = file_name
			input.carrot_left = file_name.len
		}
		this.is_mouse_rele = false
	}
}

fn hbox_draw_ev(mut win ui.Window, com &ui.Component) {
	/*
	if com.is_mouse_rele {
		mut vbox := win.get_from_id('edit')
		if os.is_dir(com.text) {
			load_directory(com.text, vbox)
		} else {
			mut input := &ui.TextField(win.get_from_id('file-input'))
			file_name := os.base(com.text)
			input.text = file_name
			input.carrot_left = file_name.len
		}
		//mut this := *com
		//this.is_mouse_rele = false
	}*/
}

fn vbtn_draw(mut win ui.Window, com &ui.Component) {
	mut this := *com

	this.height = (34 * 10)

	if mut this is ui.VBox {
		draw_bg(mut win, this)
		draw_scrollbar(mut win, mut this, this.height / 33, this.children.len)
	}
}

fn draw_bg(mut win ui.Window, this &ui.VBox) {
	x := if this.rx != 0 { this.rx } else { this.x }
	y := if this.ry != 0 { this.ry } else { this.y }

	win.draw_bordered_rect(x, y, this.width, this.height, 0, win.theme.textbox_background,
		win.theme.textbox_border)
}

pub fn draw_scrollbar(mut win ui.Window, mut com ui.VBox, cl int, spl_len int) {
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

		win.draw_bordered_rect(x + com.width - wido, y + 1, wid, com.height - 2, 2, win.theme.scroll_track_color,
			win.theme.button_bg_hover)
		win.draw_bordered_rect(x + com.width - wido, y + sth + 1, wid, enh - 2, 2, win.theme.scroll_bar_color,
			win.theme.scroll_track_color)
	}
}

pub struct FilePickerModalData {
	picker    &FilePicker
	user_data voidptr
}

pub fn open_file_picker(mut win ui.Window, conf FilePickerConfig, user_data voidptr) &ui.Page {
	mut modal := ui.Page.new(title: 'Choose Folder & File')
	modal.set_id(mut win, 'file_picker_modal')

	mut picker := create_file_picker(mut win, conf)
	modal.add_child(picker.dir_input)
	modal.add_child(picker.file_list)
	modal.add_child(picker.file_name)
	picker_data := &FilePickerModalData{picker, user_data}

	picker.ok_btn.subscribe_event('mouse_up', (fn [mut win, picker_data] (a voidptr) {
		picker_data.picker.path_change_fn(picker_data.picker, picker_data.user_data)

		win.components = win.components.filter(it.id != 'file_picker_modal')
	}))
	modal.z_index = 600
	modal.needs_init = false

	load_directory(win, os.dir(conf.path), picker.file_list)
	win.add_child(modal)
	return modal
}
