module main

import iui as ui
import gx

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title: 'My Window'
		width: 520
		height: 400
		theme: ui.theme_default()
	)

	mut p := ui.Panel.new()

	mut slid := ui.Slider.new(
		min: 0
		max: 100
	)
	slid.subscribe_event('draw', slid_draw)
	slid.set_bounds(0, 0, 100, 12)
	p.add_child(slid)

	mut slid2 := ui.Slider.new(
		min: 0
		max: 100
		dir: .vert
	)
	slid2.scroll = false
	slid2.subscribe_event('draw', slid_draw)
	slid2.set_bounds(0, 0, 9, 50)
	p.add_child(slid2)

	mut plr := &Player{
		x: 0
		y: 0
		width: 320
		height: 240
	}
	p.add_child(plr)

	window.add_child(p)

	// Start GG / Show Window
	window.run()
}

fn slid_draw(mut e ui.DrawEvent) {
	mut tar := e.target
	if mut tar is ui.Slider {
		if tar.id == '1' {
			tar.cur -= 1
		} else {
			tar.cur += 1
		}
		if tar.cur > tar.max {
			tar.id = '1'
		}
		if tar.cur < 0 {
			tar.id = '0'
		}
	}
}

pub struct Player {
	ui.Component_A
}

fn (mut this Player) draw(ctx &ui.GraphicsContext) {
	bg := ctx.theme.button_bg_normal
	bo := ctx.theme.button_border_normal

	ctx.gg.draw_rect_filled(this.x, this.y + this.height - 30, this.width, 30, bg)
	ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, bo)
}
