module iui

import gg
import os

// Image - implements Component interface
pub struct Image {
	Component_A
pub mut:
	app            &Window
	text           string
	click_event_fn fn (mut Window, Image)
	need_pack      bool
	img            &gg.Image
	rotate         int
	need_init      bool
	img_id         int
}

pub fn image_from_file(path string) &Image {
	return &Image{
		need_init: true
		text: path
		app: unsafe { nil }
		img: unsafe { nil }
		click_event_fn: blank_event_im
	}
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

pub fn image_from_byte_array_with_size(mut app Window, b []u8, width int, height int) &Image {
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

pub fn image_from_bytes(mut app Window, b []u8, width int, height int) &Image {
	return image_from_byte_array_with_size(mut app, b, width, height)
}

pub fn (mut this Image) draw(ctx &GraphicsContext) {
	if this.need_init {
		if os.exists(this.text) {
			// img := ctx.gg.create_image(this.text)
			// this.img = &img
		} else {
			abp := os.resource_abs_path(this.text)
			if os.exists(abp) {
				img := ctx.gg.create_image(abp)
				mut ggg := ctx.gg
				this.img_id = ggg.cache_image(img)
			}
		}
		this.need_init = false
	}

	if this.is_mouse_rele {
		this.is_mouse_rele = false
		mut win := ctx.win
		this.click_event_fn(mut win, *this)
	}

	ctx.gg.draw_image_with_config(gg.DrawImageConfig{
		img: this.img
		img_id: this.img_id
		img_rect: gg.Rect{
			x: this.x
			y: this.y
			width: this.width
			height: this.height
		}
		rotate: this.rotate
	})
}

pub fn (mut this Image) pack() {
	this.need_pack = true
}

pub fn (mut btn Image) pack_do(ctx &GraphicsContext) {
	width := ctx.gg.text_width(btn.text + 'ab')
	btn.width = width
	btn.height = ctx.gg.text_height(btn.text) + 4
	btn.need_pack = false
}

[deprecated]
pub fn (mut com Image) set_click(b fn (mut Window, Image)) {
	com.click_event_fn = b
}

pub fn blank_event_im(mut win Window, a Image) {
}

pub fn (mut this Image) set_draw_rotation(deg int) {
	this.rotate = deg
}
