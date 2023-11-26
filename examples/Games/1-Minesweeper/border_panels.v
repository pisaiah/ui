module main

import iui as ui
import gx

fn top_panel() &ui.Panel {
	mut p := ui.Panel.new()
	p.set_bounds(0, 0, 12, 55)
	p.subscribe_event('draw', top_panel_draw)

	return p
}

fn (app &App) side_panel() &ui.Panel {
	mut p := ui.Panel.new()
	s := app.btn_size / 2
	p.set_bounds(0, 0, s, s)
	p.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		p := e.target
		e.ctx.gg.draw_rect_filled(p.x, p.y, p.width, p.height, gx.rgb(192, 192, 192))
		
		ph := e.target.parent.height
		pw := e.target.parent.width

		dif := (pw - ph) / 2
		
		if dif > 0 {
			e.target.width = dif
		} else {
			e.target.width = 10
		}
	})
	return p
}

fn top_panel_draw(mut e ui.DrawEvent) {
	p := e.target
	e.ctx.gg.draw_rect_filled(p.x, p.y, p.width, p.height, gx.rgb(192, 192, 192))
	par := e.target.parent
	e.target.height = par.height / 5

	txt := 'Minesweeper'

	tf := gx.TextCfg{
		size: 28
	}

	e.ctx.gg.set_text_cfg(tf)
	tw := e.ctx.text_width(txt) / 2
	py := p.y + (p.height / 2) - e.ctx.line_height
	e.ctx.draw_text(p.x + (p.width / 2) - tw, py, 'Minesweeper', 0, tf)
	e.ctx.gg.set_text_cfg(gx.TextCfg{ size: 12 })
}
