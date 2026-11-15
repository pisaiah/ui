module iui

import gg
import sokol.sgl
import sokol.gfx

#flag -I @VMODROOT/extra/
#include "@VMODROOT/extra/winstuff.c"
#include "@VMODROOT/extra/sokol_patch.c"
#flag -lntdll
#flag -lwinmm

@[typedef]
pub struct C.COLORREF {
}

pub fn C.RGB(r u8, g u8, b u8) C.COLORREF

pub fn C.i_set_fps(val int)

pub fn C.i_set_power_save(val bool)

pub fn C.i_refresh_ui()

pub fn i_refresh_ui() {
	C.i_refresh_ui()
}

// Set Window FPS
pub fn set_window_fps(val int) {
	C.i_set_fps(val)
}

// Set Power Save
pub fn set_power_save(val bool) {
	C.i_set_power_save(val)
}

pub fn winc(co gg.Color) C.COLORREF {
	return C.RGB(co.r, co.g, co.b)
}

fn C.i_txt_pix(lpchtext &u16, le int, fs int, w &int, h &int, tc C.COLORREF) &u8
