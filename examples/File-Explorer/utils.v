module main

import gg
import iui as ui
import os
import stbi

// Headers included with V (v/thirdparty/)
#include "stb_image.h"
#include "stb_image_resize2.h"
#include "stb_image_write.h"

// Wrap text into multiple lines based on max_width
fn wrap_text(g &ui.GraphicsContext, text string, max_width int, font_size int) []string {
	mut lines := []string{}
	mut current_line := ''
	mut current_width := 0

	for word in text.split(' ') {
		word_width := g.text_width(word)
		space_width := g.text_width(' ')

		if current_width + word_width + space_width > max_width {
			// push current line and reset
			lines << current_line.trim_space()
			current_line = word + ' '
			current_width = word_width + space_width
		} else {
			current_line += word + ' '
			current_width += word_width + space_width
		}
	}

	if current_line.len > 0 {
		lines << current_line.trim_space()
	}
	return lines
}

// Wrap a single word into multiple lines when it exceeds max_width
fn wrap_word(g &ui.GraphicsContext, word string, max_width int, font_size int) []string {
	mut lines := []string{}
	mut current_line := ''
	mut current_width := 0

	for ch in word.runes() {
		char_str := ch.str()
		char_width := g.text_width(char_str)

		if current_width + char_width > max_width {
			// push current line and reset
			lines << current_line
			current_line = char_str
			current_width = char_width
		} else {
			current_line += char_str
			current_width += char_width
		}
	}
	if current_line.len > 0 {
		lines << current_line
	}
	return lines
}

// Draw wrapped text at (x, y)
fn draw_wrapped_text1(g &ui.GraphicsContext, x int, y int, text string, max_width int, cfg gg.TextCfg) int {
	lines := wrap_word(g, text, max_width, 0)
	mut offset_y := 0
	line_height := g.line_height // add spacing

	for line in lines {
		tw := g.text_width(line)
		g.draw_text(x - (tw / 2), y + offset_y, line, g.font, cfg)
		offset_y += line_height
	}
	return lines.len
}

// Draw wrapped text at (x, y)
fn draw_wrapped_text(g &ui.GraphicsContext, text string, x int, y int, max_width int, font_size int, color gg.Color) {
	lines := wrap_text(g, text, max_width, font_size)
	mut offset_y := 0
	line_height := g.line_height + 4 // add spacing

	for line in lines {
		g.draw_text(x, y + offset_y, line, g.font, gg.TextCfg{
			size:  font_size
			color: color
		})
		offset_y += line_height
	}
}

// stb_image_write.h binding
fn C.stbi_write_png_to_func(func voidptr,  callback function pointer,
	context voidptr,  user data passed to callback,
	w int,  width,
	h int,  height,
	comp int,  number of channels (e.g. 4 for RGBA),
	data voidptr,  pointer to pixel data,
	stride_in_bytes int,  stride (bytes per row)) int

fn cb_malloc(s usize) voidptr {
	res := unsafe { malloc(isize(s)) }
	return res
}

// Testing
__global (
	atlas = &Atlas{
		buf_ptr: unsafe { nil }
	}
)

const atlas_size = 1024 // size of atlas texture

struct Atlas {
mut:
	cx          int
	cy          int
	img         int
	tiles       []Tile
	need_init   bool = true
	buf         []u8 = []u8{len: atlas_size * atlas_size * 4, init: 0}
	buf_ptr     &u8 // = buf.data// pointer to buf.data
	need_retile bool = true
}

fn (mut a Atlas) init(mut ctx gg.Context) {
	if !a.need_init {
		return
	}

	stream_img := ctx.new_streaming_image(atlas_size, atlas_size, 4, gg.StreamingImageConfig{})

	a.buf_ptr = a.buf.data

	a.img = stream_img
	a.need_init = false
}

// Copy all tiles into the persistent atlas buffer
fn (mut a Atlas) update_from_tiles() {
	if !a.need_retile {
		return
	}

	for t in a.tiles {
		for row in 0 .. img_size {
			dest_off := ((t.y + row) * atlas_size + t.x) * 4
			src_off := row * t.w * 4
			unsafe {
				C.memcpy((&u8(a.buf.data) + dest_off), (&u8(t.pixels) + src_off), t.w * 4)
			}
		}
	}
}

fn (mut a Atlas) add_tile(pixels &u8) {
	mm := ((a.cx + 1) * img_size) > atlas_size

	if mm {
		a.cx = 0
		a.cy += 1
	} else {
		a.cx += 1
	}

	a.tiles << Tile{
		x:      a.cx
		y:      a.cy
		pixels: pixels
	}
	a.need_retile = true
}

@[heap]
struct Tile {
	x      int
	y      int
	w      int = 48
	pixels &u8
}

// Custom loader: load image at reduced size
fn load_thumbnail_id(mut ctx gg.Context, path string, thumb_w int, thumb_h int) int {
	mut w := 0
	mut h := 0
	mut comp := 0
	data := C.stbi_load(path.str, &w, &h, &comp, 4) // force RGBA
	if isnil(data) {
		return 0 // error('Failed to load image')
	}

	atlas.init(mut ctx)

	mut resized := malloc(thumb_w * thumb_h * 4)
	C.stbir_resize_uint8_linear(data, w, h, 0, resized, thumb_w, thumb_h, 0, 4)
	stream_img := ctx.new_streaming_image(thumb_w, thumb_h, 4, gg.StreamingImageConfig{}) // or { panic(err) }
	ctx.update_pixel_data(stream_img, resized)

	atlas.add_tile(resized)

	// Free original data
	C.stbi_image_free(data)

	unsafe {
		// free(data)
		// free(resized)
	}
	// C.GC_FREE(resized)
	// C.GC_FREE(data)

	atlas.update_from_tiles()
	return atlas.img
	// return stream_img
}

struct MyImage {
	ui.Image
}

// New Image
pub fn MyImage.new(c ui.ImgConfig) &MyImage {
	return &MyImage{
		text:      c.file
		need_init: c.file.len > 0
		need_pack: c.pack
		img_id:    c.id
		img:       c.img
		rotate:    c.rotate
		width:     c.width
		height:    c.height
	}
}

fn (mut this MyImage) draw(ctx &ui.GraphicsContext) {
	if this.need_init {
		this.myinit(ctx)
		this.need_init = false
	}

	// dump('DRAW!! ${i.text}')
	// i.Image.draw(g)

	if this.need_pack {
		this.pack_do(ctx)
	}

	if this.is_mouse_rele {
		this.is_mouse_rele = false
	}

	ctx.gg.draw_image_with_config(gg.DrawImageConfig{
		img:       this.img
		img_id:    this.img_id
		img_rect:  gg.Rect{
			x:      this.x
			y:      this.y
			width:  this.width
			height: this.height
		}
		part_rect: gg.Rect{
			x:      0
			y:      0
			width:  48
			height: 48
		}
		rotation:  this.rotate
	})
}

fn (mut this MyImage) myinit(ctx &ui.GraphicsContext) {
	mut win := ctx.win
	if os.exists(this.text) {
		mut img := load_thumbnail_id(mut win.gg, this.text, img_size, img_size) // or { println(err) return }
		this.img_id = img
		this.width = img_size
		this.height = img_size
	}
}
