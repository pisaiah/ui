//
// Horrible Webcam Example
// (Requires ffmpeg on system path)
//
module main

import iui as ui
import os
import gg
import stbi
import time

const (
	webcam_name   = 'Lenovo EasyCamera' // TODO: This is platform dependent, (Mine = "Lenovo EasyCamera")
	webcam_width  = 256
	webcam_height = (webcam_width * 9) / 16
	webcam_fps    = 9
	size_text     = webcam_width.str() + 'x' + webcam_height.str()
)

struct OurData {
mut:
	img      stbi.Image
	image_id int = -1
	id_loop  int
	req_nam  int = 1
}

[console]
fn main() {
	// Create Window
	mut window := ui.window_with_config(ui.theme_dark(), 'V Webcam', webcam_width + 20,
		webcam_height + 64, &ui.WindowConfig{
		ui_mode: false
	})

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)
	window.bar.add_child(ui.menuitem(' '))

	temp := os.join_path(os.temp_dir(), 'webcamtest')

	list := os.ls(temp) or { [''] }
	for file in list {
		os.rm(os.join_path(temp, file)) or {}
	}

	mut storage := OurData{}

	mut btn := ui.label(window, 'Test')

	window.id_map['storage'] = &storage

	btn.draw_event_fn = fn (mut win ui.Window, com &ui.Component) {
		mut storage := &OurData(win.id_map['storage'])
		update_image_loop(mut win, mut storage)
		mut this := *com
		this.text = webcam_name + ', ' + size_text + ', Frame: ' + storage.req_nam.str() +
			', FPS: ' + webcam_fps.str()
	}
	btn.set_config(12, true, false) // set to 12px font

	btn.set_pos(10, 35 + webcam_height + 4)
	btn.pack()
	window.add_child(btn)

	go ffmpeg_loop(mut window)

	window.gg.run()

	mut pro := &os.Process(window.id_map['ffmpeg'])
	pro.signal_pgkill()
}

fn ffmpeg_loop(mut win ui.Window) {
	mut storage := &OurData(win.id_map['storage'])

	temp := os.join_path(os.join_path(os.temp_dir(), 'webcamtest'), 'ffmpeg-test-%03d.jpg')
	con := run_exec(mut win, ['ffmpeg', '-f', 'dshow', '-y', '-i', '"video=' + webcam_name + '"',
		'-r', webcam_fps.str(), '-s', webcam_width.str() + 'x' + webcam_height.str(), '-hide_banner',
		'-loglevel', 'error', temp])
}

fn update_image_loop(mut window ui.Window, mut storage OurData) {
	// make_icon(mut window, 320, 240, mut storage)
	make_icon(mut window, webcam_width, webcam_height, mut storage)
}

// Create an new ui.Image
fn make_icon(mut win ui.Window, width int, height int, mut storage OurData) int {
	mut ggim := storage.image_id
	if ggim == -1 {
		ggim = win.gg.new_streaming_image(width, height, 4, gg.StreamingImageConfig{
			pixel_format: .rgba8
		})
		storage.image_id = ggim

		mut img := ui.image(win, win.gg.get_cached_image_by_idx(ggim))
		img.set_bounds(10, 35, width, height)
		img.pack()
		win.add_child(img)
	}

	dir := os.join_path(os.temp_dir(), 'webcamtest')

	temp_neg := os.join_path(dir, 'ffmpeg-test-' + format_nam(storage.req_nam - 2) + '.jpg')
	temp := os.join_path(dir, 'ffmpeg-test-' + format_nam(storage.req_nam) + '.jpg')

	storage.img.free()
	if !os.exists(temp) {
		return ggim
	}

	mut img := stbi.load(temp) or { panic('err') }
	storage.img = img

	temp_1 := os.join_path(dir, 'ffmpeg-test-' + format_nam(storage.req_nam + 1) + '.jpg')
	if os.exists(temp_1) {
		storage.req_nam += 1
	}

	win.gg.update_pixel_data(ggim, storage.img.data)

	os.rm(temp_neg) or {}

	return ggim
}

fn format_nam(val int) string {
	if val < 10 {
		return '00' + val.str()
	} else if val < 100 {
		return '0' + val.str()
	}
	return val.str()
}

// Run command without updating a text box
fn run_exec(mut win ui.Window, args []string) []string {
	if os.user_os() == 'windows' {
		return run_exec_win(mut win, args)
	} else {
		return run_exec_unix(mut win, args)
	}
}

// Linux
fn run_exec_unix(mut win ui.Window, args []string) []string {
	mut cmd := os.Command{
		path: args.join(' ')
	}

	mut content := []string{}
	cmd.start() or { content << err.str() }
	for !cmd.eof {
		out := cmd.read_line()
		if out.len > 0 {
			for line in out.split_into_lines() {
				content << line.trim_space()
			}
		}
	}

	cmd.close() or { content << err.str() }
	return content
}

// Windows;
// os.Command not fully implemented on Windows, so cmd.exe is used
//
fn run_exec_win(mut win ui.Window, args []string) []string {
	mut pro := os.new_process('cmd')

	mut argsa := ['/min', '/c', args.join(' ')]
	pro.set_args(argsa)

	win.id_map['ffmpeg'] = pro

	pro.set_redirect_stdio()
	pro.run()

	mut content := []string{}
	for pro.is_alive() {
		mut out := pro.stdout_read()
		mut eout := pro.stderr_read()
		if out.len > 0 {
			println(out)
			for line in out.split_into_lines() {
				content << line.trim_space()
			}
		}
		if eout.len > 0 {
			println(eout)
			for line in eout.split_into_lines() {
				content << line.trim_space()
			}
		}
	}

	pro.close()
	return content
}
