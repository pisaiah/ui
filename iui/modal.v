module iui

import gg
import gx

// Modal - implements Component interface
struct Modal {
	Component_A
pub mut:
	window         &Window
	text           string
	click_event_fn fn (mut Window, Modal)
	in_modal       bool
	needs_init     bool
	close          &Button
	shown          bool

	in_width  int
	in_height int
	left_off  int
	top_off   int = 50
	xs        int
}

pub fn modal(app &Window, title string) &Modal {
	return &Modal{
		text: title
		window: app
		click_event_fn: fn (mut win Window, a Modal) {}
		z_index: 500
		needs_init: true
		draw_event_fn: fn (mut win Window, mut com Component) {
			if mut com is Modal {
				for mut kid in com.children {
					kid.draw_event_fn(mut win, kid)
				}
			}
		}
		in_width: 500
		in_height: 300
		close: 0
	}
}

pub fn (mut this Modal) draw(ctx &GraphicsContext) {
	mut app := this.window
	ws := gg.window_size()

	this.width = ws.width
	this.height = ws.height

	if this.z_index <= 501 {
		// Only draw background for one modal.
		app.gg.draw_rect_filled(0, 0, ws.width, ws.height, gx.rgba(0, 0, 0, 170))
	}

	wid := this.in_width
	hei := this.in_height
	bord_wid := 5
	wid_2 := wid - (bord_wid * 2)
	bg := ctx.theme.textbox_border

	xs := (ws.width / 2) - (wid / 2) - this.left_off
	this.xs = xs
	app.gg.draw_rounded_rect_filled(xs, this.top_off, wid, 40, 8, bg)

	title := this.text
	tw := text_width(app, title)
	th := ctx.line_height

	app.gg.draw_text((ws.width / 2) - (tw / 2), this.top_off + (th / 2) - 1, title, gx.TextCfg{
		size: app.font_size
		color: app.theme.text_color
	})

	top := 28
	app.gg.draw_rect_filled(xs, this.top_off + top, wid, hei + bord_wid, bg)
	app.gg.draw_rect_filled(xs + bord_wid, this.top_off + top, wid_2, hei, app.theme.background)
	app.gg.draw_rect_empty(xs + bord_wid, this.top_off + top, wid_2, hei, app.theme.button_bg_click)

	// Do component draw event again to fix z-index
	this.draw_event_fn(mut app, &Component(this))

	if this.needs_init {
		this.create_close_btn(mut app, true)
		this.needs_init = false
	}

	y_off := this.y + this.top_off + top
	for mut com in this.children {
		com.draw_event_fn(mut app, com)
		app.draw_with_offset(mut com, xs, y_off + 2)
	}
}

pub fn (mut this Modal) create_close_btn(mut app Window, ce bool) &Button {
	mut close := button(app, 'OK')

	y := this.in_height - 35
	close.set_bounds(200, y, 100, 25)

	if ce {
		close.set_click(default_modal_close_fn)
	}

	ref := &close
	this.children << ref
	this.close = ref
	return ref
}

pub fn default_modal_close_fn(mut win Window, btn Button) {
	win.components = win.components.filter(mut it !is Modal)
}

pub fn (mut com Modal) set_click(b fn (mut Window, Modal)) {
	com.click_event_fn = b
}
