module main

import iui as ui
import gg
import gx

// Background component.
struct BackgroundBox {
	ui.Component_A
	win &ui.Window
}

fn bg_area(win &ui.Window) &BackgroundBox {
	return &BackgroundBox{
		win: win
		z_index: -1
	}
}

fn (mut this BackgroundBox) draw() {
	this.win.gg.draw_rect_filled(this.x, this.y, this.width, this.height, gx.white)
}
