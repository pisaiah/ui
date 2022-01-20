module iui

import gg
import gx

// Image - implements Component interface
struct Image {
	Component_A
pub mut:
	app            &Window
	text           string
	click_event_fn fn (mut Window, Image)
	in_modal       bool
	need_pack      bool
	img            &gg.Image
}

pub fn image(app &Window, img &gg.Image) &Image {
	return &Image{
		text: ''
		img: img
		app: app
		click_event_fn: blank_event_im
	}
}

pub fn image_with_size(app &Window, img &gg.Image, width int, height int) &Image {
	return &Image{
		text: ''
		img: img
		app: app
		width: width
		height: height
		click_event_fn: blank_event_im
	}
}

pub fn image_from_byte_array_with_size(mut app Window, b []byte, width int, height int) &Image {
	mut img := &Image{
		text: ''
		img: 0
		app: app
		width: width
		height: height
		click_event_fn: blank_event_im
	}
	gg_im := app.gg.create_image_from_byte_array(b)
	img.img = &gg_im
	return img
}

pub fn (mut this Image) draw() {
	this.app.gg.draw_image(this.x, this.y, this.width, this.height, this.img)
}

pub fn (mut this Image) pack() {
	this.need_pack = true
}

pub fn (mut btn Image) pack_do() {
	width := text_width(btn.app, btn.text + 'ab')
	btn.width = width
	btn.height = text_height(btn.app, btn.text) + 4
	btn.need_pack = false
}

fn (mut app Window) draw_image(x int, y int, width int, height int, mut btn Image) {
	if btn.need_pack {
		btn.pack_do()
	}

	text := btn.text
	size := text_width(app, text) / 2
	sizh := text_height(app, text) / 2

	// mut bg := app.theme.button_bg_normal
	// mut border := app.theme.button_border_normal

	// mut mid := (x + (width / 2))
	// mut midy := (y + (height / 2))

	// Detect Hover
	// if (math.abs(mid - app.mouse_x) < (width / 2)) && (math.abs(midy - app.mouse_y) < (height / 2)) {
	// bg = app.theme.button_bg_hover
	// border = app.theme.button_border_hover
	//}

	if btn.is_mouse_rele {
		btn.is_mouse_rele = false
		btn.click_event_fn(app, *btn)
		// btn.is_selected = true
	}

	// Detect Click
	if btn.is_mouse_down {
		// bg = app.theme.button_bg_click
		// border = app.theme.button_border_click
	}

	// Draw Button Text
	app.gg.draw_text((x + (width / 2)) - size, y + (height / 2) - sizh, text, gx.TextCfg{
		size: app.font_size
		color: app.theme.text_color
	})
}

pub fn (mut com Image) set_click(b fn (mut Window, Image)) {
	com.click_event_fn = b
}

pub fn blank_event_im(mut win Window, a Image) {
}
