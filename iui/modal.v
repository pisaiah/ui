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
	children       []Component
	needs_init     bool
	close          Button
	shown          bool
}

pub fn (mut this Modal) add_child(com Component) {
	this.children << com
}

pub fn (mut this Modal) add_children(coms []Component) {
	for com in coms {
		this.children << com
	}
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
	}
}

pub fn (mut this Modal) draw() {
	// DRAW

	mut app := this.window
	mut ws := gg.window_size()

	this.width = ws.width
	this.height = ws.height

	app.gg.draw_rect_filled(0, 0, ws.width, ws.height, gx.rgba(0, 0, 0, 150))

	wid := 500
	hei := 300

	xs := (ws.width / 2) - (wid / 2)
	app.gg.draw_rounded_rect_filled(xs, 50, wid, 26, 2, app.theme.button_bg_hover)

	mut title := this.text
	tw := text_width(app, title)
	th := text_height(app, title)
	app.gg.draw_text((ws.width / 2) - (tw / 2), 50 + (th / 2) - 1, title, gx.TextCfg{
		size: app.font_size
		color: app.theme.text_color
	})

	for i := 0; i < 4; i++ {
		app.draw_bordered_rect((ws.width / 2) - (wid / 2) + i, 74 + i, wid - (i * 2),
			hei - (i * 2), 2, app.theme.background, app.theme.button_bg_hover)
	}

	if this.needs_init {
		this.create_close_btn(mut app, true)
		this.needs_init = false
	}

	for mut com in this.children {
		draw_with_offset(mut com, xs, this.y + 76)
	}
}

pub fn (mut this Modal) create_close_btn(mut app Window, ce bool) Button {
	mut close := button(app, 'OK')
	close.x = (300 / 2) + (100 / 2)
	close.y = (300) - 35
	close.width = 100
	close.height = 25

	if ce {
		close.set_click(fn (mut win Window, mutbtn Button) {
			win.components = win.components.filter(mut it !is Modal)
		})
	}

	this.children << close
	this.close = close
	return close
}

pub fn (mut com Modal) set_click(b fn (mut Window, Modal)) {
	com.click_event_fn = b
}
