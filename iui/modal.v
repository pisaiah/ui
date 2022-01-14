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
}

pub fn (mut this Modal) add_child(com Component) {
    this.children << com
}

pub fn modal(app &Window, title string) &Modal {
	return &Modal{
		text: title
		window: app
		click_event_fn: fn (mut win Window, a Modal) {}
		z_index: 500
		needs_init: true
	}
}

pub fn (mut this Modal) draw() {
	// DRAW

	mut app := this.window
	mut ws := gg.window_size()

	this.width = ws.width
	this.height = ws.height

	app.gg.draw_rect_filled(0, 0, ws.width, ws.height, gx.rgba(0, 0, 0, 200))

	wid := 500
	hei := 300

	xs := (ws.width / 2) - (wid / 2)
	app.gg.draw_rounded_rect(xs, 50, wid, 26, 2, app.theme.button_bg_hover)

	mut title := this.text
	tw := text_width(app, title)
	th := text_height(app, title)
	app.gg.draw_text((ws.width / 2) - (tw / 2), 50 + (th / 2) - 1, title, gx.TextCfg{
		size: 16
		color: app.theme.text_color
	})

	for i := 0; i < 4; i++ {
		app.draw_bordered_rect((ws.width / 2) - (wid / 2) + i, 74 + i, wid - (i * 2),
			hei - (i * 2), 2, app.theme.background, app.theme.button_bg_hover)
	}

	/*mut spl := app.modal_text.split('\n')
	mut mult := 10
	for txt in spl {
		app.gg.draw_text((ws.width / 2) - (wid / 2) + 26, 86 + mult, txt, gx.TextCfg{
			size: 15
			color: app.theme.text_color
		})
		mult += app.gg.text_height(txt) + 4
	}*/

	if this.needs_init {
		mut close := button(app, 'OK')
		close.x = (300/2) + (100/2)
		println(close.x)
		//close.x = (ws.width / 2) - 50
		close.y = (300) - 35
		close.width = 100
		close.height = 25

		close.set_click(fn (mut win Window, mutbtn Button) {
			for mut com in win.components {
				if mut com is Modal {
					mut co := win.components.index(Component(com))
					win.components.delete(co)
				}
			}
		})

		this.draw_event_fn = fn (mut win Window, mut com Component) {
			if mut com is Modal {
				for mut kid in com.children {
					kid.draw_event_fn(mut win, kid)
				}
			}
		}

		this.children << close
		this.needs_init = false
	}

	//mut sx := (ws.width / 2) - (500 / 2)
	for mut com in this.children {
		draw_with_offset(mut com, xs, this.y + 76)
	}
}

pub fn (mut com Modal) set_click(b fn (mut Window, Modal)) {
	com.click_event_fn = b
}
