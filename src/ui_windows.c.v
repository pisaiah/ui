module iui

import gg
import gx
import sokol.sgl
import sokol.gfx

#flag -I @VMODROOT/src/extra/
#include "@VMODROOT/src/extra/winstuff.c"

pub fn (ctx &GraphicsContext) draw_win32_text(x int, y int, txt string, cfg gx.TextCfg) {
	mut win := ctx.win
	id := 'WL-${txt}'
	if id !in win.id_map {
		win.id_map[id] = &WLabel{
			text: txt
		}
	}

	mut lbl := win.get[&WLabel](id)
	lbl.x = x
	lbl.y = y

	if lbl.cfg != cfg {
		lbl.cfg = cfg
		lbl.dirt = true
	}

	lbl.cfg = cfg
	lbl.draw(ctx)
}

pub struct WLabel {
	Component_A
mut:
	text string
	data &u8 = unsafe { nil }
	sok  bool
	simg gfx.Image
	cfg  gx.TextCfg
	dirt bool
}

pub fn C.RGB(r u8, g u8, b u8) C.COLORREF

pub fn winc(co gx.Color) C.COLORREF {
	return C.RGB(co.r, co.g, co.b)
}

pub fn (mut wl WLabel) draw(ctx &GraphicsContext) {
	if isnil(wl.data) {
		// dump(wl.x)
		bb := C.i_txt_pix(wl.text.to_wide(), wl.text.len, ctx.font_size, &wl.width, &wl.height,
			winc(wl.cfg.color))
		wl.data = bb
	}

	if !wl.sok {
		wl.init_sokol_image()
		wl.dirt = false
	} else {
		// wl.update_simg(ctx)
	}

	if wl.dirt {
		bb := C.i_txt_pix(wl.text.to_wide(), wl.text.len, ctx.font_size, &wl.width, &wl.height,
			winc(wl.cfg.color))
		wl.data = bb

		// wl.update_simg(ctx)
		wl.init_sokol_image()
		wl.dirt = false
	}

	x0 := wl.x * ctx.gg.scale
	y0 := wl.y * ctx.gg.scale
	x1 := (wl.x + wl.width) * ctx.gg.scale
	y1 := (wl.y + wl.height) * ctx.gg.scale

	sgl.load_pipeline(ctx.gg.pipeline.alpha)

	sgl.enable_texture()
	sgl.texture(wl.simg)

	c := gx.white

	sgl.begin_quads()
	sgl.c4b(c.r, c.g, c.b, c.a)
	sgl.v2f_t2f(x0, y0, 0, 0)
	sgl.v2f_t2f(x1, y0, 1, 0)
	sgl.v2f_t2f(x1, y1, 1, 1)
	sgl.v2f_t2f(x0, y1, 0, 1)
	sgl.end()

	sgl.disable_texture()
}

pub fn (mut l WLabel) init_sokol_image() {
	mut img_desc := gfx.ImageDesc{
		width: l.width
		height: l.height
		num_mipmaps: 0
		wrap_u: .clamp_to_edge
		wrap_v: .clamp_to_edge
		label: ''.str
		d3d11_texture: 0
	}

	img_size := usize(4 * l.width * l.height)
	img_desc.data.subimage[0][0] = gfx.Range{
		ptr: l.data
		size: img_size
	}
	l.simg = gfx.make_image(&img_desc)
	l.sok = true
}

pub fn (mut wl WLabel) update_simg(ctx &GraphicsContext) {
	// fn update_image(img Image, data &ImageData)

	mut imd := &gfx.ImageData{}

	bb := C.i_txt_pix(wl.text.to_wide(), wl.text.len, ctx.font_size, &wl.width, &wl.height,
		winc(wl.cfg.color))
	wl.data = bb

	img_size := usize(4 * wl.width * wl.height)
	imd.subimage[0][0] = gfx.Range{
		ptr: wl.data
		size: img_size
	}
	gfx.update_image(wl.simg, imd)
}

fn C.i_txt_pix(lpchtext &u16, le int, fs int, w &int, h &int, tc C.COLORREF) &u8
