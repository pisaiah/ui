module iui

import gg
import gx

// Button - implements Component interface
struct Button {
	Component_A
pub mut:
	app                &Window
	click_event_fn     fn (mut Window, Button)
	new_click_event_fn fn (voidptr, voidptr, voidptr)
	need_pack          bool
	extra              string
	user_data          voidptr
	override_bg        bool
	override_bg_color  gx.Color
}

pub fn button(app &Window, text string) Button {
	return Button{
		text: text
		app: app
		click_event_fn: fn (mut win Window, a Button) {}
		new_click_event_fn: fn (a voidptr, b voidptr, c voidptr) {}
		user_data: 0
	}
}

pub fn (mut this Button) set_background(color gx.Color) {
	this.override_bg = true
	this.override_bg_color = color
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
	btn.height = text_height(btn.app, btn.text + 'a') + 13
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
	if (abs(mid - app.mouse_x) < (width / 2)) && (abs(midy - app.mouse_y) < (height / 2)) {
		if app.bar == 0 || app.bar.tik > 90 {
			bg = app.theme.button_bg_hover
			border = app.theme.button_border_hover
		}
	}

	if btn.override_bg {
		bg = btn.override_bg_color
	}

	if btn.is_mouse_rele {
		if app.bar == 0 || app.bar.tik > 90 {
			btn.click_event_fn(app, *btn)
			btn.new_click_event_fn(app, btn, btn.user_data)
		}
		btn.is_mouse_rele = false
	}

	// Detect Click
	if btn.is_mouse_down {
		// btn.eb.publish('click', work, error) // TODO: How to use Eventbus without MEMORY ERROR.
		bg = app.theme.button_bg_click
		border = app.theme.button_border_click
	}

	// Draw Button Background & Border
	app.gg.draw_rounded_rect_filled(x, y, width, height, 4, bg)
	app.gg.draw_rounded_rect_empty(x, y, width, height, 4, border)

	// Draw Button Text
	app.gg.draw_text((x + (width / 2)) - size, y + (height / 2) - sizh, text, gx.TextCfg{
		size: app.font_size
		color: app.theme.text_color
	})
}

// TODO [deprecated: 'use set_click_fn']
pub fn (mut com Button) set_click(b fn (mut Window, Button)) {
	com.click_event_fn = b
}

pub fn (mut com Button) set_click_fn(b fn (voidptr, voidptr, voidptr), extra_data voidptr) {
	com.new_click_event_fn = b
	com.user_data = extra_data
}
