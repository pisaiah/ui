module iui

import gg
import os

// Image - implements Component interface
pub struct Image {
	Component_A
pub mut:
	text      string
	need_pack bool
	img       &gg.Image
	rotate    int
	need_init bool
	img_id    int
}

[params]
pub struct ImgConfig {
	file   string
	img    &gg.Image = unsafe { nil }
	rotate int
	id     int
	pack   bool
}

// New Image
pub fn Image.new(c ImgConfig) &Image {
	return &Image{
		text: c.file
		need_init: c.file.len > 0
		need_pack: c.pack
		img_id: c.id
		img: c.img
		rotate: c.rotate
	}
}

// [deprecated]
pub fn image_from_byte_array_with_size(mut w Window, b []u8, width int, h int) &Image {
	mut img := &Image{
		text: ''
		img: 0
		width: width
		height: h
	}
	gg_im := w.gg.create_image_from_byte_array(b) or { panic(err) }
	img.img = &gg_im
	return img
}

pub fn image_from_bytes(mut w Window, b []u8, width int, height int) &Image {
	return image_from_byte_array_with_size(mut w, b, width, height)
}

pub fn (mut this Image) draw(ctx &GraphicsContext) {
	if this.need_init {
		mut win := ctx.win
		if os.exists(this.text) {
			img := win.gg.create_image(this.text) or { panic(err) }
			this.img = &img
		} else {
			abp := os.resource_abs_path(this.text)
			if os.exists(abp) {
				img := win.gg.create_image(abp) or { panic(err) }
				mut ggg := ctx.gg
				this.img_id = ggg.cache_image(img)
			}
		}
		this.need_init = false
	}

	if this.need_pack {
		this.pack_do()
	}

	if this.is_mouse_rele {
		this.is_mouse_rele = false
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

pub fn (mut i Image) pack() {
	i.need_pack = true
}

pub fn (mut i Image) pack_do() {
	i.width = i.img.width
	i.height = i.img.height
}

pub fn (mut i Image) set_draw_rotation(deg int) {
	i.rotate = deg
}
