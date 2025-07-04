module dialogs

import os

#flag -I @VMODROOT/dialogs/

#include "@VMODROOT/dialogs/dialogs_lin.c"

fn C.linux_open_dialogs(a &char) &char

// Windows
pub fn open_dialog(title string) string {
	temp := unsafe {
		C.linux_open_dialogs(cstr(title))
	}
	dump(temp)

	if temp != &char(0) {
		return unsafe { temp.vstring() }
	} else {
		return ''
	}
}
