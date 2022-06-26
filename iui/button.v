module iui

import gg
import gx

//
// Button - implements Component interface
pub struct Button {
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

[params]
pub struct ButtonConfig {
	bounds         Bounds
	click_event_fn fn (voidptr, voidptr, voidptr) = fn (a voidptr, b voidptr, c voidptr) {}
	should_pack    bool
	user_data      voidptr
}

pub fn button(app &Window, text string, conf ButtonConfig) Button {
	return Button{
		text: text
		x: conf.bounds.x
		y: conf.bounds.y
		width: conf.bounds.width
		height: conf.bounds.height
		app: app
		click_event_fn: fn (mut win Window, a Button) {}
		new_click_event_fn: conf.click_event_fn
		user_data: conf.user_data
		need_pack: conf.should_pack
	}
}

pub fn (mut this Button) set_background(color gx.Color) {
	this.override_bg = true
	this.override_bg_color = color
}

pub fn (mut btn Button) draw(ctx &GraphicsContext) {
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

fn (this &Button) draw_background() {
	mid_x := this.x + (this.width / 2)
	mid_y := this.y + (this.height / 2)

	mouse_x := this.app.mouse_x
	mouse_y := this.app.mouse_y

	mouse_in_x := abs(mid_x - mouse_x) < this.width / 2
	mouse_in_y := abs(mid_y - mouse_y) < this.height / 2

	mouse_in := mouse_in_x && mouse_in_y

	bg := this.get_bg(mouse_in)
	border := this.get_border(mouse_in)

	this.app.gg.draw_rounded_rect_filled(this.x, this.y, this.width, this.height, 1, bg)
	this.app.gg.draw_rounded_rect_empty(this.x, this.y, this.width, this.height, 1, border)
}

fn (this &Button) get_border(is_hover bool) gx.Color {
	if this.is_mouse_down {
		return this.app.theme.button_border_click
	}
	if is_hover {
		return this.app.theme.button_border_hover
	}
	return this.app.theme.button_border_normal
}

fn (this &Button) get_bg(is_hover bool) gx.Color {
	if this.override_bg {
		return this.override_bg_color
	}

	should := this.app.bar == voidptr(0) || this.app.bar.tik > 90

	if this.is_mouse_down && should {
		return this.app.theme.button_bg_click
	}
	if is_hover && should {
		return this.app.theme.button_bg_hover
	}
	return this.app.theme.button_bg_normal
}

fn (mut app Window) draw_button(x int, y int, width int, height int, mut btn Button) {
	if btn.need_pack {
		btn.pack_do()
	}

	text := btn.text
	size := text_width(app, text) / 2
	sizh := text_height(app, text) / 2

	// Handle click
	if btn.is_mouse_rele {
		if app.bar == voidptr(0) || app.bar.tik > 90 {
			btn.click_event_fn(app, *btn)
			btn.new_click_event_fn(app, btn, btn.user_data)
		}
		btn.is_mouse_rele = false
	}

	// Draw Button Background & Border
	btn.draw_background()

	// Draw Button Text
	ctx := app.graphics_context
	ctx.draw_text((x + (width / 2)) - size, y + (height / 2) - sizh, text, ctx.font, gx.TextCfg{
		size: app.font_size
		color: ctx.theme.text_color
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
