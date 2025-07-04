module dialogs

import os

#include "@VMODROOT/src/extra/dialogs/tinyfiledialogs.h"
#flag -I @VMODROOT/src/extra/dialogs/commdlg.h
#flag -I @VMODROOT/src/extra/dialogs/
#flag @VMODROOT/src/extra/dialogs/tinyfiledialogs.c

#include "@VMODROOT/src/extra/dialogs/commdlg.h"

/*
#include "@VMODROOT/src/extra/dialogs/dialogs_win.h"
#include "@VMODROOT/src/extra/dialogs/dialogs_win.c"

fn C.win_open_file_dialog(a &char) &char

#flag windows -lole32
#flag windows -lcomdlg32

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

fn cstr(the_string string) &char {
	return &char(the_string.str)
}
*/

fn C.tinyfd_openFileDialog(a &char, b &char, c &char, d &char, e &char, f &char) &char

fn C.tinyfd_saveFileDialog(a &char, b &char, c &char, d &char, e &char) &char

fn C.tinyfd_selectFolderDialog(a &char, b &char) &char

fn C.tinyfd_colorChooser(a &char, b &char, c &char, d &char) &char

fn C.colorer() &char

pub fn color_picker() string {
	temp := C.colorer()

	if temp == &char(0) {
		return ''
	}
	val := unsafe { temp.vstring() }

	return val
}

fn cstr(the_string string) &char {
	return &char(the_string.str)
}

pub fn open_dialog(title string) string {
	temp := unsafe {
		C.tinyfd_openFileDialog(cstr(title), cstr(''), 0, cstr(''), cstr(''), cstr(''))
	}
	if temp != &char(0) {
		return unsafe { temp.vstring() }
	} else {
		return ''
	}
}

pub fn save_dialog(title string) string {
	temp := unsafe { C.tinyfd_saveFileDialog(cstr(title), cstr(''), 0, C.NULL, cstr('')) }
	if temp != &char(0) {
		return unsafe { temp.vstring() }
	}
	return ''
}

pub fn select_folder_dialog(title string, current string) string {
	temp := C.tinyfd_selectFolderDialog(cstr(title), cstr(os.real_path(current)))
	if temp != &char(0) {
		return unsafe { temp.vstring() }
	}
	return ''
}
