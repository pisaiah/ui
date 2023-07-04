module iui

import gg
import gx

//
// Button - implements Component interface
pub struct Button {
	Component_A
pub mut:
	app                &Window
	icon               int
	click_event_fn     fn (mut Window, Button)
	new_click_event_fn fn (voidptr, voidptr, voidptr)
	need_pack          bool
	extra              string
	user_data          voidptr
	override_bg        bool
	override_bg_color  gx.Color
	icon_width         int
	icon_height        int
	border_radius      int
	area_filled        bool = true
}

[params]
pub struct ButtonConfig {
	text        string
	bounds      Bounds
	should_pack bool
	user_data   voidptr
	area_filled bool = true
	icon        int  = -1
}

[deprecated: 'Use button(ButtonConfig)']
pub fn button_with_icon(icon int, conf ButtonConfig) &Button {
	return &Button{
		text: ''
		icon: icon
		x: conf.bounds.x
		y: conf.bounds.y
		width: conf.bounds.width
		height: conf.bounds.height
		app: unsafe { nil }
		click_event_fn: fn (mut win Window, a Button) {}
		new_click_event_fn: unsafe { nil }
		user_data: conf.user_data
		need_pack: conf.should_pack
		area_filled: conf.area_filled
	}
}

pub fn button(conf ButtonConfig) &Button {
	return &Button{
		app: unsafe { nil }
		text: conf.text
		icon: conf.icon
		x: conf.bounds.x
		y: conf.bounds.y
		width: conf.bounds.width
		height: conf.bounds.height
		click_event_fn: fn (mut win Window, a Button) {}
		new_click_event_fn: unsafe { nil }
		user_data: conf.user_data
		need_pack: conf.should_pack
		area_filled: conf.area_filled
	}
}

// Sets the contentAreaFilled property, whether to paint
// See https://docs.oracle.com/javase/7/docs/api/javax/swing/AbstractButton.html#setContentAreaFilled(boolean)
pub fn (mut this Button) set_area_filled(val bool) {
	this.area_filled = val
}

pub fn (mut this Button) set_background(color gx.Color) {
	this.override_bg = true
	this.override_bg_color = color
}

pub fn (mut btn Button) draw(ctx &GraphicsContext) {
	if btn.app == unsafe { nil } {
		btn.app = ctx.win
	}

	btn.app.draw_button(btn.x, btn.y, btn.width, btn.height, mut btn)
}

pub fn (mut btn Button) pack() {
	btn.need_pack = true
}

pub fn (mut btn Button) pack_do() {
	width := text_width(btn.app, btn.text) + 4
	btn.width = width
	btn.height = 20 // text_height(btn.app, btn.text + 'a') + 13
	btn.need_pack = false
}

fn (this &Button) draw_background(ctx &GraphicsContext) {
	mid_x := this.x + (this.width / 2)
	mid_y := this.y + (this.height / 2)

	mouse_x := this.app.mouse_x
	mouse_y := this.app.mouse_y

	mouse_in_x := abs(mid_x - mouse_x) < this.width / 2
	mouse_in_y := abs(mid_y - mouse_y) < this.height / 2

	mouse_in := mouse_in_x && mouse_in_y

	bg := this.get_bg(mouse_in)
	border := this.get_border(mouse_in)

	if this.area_filled {
		ctx.theme.button_fill_fn(this.x, this.y, this.width, this.height, this.border_radius,
			bg, ctx)
	}
	if this.border_radius != -1 {
		this.app.gg.draw_rounded_rect_empty(this.x, this.y, this.width, this.height, this.border_radius,
			border)
	}
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

	should := true // this.app.bar == unsafe { nil } || this.app.bar.tik > 90

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
		if app.bar == unsafe { nil } || app.bar.tik > 90 {
			btn.click_event_fn(mut app, *btn)
			if !isnil(btn.new_click_event_fn) {
				btn.new_click_event_fn(app, btn, btn.user_data)
			}
		}
		btn.is_mouse_rele = false
	}

	// Draw Button Text
	ctx := app.graphics_context

	// Draw Button Background & Border
	btn.draw_background(ctx)

	if btn.width == 0 && btn.height == 0 {
		btn.pack_do()
	}

	if btn.icon != -1 {
		wid := if btn.icon_width > 0 { btn.icon_width } else { btn.width }
		hei := if btn.icon_height > 0 { btn.icon_height } else { btn.height }
		ctx.gg.draw_image_with_config(gg.DrawImageConfig{
			img_id: btn.icon
			img_rect: gg.Rect{
				x: btn.x + (btn.width / 2) - (wid / 2)
				y: btn.y + (btn.height / 2) - (hei / 2)
				width: wid
				height: hei
			}
		})
		return
	}

	ctx.draw_text((x + (width / 2)) - size, y + (height / 2) - sizh, text, ctx.font, gx.TextCfg{
		size: app.font_size
		color: ctx.theme.text_color
	})
}

[deprecated: 'use subscribe_event']
pub fn (mut com Button) set_click(b fn (mut Window, Button)) {
	com.click_event_fn = b
}

[deprecated: 'use subscribe_event']
pub fn (mut com Button) set_click_fn(b fn (voidptr, voidptr, voidptr), extra_data voidptr) {
	com.new_click_event_fn = b
	com.user_data = extra_data
}
