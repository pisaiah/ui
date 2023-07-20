module iui

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
