module iui

import gg
import gx
import math

// Button - implements Component interface
struct Button {
	Component_A
pub mut:
	app            &Window
	click_event_fn fn (mut Window, Button)
	need_pack      bool
	in_modal       bool
}

pub fn button(app &Window, text string) Button {
	return Button{
		text: text
		app: app
		click_event_fn: fn (mut win Window, a Button) {}
	}
}

pub fn (mut btn Button) draw() {
	btn.app.draw_button(btn.x, btn.y, btn.width, btn.height, mut btn)
}

pub fn (mut btn Button) pack() {
	btn.need_pack = true
}

pub fn (mut btn Button) pack_do() {
	width := text_width(btn.app, btn.text + 'ab')
	btn.width = width
	btn.height = text_height(btn.app, btn.text) + 13
	btn.need_pack = false
}

fn (mut app Window) draw_button(x int, y int, width int, height int, mut btn Button) {
	if btn.need_pack {
		btn.pack_do()
	}

	text := btn.text
	size := text_width(app, text) / 2
	sizh := text_height(app, text) / 2

	mut bg := app.theme.button_bg_normal
	mut border := app.theme.button_border_normal

	mut mid := (x + (width / 2))
	mut midy := (y + (height / 2))

	// Detect Hover
	if (math.abs(mid - app.mouse_x) < (width / 2)) && (math.abs(midy - app.mouse_y) < (height / 2)) {
		bg = app.theme.button_bg_hover
		border = app.theme.button_border_hover
	}

	if btn.is_mouse_rele {
		btn.click_event_fn(app, *btn)
		btn.is_mouse_rele = false
	}

	// Detect Click
	if btn.is_mouse_down {
		// btn.eb.publish('click', work, error) // TODO: How to use Eventbus without INVALID MEMORY ERROR.
		if app.modal_show {
			if !btn.in_modal {
				return
			}
		}

		bg = app.theme.button_bg_click
		border = app.theme.button_border_click
	}

	// Draw Button Background & Border
	app.gg.draw_rounded_rect(x, y, width, height, 4, bg)
	app.gg.draw_rounded_rect_empty(x, y, width, height, 4, border)

	// Draw Button Text
	app.gg.draw_text((x + (width / 2)) - size, y + (height / 2) - sizh, text, gx.TextCfg{
		size: font_size
		color: app.theme.text_color
	})
}

pub fn (mut com Button) set_click(b fn (mut Window, Button)) {
	com.click_event_fn = b
}
