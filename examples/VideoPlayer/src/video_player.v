module main

import iui as ui
import gx
import os

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title: 'Video Player'
		width: 520
		height: 400
		theme: ui.theme_default()
	)

	window.set_theme(ui.theme_seven_dark())

	mut p := ui.Panel.new(
		layout: ui.BorderLayout.new()
	)
	p.set_bounds(0, 0, 520, 400)

	mut plr := &Player{
		x: 0
		y: 0
		width: 480
		height: 360
		vmpv: unsafe { nil }
	}

	p.add_child_with_flag(plr, ui.borderlayout_center)

	window.add_child(p)

	window.run()
}

fn (mut p Player) slid_draw(mut e ui.DrawEvent) {
	mut tar := e.target
	if mut tar is ui.Slider {
		tar.max = f32(p.vmpv.i_video_duration)
		tar.cur = f32(p.vmpv.i_video_position)

		cw := e.target.parent.children[0].width
		ww := e.target.parent.width - cw
		e.target.width = ww - 15
	}
}

fn (mut p Player) slid_down(mut e ui.MouseEvent) {
	mut tar := e.target
	if mut tar is ui.Slider {
		dump(tar.scroll_i)
		p.vmpv.seek(tar.scroll_i)
	}
}

pub struct Player {
	ui.Component_A
mut:
	init bool
	vmpv &MPVPlayer //= unsafe { nil }
	tik  int
}

fn (mut this Player) draw(ctx &ui.GraphicsContext) {
	bg := gx.black // ctx.theme.button_bg_normal
	bo := gx.black // ctx.theme.button_border_normal

	if this.is_mouse_rele {
		this.is_mouse_rele = false
	}

	if this.is_mouse_down {
	}

	if !this.init {
		this.init = true
		this.setup(ctx)
	}

	if this.tik > 5 {
		this.vmpv.draw_(this.x, this.y, this.width, this.height - 30)
	}
	this.tik += 1

	bary := this.y + this.height - 30

	ctx.gg.draw_rect_filled(this.x, bary, this.width, 30, bg)
	ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, bo)

	// mut com := &ui.Component(this.barp)
	for mut com in this.children {
		com.set_parent(this)
		com.draw_with_offset(ctx, this.x, bary)
	}
}

fn (mut this Player) setup(ctx &ui.GraphicsContext) {
	if os.args.len < 2 {
		eprintln('give path for the video.')
		exit(1)
	}

	video_path := os.args[1..].join(' ')

	dump(video_path)

	mut window := &MPVPlayer{
		video_path: video_path
	}
	window.ctx = ctx.win.gg

	window.init(unsafe { nil })

	mut barp := ui.Panel.new(layout: ui.FlowLayout.new(vgap: 1))

	barp.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		e.target.width = e.target.parent.width
		e.target.height = 30
	})

	this.vmpv = window

	mut pbtn := ui.Button.new(text: 'Play/Pause')
	pbtn.subscribe_event('mouse_up', fn [mut this] (mut e ui.MouseEvent) {
		// this.vmpv.play_video(this.vmpv.video_path)
		C.mpv_command_async(this.vmpv.i_mpv_handle, 0, [&char('cycle'.str), &char('pause'.str),
			&char(0)].data)

		// seek
	})

	mut slid := ui.Slider.new(
		min: 0
		max: 100
	)
	slid.subscribe_event('draw', this.slid_draw)
	slid.subscribe_event('mouse_up', this.slid_down)
	slid.set_bounds(0, 5, 100, 12)

	barp.add_child(pbtn)
	barp.add_child(slid)
	this.add_child(barp)
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
	C.mpv_set_property_string(mpv.i_mpv_handle, 'time-pos'.str, '${val}'.str)
}
