module iui

import gg
import sokol.sgl
import sokol.gfx

#flag -I @VMODROOT/src/extra/
#include "@VMODROOT/src/extra/winstuff.c"

pub struct WLabel {
	Component_A
mut:
	text    string
	data    &u8 = unsafe { nil }
	simg_ok bool
	simg    gfx.Image
	ok      bool
}

pub fn (mut wl WLabel) draw(ctx &GraphicsContext) {
	if isnil(wl.data) {
		bb := C.iui_text_pix(wl.text.to_wide(), wl.text.len, ctx.font_size, &wl.width,
			&wl.height)
		wl.data = bb
	}

	if !wl.simg_ok {
		wl.init_sokol_image()
	}

	x0 := wl.x * ctx.gg.scale
	y0 := wl.y * ctx.gg.scale
	x1 := (wl.x + wl.width) * ctx.gg.scale
	y1 := (wl.y + wl.height) * ctx.gg.scale

	// sgl.load_pipeline(ctx.gg.pipeline.alpha)

	sgl.enable_texture()
	sgl.texture(wl.simg)

	sgl.begin_quads()
	sgl.v2f_t2f(x0, y0, 0, 0)
	sgl.v2f_t2f(x1, y0, 1, 0)
	sgl.v2f_t2f(x1, y1, 1, 1)
	sgl.v2f_t2f(x0, y1, 0, 1)
	sgl.end()

	sgl.disable_texture()
}

// init_sokol_image initializes this `Image` for use with the
// sokol graphical backend system.
pub fn (mut img WLabel) init_sokol_image() &WLabel {
	mut img_desc := gfx.ImageDesc{
		width: img.width
		height: img.height
		num_mipmaps: 0
		wrap_u: .clamp_to_edge
		wrap_v: .clamp_to_edge
		label: 'aaa'.str // img.path.str
		d3d11_texture: 0
	}

	img_size := usize(4 * img.width * img.height)
	img_desc.data.subimage[0][0] = gfx.Range{
		ptr: img.data
		size: img_size
	}
	img.simg = gfx.make_image(&img_desc)
	img.simg_ok = true
	img.ok = true
	return img
}

fn C.iui_text_pix(lpchtext &u16, le int, fs int, w &int, h &int) &u8
