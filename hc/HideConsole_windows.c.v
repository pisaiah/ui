// Console Hider - Public Domain
module hc

#include "windows.h"
#include "winuser.h"
#flag -luser32

pub fn hide_console_win() {
	$if gcc {
		mut t := C.GetConsoleWindow()
		C.ShowWindow(t, 0)
	}
}

// user32.dll
fn C.GetConsoleWindow() C.HWND
fn C.ShowWindow(C.HWND, int)
