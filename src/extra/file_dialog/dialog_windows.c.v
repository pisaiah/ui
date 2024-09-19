module file_dialog

import os

#flag -I @VMODROOT/src/extra/file_dialog/commdlg.h
#flag -I @VMODROOT/src/extra/file_dialog/

#include "@VMODROOT/src/extra/file_dialog/commdlg.h"
#include "@VMODROOT/src/extra/file_dialog/dialogs_win.h"
#include "@VMODROOT/src/extra/file_dialog/dialogs_win.c"

#flag windows -lole32
#flag windows -lcomdlg32

fn C.win_open_file_dialog(a &char) &char

// Windows
pub fn open_dialog(title string) string {
	temp := unsafe {
		C.win_open_file_dialog(cstr(title))
	}
	dump(temp)
	
	if temp != &char(0) {
		return unsafe { temp.vstring() }
	} else {
		return ''
	}
}