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

pub fn (mut this WLabel) draw(ctx &GraphicsContext) {
	if isnil(this.data) {
		w := 0
		h := 0
		bb := C.iui_draw_text_to_pix(this.text.to_wide(), this.text.len, ctx.font_size,
			&w, &h)
		this.width = w
		this.height = h
		this.data = bb
	}

	if !this.simg_ok {
		this.init_sokol_image()
	}

	config := gg.DrawImageConfig{}

	mut img_rect := config.img_rect
	if img_rect.width == 0 && img_rect.height == 0 {
		img_rect = gg.Rect{this.x, this.y, this.width, this.height}
	}

	mut part_rect := config.part_rect
	if part_rect.width == 0 && part_rect.height == 0 {
		part_rect = gg.Rect{part_rect.x, part_rect.y, this.width, this.height}
	}

	u0 := part_rect.x / this.width
	v0 := part_rect.y / this.height
	u1 := (part_rect.x + part_rect.width) / this.width
	v1 := (part_rect.y + part_rect.height) / this.height
	x0 := img_rect.x * ctx.gg.scale
	y0 := img_rect.y * ctx.gg.scale
	x1 := (img_rect.x + img_rect.width) * ctx.gg.scale
	mut y1 := (img_rect.y + img_rect.height) * ctx.gg.scale

	sgl.load_pipeline(ctx.gg.pipeline.alpha)

	sgl.enable_texture()
	sgl.texture(this.simg)

	sgl.begin_quads()
	sgl.c4b(config.color.r, config.color.g, config.color.b, config.color.a)
	sgl.v3f_t2f(x0, y0, config.z, u0, v0)
	sgl.v3f_t2f(x1, y0, config.z, u1, v0)
	sgl.v3f_t2f(x1, y1, config.z, u1, v1)
	sgl.v3f_t2f(x0, y1, config.z, u0, v1)
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

fn C.iui_draw_text_to_pix(lpchtext &u16, le int, fs int, w &int, h &int) &u8

/*
import gx
import sokol.sapp

#flag -I @VMODROOT/src/extra/
#include "@VMODROOT/src/extra/winstuff.c"

// Reference: https://wiki.winehq.org/List_Of_Windows_Messages
const (
	cs_vredraw          = 0x0001
	cs_hredraw          = 0x0002
	gwlp_userdata       = -21
	dt_noclip           = 256
	idc_arrow           = 32512
)

// text c fns
fn C.DrawText(hdc C.HDC, lpchtext &u16, cch int, rect &C.tagRECT, format u32)
fn C.TextOut(hdc C.HDC, x int, y int , lpchtext &u16, cch int)

// BOOL TextOutA(HDC hdc, int x, int y, LPCSTR lpString, int c);

fn C.iui_text_size(hdc C.HDC, lpchtext &u16, le int) C.tagSIZE
fn C.fix_text_bg(hdc C.HDC)
fn C.SetTextColor(hdc C.HDC, color C.COLORREF)
fn C.iui_create_font(size int) C.HFONT

fn C.RGB(r int, g int, b int) C.COLORREF

fn C.DeleteObject(obj C.HGDIOBJ)

fn C.SelectObject(hdc C.HDC, h C.HGDIOBJ)

fn C.GetDC(hwnd C.HWND) C.HDC
fn C.ReleaseDC(hwnd C.HWND, hdc C.HDC)

fn C.InvalidateRect(hwnd C.HWND, rect &C.tagRECT, berase bool)

// Rectangle
struct C.tagRECT {
	left   f32
	top    f32
	right  f32
	bottom f32
}

struct C.tagSIZE {
	cx f32
	cy f32
}

fn win32_draw_text(hdc C.HDC, text string, x int, y int, cfg gx.TextCfg) {
	C.fix_text_bg(hdc)
	C.SetTextColor(hdc, C.RGB(cfg.color.r, cfg.color.g, cfg.color.b))
	hfont := C.iui_create_font(cfg.size)
	C.SelectObject(hdc, C.HGDIOBJ(hfont))

	// C.DrawText(hdc, text.to_wide(), -1, rect, 256)
	for i in 0 .. 256 {
		C.TextOut(hdc, x, y, text.to_wide(), text.len)
	}
	C.DeleteObject(C.HGDIOBJ(hfont))
	
	//hwnd := sapp.win32_get_hwnd()
	//C.InvalidateRect(hwnd, rect, C.TRUE)
}

fn win32_text_size(hdc C.HDC, text string) (f32, f32) {
	//size := C.my_text_size(hdc, text.to_wide(), text.len)
	//return size.cx, size.cy
	return 0, 0
}

[inline]
fn win_draw_text(x int, y int, text_ string, cfg gx.TextCfg) {
	hwnd := sapp.win32_get_hwnd()
	//hdc := sapp.win32_get_dc()
	hdc := C.GetDC(hwnd)
	
	win32_draw_text(hdc, text_, x, y, cfg)
	
	C.ReleaseDC(hwnd, hdc)
}*/
