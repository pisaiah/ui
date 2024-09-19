module main

import iui as ui
import gx
import os
import math
// import dialog

// bug? should be "iui.extra.dialogs"?
import iui.src.extra.file_dialog

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title: 'Video Player'
		width: 520
		height: 400
		theme: ui.theme_dark()
		ui_mode: false
	)

	mut mb := ui.Menubar.new()

	// window.set_theme(ui.theme_seven_dark())
	mut p := ui.Panel.new(
		layout: ui.BorderLayout.new(hgap: 0, vgap: 0)
	)
	p.set_bounds(0, 0, 520, 400)

	if os.args.len < 2 {
		eprintln('give path for the video.')
		exit(1)
	}

	video_path := os.args[1..].join(' ')

	mut plr := &Player{
		x: 0
		y: 0
		width: 480
		height: 360
		vmpv: unsafe { nil }
		logo: unsafe { nil }
		path: ''
		// video_path
	}

	// Media Playback Audio Video Subtitle Tools View Help
	mb.add_child(ui.MenuItem.new(
		text: 'Media'
		children: [
			ui.MenuItem.new(
				text: 'Open File...'
				click_event_fn: plr.open_click
			),
		]
	))

	mb.add_child(ui.MenuItem.new(
		text: 'Help'
		children: [
			ui.MenuItem.new(
				text: 'About iUI'
			),
		]
	))

	window.bar = mb

	p.add_child_with_flag(plr, ui.borderlayout_center)

	window.add_child(p)

	window.run()
}

fn (mut p Player) open_click(mut win ui.Window, com ui.MenuItem) {
	if !isnil(p.vmpv) {
		dump('SET PAUSE')
		p.vmpv.is_pause = true
		p.vmpv.free()
	}

	selected_file := file_dialog.open_dialog('') // '' // dialog.file_dialog()
	dump(selected_file)

	p.path = selected_file // or { return }
	p.setup(win.graphics_context)
}

fn (mut p Player) slid_draw(mut e ui.DrawEvent) {
	mut tar := e.target
	if mut tar is ui.Slider {
		if !isnil(p.vmpv) {
			tar.max = f32(p.vmpv.i_video_duration)
			tar.cur = f32(p.vmpv.i_video_position)
		}

		cw := e.target.parent.children[0].width + e.target.parent.children[1].width +
			e.target.parent.children[3].width + 10
		ww := e.target.parent.width - cw
		e.target.width = ww - 15
	}
}

fn (mut p Player) slid_down(mut e ui.MouseEvent) {
	mut tar := e.target
	if mut tar is ui.Slider {
		dump(tar.scroll_i)
		if !isnil(p.vmpv) {
			p.vmpv.seek(tar.scroll_i)
		}
	}
}

@[heap]
pub struct Player {
	ui.Component_A
mut:
	init bool
	vmpv &MPVPlayer
	//= unsafe { nil }
	tik        int
	path       string
	logo       &ui.Image
	bar_height int = 30
	mx         int
	my         int
}

fn (mut this Player) draw(ctx &ui.GraphicsContext) {
	bg := gx.black // ctx.theme.button_bg_normal
	bo := gx.black // ctx.theme.button_border_normal
	if this.is_mouse_rele {
		this.is_mouse_rele = false
	}

	if this.is_mouse_down {
	}

	ctx.gg.draw_rect_filled(this.x, this.y, this.width, this.height, bg)

	if !this.init {
		this.init = true
		this.setup_controls(ctx)
	}

	if isnil(this.vmpv) {
		this.logo.x = this.x + (this.width / 2) - (this.logo.width / 2)
		this.logo.y = this.y + (this.height / 2) - (this.logo.height / 2) - this.bar_height
		this.logo.draw(ctx)
	}

	if this.tik > 5 && !isnil(this.vmpv) {
		this.vmpv.draw_(this.x, this.y, this.width, this.height - this.bar_height)
	}
	this.tik += 1

	if this.tik > 200 && this.bar_height > 0 {
		this.bar_height -= 2
	}

	if this.mx != ctx.win.mouse_x && this.tik > 200 {
		this.tik = 6
	}

	if this.tik < 200 && this.bar_height < 30 {
		this.bar_height += 2
	}

	this.mx = ctx.win.mouse_x
	this.my = ctx.win.mouse_y

	bary := this.y + this.height - this.bar_height

	ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, bo)

	for mut com in this.children {
		com.set_parent(this)
		com.draw_with_offset(ctx, this.x, bary)
	}
}

fn (mut this Player) setup(ctx &ui.GraphicsContext) {
	mut window := &MPVPlayer{
		video_path: this.path
	}
	window.ctx = ctx.win.gg

	window.init(unsafe { nil })

	this.vmpv = window

	// this.setup_controls(ctx)
}

fn (mut this Player) setup_controls(ctx &ui.GraphicsContext) {
	mut logo := ui.Image.new(file: 'assets/logo.png')
	logo.pack()
	this.logo = logo

	mut barp := ui.Panel.new(layout: ui.FlowLayout.new(vgap: 1))

	barp.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		e.target.width = e.target.parent.width
		e.target.height = 30
	})

	mut pbtn := ui.Button.new(
		text: 'Play'
	)

	pbtn.subscribe_event('draw', fn [mut this, mut pbtn] (mut e ui.DrawEvent) {
		if isnil(this.vmpv) {
			return
		}

		if this.vmpv.is_pause {
			e.target.text = ' Play  '
		} else {
			e.target.text = 'Pause'
		}
		pbtn.pack()
	})

	pbtn.subscribe_event('mouse_up', fn [mut this] (mut e ui.MouseEvent) {
		this.cmd_async([&char('cycle'.str), &char('pause'.str), &char(0)])
	})

	mut s_lbl := ui.Label.new(text: '00:00:00')
	mut e_lbl := ui.Label.new(text: '00:00:00')

	s_lbl.set_bounds(0, 3, 0, 0)
	e_lbl.set_bounds(0, 3, 0, 0)

	s_lbl.subscribe_event('draw', fn [this] (mut e ui.MouseEvent) {
		e.target.width = e.ctx.text_width(e.target.text)
		if isnil(this.vmpv) {
			return
		}
		e.target.text = format_time(this.vmpv.i_video_position)
	})

	e_lbl.subscribe_event('draw', fn [this] (mut e ui.MouseEvent) {
		e.target.width = e.ctx.text_width(e.target.text)
		if isnil(this.vmpv) {
			return
		}
		e.target.text = format_time(this.vmpv.i_video_duration)
	})

	mut slid := ui.Slider.new(
		min: 0
		max: 100
	)
	slid.subscribe_event('draw', this.slid_draw)
	slid.subscribe_event('mouse_up', this.slid_down)
	slid.set_bounds(0, 5, 100, 12)

	barp.add_child(pbtn)
	barp.add_child(s_lbl)
	barp.add_child(slid)
	barp.add_child(e_lbl)
	this.add_child(barp)
}

fn format_time(seconds f64) string {
	hours := int(seconds / 3600)
	minutes := int(math.fmod(seconds, 3600)) / 60
	second := int(math.fmod(seconds, 60))

	return pad(hours.str()) + ':' + pad(minutes.str()) + ':' + pad(second.str())
}

fn pad(s string) string {
	if s.len == 1 {
		return '0' + s
	}
	return s
}

fn (this &Player) cmd_async(chs []&char) int {
	if isnil(this.vmpv) {
		return -1
	}
	return C.mpv_command_async(this.vmpv.i_mpv_handle, 0, chs.data)
}

pub fn (mut mpv MPVPlayer) draw_texture_(x int, y int, w int, h int) {
	// t_res := mpv.ctx.window_size()

	// Note: some math to make the video always centered and fits into the window.
	mut factor := f64(c_win_height) / f64(h)

	if factor == 0.0 {
		factor = 1.0
	}

	ix := 0 // (w - int(c_win_width / factor)) / 2
	iw := w // int(c_win_width / factor)
	ih := h // int(c_win_height / factor)
	mpv.ctx.draw_image(x + ix, y, iw, ih, mpv.i_texture)
}

pub fn (mut mpv MPVPlayer) draw_(x int, y int, w int, h int) {
	mpv.update_texture()
	mpv.draw_texture_(x, y, w, h)
}

pub fn (mut mpv MPVPlayer) seek(val int) {
	/// C.mpv_command_async(mpv.i_mpv_handle, 0, [&char('seek'.str), &char('absolute'.str), &char('${val}'.str)].data)
	C.mpv_set_property_string(mpv.i_mpv_handle, 'time-pos'.str, '${val}'.str)
}
