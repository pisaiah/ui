module imagex

import gg
import os
import iui as ui
import time
import math

// C interop for stb_image + stb_image_resize
#flag -I @VROOT/thirdparty/stb_image
#include "stb_image.h"
#include "stb_image_resize2.h"

fn C.stbi_load(filename &char, x &int, y &int, comp &int, req_comp int) &u8
fn C.stbi_image_free(ret &u8)
fn C.stbir_resize_uint8_linear(input_pixels &u8, in_w int, in_h int, in_stride int,
	output_pixels &u8, out_w int, out_h int, out_stride int,
	num_channels int) int

@[heap]
pub struct ResizedImage {
	ui.Image
mut:
	resized_width  ?int
	resized_height ?int
	resize_percent ?f32
	data           &u8 = unsafe { nil }
	img_init       bool
	ww             int
	hh             int
	async          bool
}

@[params]
pub struct ResizedImageConfig {
	ui.ImgConfig
pub:
	resized_width  ?int
	resized_height ?int
	resize_percent ?f32
	async          bool
}

pub fn ResizedImage.new(c ResizedImageConfig) &ResizedImage {
	return &ResizedImage{
		text:           c.file
		need_init:      c.file.len > 0
		need_pack:      c.pack
		img_id:         c.id
		img:            c.img
		rotate:         c.rotate
		width:          c.width
		height:         c.height
		resized_width:  c.resized_width
		resized_height: c.resized_height
		resize_percent: c.resize_percent
		async:          c.async
	}
}

// Draws a rotating arc loader using filled arcs
// ctx: gg.Context
// x, y: center position
// inner_radius: inner radius of the ring
// thickness: ring thickness
// angle: current rotation angle (animate this)
// arc_fraction: fraction of circle covered (0.0–1.0)
// base_color: background ring color
// progress_color: arc segment color
fn draw_loader_arc(ctx &gg.Context, x f32, y f32, inner_radius f32, thickness f32,
	angle f32, arc_fraction f32, base_color gg.Color, progress_color gg.Color) {
	// Draw base ring (full circle)
	ctx.draw_arc_filled(x, y, inner_radius, thickness, 0, 2 * math.pi, 100, base_color)

	// Draw progress arc
	arc_angle := 2 * math.pi * arc_fraction
	ctx.draw_arc_filled(x, y, inner_radius, thickness, angle, angle + arc_angle, 100,
		progress_color)
}

fn (mut i ResizedImage) draw(g &ui.GraphicsContext) {
	if i.Image.need_init {
		i.init_resize(g)
		i.Image.need_init = false
	}

	if !isnil(i.data) && !i.img_init {
		mut ctx := g.gg
		id := ctx.new_streaming_image(i.ww, i.hh, 4, gg.StreamingImageConfig{}) // or { panic(err) }
		ctx.update_pixel_data(id, i.data)
		i.Image.img_id = id
		i.img_init = true

		C.stbi_image_free(i.data)
	}

	if !i.img_init {
		g.draw_corner_rect(i.x, i.y, i.width, i.height, g.theme.text_color, g.theme.background)
		angle := f32(0.05 * f32(g.gg.frame))
		draw_loader_arc(g.gg, i.x + (i.width / 2), i.y + (i.height / 2), 60, 8, angle,
			0.25, g.theme.text_color, g.theme.scroll_bar_color)
		return
	}

	i.Image.draw(g)
}

fn (mut i ResizedImage) do_load_resized(g &ui.GraphicsContext, w int, h int) {
	load_resized_image_cb(fn [mut i] (data &u8, ww int, hh int) {
		i.data = unsafe { data }
		i.Image.width = ww
		i.Image.width = hh
		i.ww = ww
		i.hh = hh
	}, i.text, w, h, i.resize_percent)
}

fn (mut i ResizedImage) init_resize(g &ui.GraphicsContext) {
	// this.init(ctx)

	start := time.now()

	w := i.resized_width or { i.width }
	h := i.resized_height or { i.height }

	if i.async {
		spawn i.do_load_resized(g, w, h)
	} else {
		i.do_load_resized(g, w, h)
	}

	i.Image.need_init = false

	$if dump_img_load_time ? {
		end := time.now()
		dump(end - start)
	}
}

fn get_perc(perc f32) f32 {
	if perc > 1 {
		return perc / 100.0
	}
	return perc
}

// Custom loader: load, downscale, wrap into gg.Image
pub fn load_resized_image(mut ctx gg.Context, path string, target_w int, target_h int, perc ?f32) !(int, int, int) {
	resized, th, tw := resize_image(path, target_w, target_h, perc) or { return err }

	stream_img := ctx.new_streaming_image(tw, th, 4, gg.StreamingImageConfig{}) // or { panic(err) }
	ctx.update_pixel_data(stream_img, resized)

	return stream_img, th, tw
}

pub fn load_resized_image_cb(cb fn (&u8, int, int), path string, target_w int, target_h int, perc ?f32) {
	resized, th, tw := resize_image(path, target_w, target_h, perc) or { return }
	cb(resized, th, tw)

	// stream_img := ctx.new_streaming_image( tw, th, 4, gg.StreamingImageConfig{}) // or { panic(err) }
	// ctx.update_pixel_data(stream_img, resized)

	// return stream_img, th, tw
}

pub fn resize_image(path string, target_w int, target_h int, perc ?f32) !(&u8, int, int) {
	mut w := 0
	mut h := 0
	mut comp := 0

	$if dump_img_load_time ? {
		dump('Loading Image..')
	}

	data := C.stbi_load(path.str, &w, &h, &comp, 4)
	if data == unsafe { nil } {
		return error('Failed to load image')
	}
	defer {
		C.stbi_image_free(data)
		data.free()
		unsafe {
			free(data)
		}
	}

	$if dump_img_load_time ? {
		dump('Resizing Image to target size..')
	}

	tw := int(if perc != none { f32(w) * get_perc(perc) } else { target_w })
	th := int(if perc != none { f32(h) * get_perc(perc) } else { target_h })

	mut resized := unsafe { malloc(tw * th * 4) }

	C.stbir_resize_uint8_linear(data, w, h, 0, resized, tw, th, 0, 4)

	$if dump_img_load_time ? {
		dump('Resized Image.')
	}
	// stream_img := ctx.new_streaming_image( tw, th, 4, gg.StreamingImageConfig{}) // or { panic(err) }
	// ctx.update_pixel_data(stream_img, resized)
	return resized, th, tw
}

/*
fn main() {
    mut ctx := gg.new_context(
        bg_color: gg.white,
        width: 800,
        height: 600,
        use_ortho: true,
        create_window: true,
    )

    // Example: load a huge image but downscale to 1024x1024
    img := load_resized_image(&ctx, 'huge_photo.png', 1024, 1024) or {
        panic(err)
    }

    ctx.run(fn (ctx &gg.Context) {
        ctx.begin()
        ctx.draw_image(img, 0, 0)
        ctx.end()
    })
}
*/
