module dialogs

#flag -I @VMODROOT/dialogs/commdlg.h
#flag -I @VMODROOT/dialogs/

#include "@VMODROOT/dialogs/commdlg.h"
#include "@VMODROOT/dialogs/dialogs_win.h"
#include "@VMODROOT/dialogs/dialogs_win.c"

#flag windows -lole32
#flag windows -lcomdlg32

fn C.win_open_dialogs(a &char) &char

// Windows
pub fn open_dialog(title string) string {
	temp := unsafe {
		C.win_open_dialogs(cstr(title))
	}
	dump(temp)

	if temp != &char(0) {
		return unsafe { temp.vstring() }
	} else {
		return ''
	}
}
