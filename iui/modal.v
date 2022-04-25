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
	close          Button
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
	}
}

pub fn (mut this Modal) draw(ctx &GraphicsContext) {
	mut app := this.window
	mut ws := gg.window_size()

	this.width = ws.width
	this.height = ws.height

	if this.z_index <= 501 {
		// Only draw background for one modal.
		app.gg.draw_rect_filled(0, 0, ws.width, ws.height, gx.rgba(0, 0, 0, 150))
	}

	wid := this.in_width
	hei := this.in_height

	xs := (ws.width / 2) - (wid / 2) - this.left_off
	this.xs = xs
	app.gg.draw_rounded_rect_filled(xs, this.top_off, wid, 26, 2, app.theme.button_bg_hover)

	mut title := this.text
	tw := text_width(app, title)
	th := text_height(app, title)
	app.gg.draw_text((ws.width / 2) - (tw / 2), this.top_off + (th / 2) - 1, title, gx.TextCfg{
		size: app.font_size
		color: app.theme.text_color
	})

	for i := 0; i < 4; i++ {
		app.draw_bordered_rect((ws.width / 2) - (wid / 2) + i - this.left_off, this.top_off + 24 + i,
			wid - (i * 2), hei - (i * 2), 2, app.theme.background, app.theme.button_bg_hover)
	}

	// Do component draw event again to fix z-index
	this.draw_event_fn(mut app, &Component(this))

	if this.needs_init {
		this.create_close_btn(mut app, true)
		this.needs_init = false
	}

	for mut com in this.children {
		com.draw_event_fn(mut app, com)
		app.draw_with_offset(mut com, xs, this.y + this.top_off + 26)
	}
}

pub fn (mut this Modal) create_close_btn(mut app Window, ce bool) Button {
	mut close := button(app, 'OK')
	close.x = (300 / 2) + (100 / 2)
	close.y = (this.in_height) - 35
	close.width = 100
	close.height = 25

	if ce {
		close.set_click(default_modal_close_fn)
	}

	this.children << close
	this.close = close
	return close
}

pub fn default_modal_close_fn(mut win Window, btn Button) {
	win.components = win.components.filter(mut it !is Modal)
}

pub fn (mut com Modal) set_click(b fn (mut Window, Modal)) {
	com.click_event_fn = b
}
