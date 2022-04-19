module extra

import gg
import iui as ui
import os

// File Picker
struct FilePicker {
pub mut:
	dir_input      &ui.TextField
	file_list      &ui.VBox
	file_name      &ui.HBox
	ok_btn         &ui.Button
	path_change_fn fn (voidptr, voidptr)
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

[parms]
pub struct FilePickerConfig {
	in_modal       bool
	path           string = os.home_dir()
	path_change_fn fn (voidptr, voidptr)
	show_icons     bool
}

pub fn create_file_picker(mut window ui.Window, conf FilePickerConfig) &FilePicker {
	dir := os.dir(conf.path)
	file_name := if os.is_dir(conf.path) { '' } else { os.base(conf.path) }

	mut dir_input := ui.textfield(window, dir)
	mut file_input := ui.textfield(window, file_name)

	padding := if conf.in_modal { 10 } else { 30 }

	dir_input.set_bounds(4, padding, 491, 25)
	dir_input.set_id(mut window, 'dir-input')
	dir_input.before_txtc_event_fn = before_txt_change

	mut res_box := ui.vbox(window)
	res_box.set_id(mut window, 'edit')
	res_box.set_bounds(4, 28 + padding, 0, 0)
	res_box.draw_event_fn = vbtn_draw
	res_box.overflow = false

	fi_y := (36 * 10) + 35
	file_input.set_bounds(24, 0, 300, 25)
	file_input.set_id(mut window, 'file-input')

	mut hbox := ui.hbox(window)
	hbox.set_bounds(0, 16, 0, 0)
	hbox.pack()

	mut lbl := ui.label(window, 'File name:')
	lbl.set_bounds(10, 4, 0, 0)
	lbl.pack()
	hbox.add_child(lbl)

	hbox.set_bounds(0, padding + fi_y, 491, 25)
	hbox.add_child(file_input)

	mut btn := ui.button(window, 'OK')
	btn.set_bounds(8, 0, 64, 25)
	hbox.add_child(btn)

	return &FilePicker{dir_input, res_box, hbox, &btn, conf.path_change_fn}
}

fn before_txt_change(mut win ui.Window, tb ui.TextField) bool {
	mut is_enter := tb.last_letter == 'enter'
	if is_enter {
		mut txt := tb.text
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
	mut input := &ui.TextField(vbox.win.get_from_id('dir-input'))
	real_dir := os.real_path(dir)
	input.text = real_dir
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
	lbl.set_bounds(50, 0, 300, 28)
	lbl.draw_event_fn = lbl_draw_ev

	file_size := os.file_size(full_path)
	mut size := ui.label(win, format_size(file_size))
	size.draw_event_fn = lbl_draw_ev
	size.set_bounds(0, 0, 130, 32)

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

	hbox.set_bounds(1, 0, 490, 40)
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
	if mut this is ui.Label {
		this.height = ui.text_height(win, 'A{}') + 5

		this.app.gg.draw_rect_filled(this.rx - 10, this.ry, this.width - 4, this.height - 2,
			win.theme.button_bg_normal)
	}
}

fn hbox_draw_ev(mut win ui.Window, com &ui.Component) {
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
	}
}

fn vbtn_draw(mut win ui.Window, com &ui.Component) {
	mut this := *com

	this.height = (34 * 10)

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

pub fn draw_scrollbar(mut com ui.VBox, cl int, spl_len int) {
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

struct FilePickerModalData {
	picker    &FilePicker
	user_data voidptr
}

pub fn open_file_picker(mut win ui.Window, conf FilePickerConfig, user_data voidptr) {
	mut modal := ui.modal(win, 'Choose Folder & File')
	modal.top_off = 16
	modal.in_width = 500
	modal.in_height = 460
	modal.set_id(mut win, 'file_picker_modal')

	mut picker := create_file_picker(mut win, conf)
	modal.add_child(picker.dir_input)
	modal.add_child(picker.file_list)
	modal.add_child(picker.file_name)

	picker.ok_btn.set_click_fn(fn (a voidptr, b voidptr, c voidptr) {
		mut win := &ui.Window(a)
		data := &FilePickerModalData(c)

		data.picker.path_change_fn(data.picker, data.user_data)

		win.components = win.components.filter(it.id != 'file_picker_modal')
	}, &FilePickerModalData{picker, user_data})
	modal.z_index = 600
	modal.needs_init = false

	load_directory(os.dir(conf.path), picker.file_list)
	win.add_child(modal)
}
