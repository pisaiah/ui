module iui

import gg

const (
	numbers_val = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.']
)

fn (mut app Window) check_box(key gg.KeyCode, e &gg.Event, mut a Component) bool {
	if mut a is TextField {
		app.runebox_key(key, e, mut a)
		return a.is_selected
	}
	if mut a is TextArea {
		app.textarea_key_down(key, e, mut a)
		return true
	}
	if mut a is Tabbox {
		mut kids := a.kids[a.active_tab]
		for mut comm in kids {
			app.check_box(key, e, mut comm)
		}
	}
	if mut a is VBox || mut a is HBox || mut a is Titlebox {
		for mut comm in a.children {
			if app.check_box(key, e, mut comm) {
				return true
			}
		}
	}
	if mut a is ScrollView {
		for mut comm in a.children {
			if app.check_box(key, e, mut comm) {
				return true
			}
		}
	}
	return false
}

fn (mut app Window) key_down(key gg.KeyCode, e &gg.Event) {
	// global keys
	match key {
		.left_alt {
			app.debug_draw = !app.debug_draw
			return
		}
		.left_control {
			// TODO: Copy & Paste, Undo & Redo
			return
		}
		else {}
	}
	for mut a in app.components {
		app.check_box(key, e, mut a)

		if mut a is Modal {
			for mut child in a.children {
				app.check_box(key, e, mut child)
			}
		}
		if mut a is Page {
			for mut child in a.children {
				app.check_box(key, e, mut child)
			}
			return
		}
	}
	app.key_down_event(mut app, key, e)
}

fn get_shifted_letter(letter string) string {
	shift_keys := {
		'minus':         '_'
		'left_bracket':  '{'
		'right_bracket': '}'
		'equal':         '+'
		'apostrophe':    '"'
		'comma':         '<'
		'period':        '>'
		'slash':         '?'
		'semicolon':     ':'
		'backslash':     '|'
		'grave_accent':  '~'
	}
	if letter in shift_keys {
		return shift_keys[letter]
	}
	return letter.to_upper()
}

fn (mut app Window) runebox_key(key gg.KeyCode, ev &gg.Event, mut com TextField) {
	if !com.is_selected {
		return
	}
	if key == .right {
		com.carrot_left += 1
	} else if key == .left {
		com.carrot_left -= 1
	} else {
		mod := ev.modifiers
		if mod == 8 {
			// Windows Key
			return
		}
		if mod == 2 {
			com.ctrl_down = true
		}
		if key == .backspace {
			com.text = com.text.substr_ni(0, com.carrot_left - 1) +
				com.text.substr_ni(com.carrot_left, com.text.len)
			com.carrot_left -= 1
		} else {
			mut strr := key.str()
			if key == .space {
				strr = ' '
			}
			enter := is_enter(key)
			if enter {
				strr = '\n'
			}

			kc := u32(gg.KeyCode(ev.key_code))
			mut letter := ev.key_code.str()
			res := utf32_to_str(kc)

			if letter == 'left_shift' || letter == 'right_shift' {
				letter = ''
				app.shift_pressed = true
				return
			}

			if letter.starts_with('_') {
				letter = letter.replace('_', '')
				nums := [')', '!', '@', '#', '$', '%', '^', '&', '*', '(']
				if app.shift_pressed && letter.len > 0 {
					letter = nums[letter.u32()]
				}
			}
			if letter == 'minus' {
				if app.shift_pressed {
					letter = '_'
				} else {
					letter = '-'
				}
			}

			if app.shift_pressed {
				letter = get_shifted_letter(letter)
			}

			com.last_letter = letter

			if letter.len > 1 {
				if letter == 'tab' {
					letter = '\t'
				} else {
					letter = res
				}
			}
			if strr != '\n' {
				strr = letter
			}

			bevnt := com.before_txtc_event_fn(mut app, *com)
			if bevnt || key == .up || key == .down {
				// 'true' indicates cancel event
				return
			}

			if mod != 2 && !enter {
				if com.numeric {
					if strr !in iui.numbers_val {
						com.last_letter = letter
						com.text_change_event_fn(app, com)
						return
					}
				}

				com.text = com.text.substr_ni(0, com.carrot_left) + strr +
					com.text.substr_ni(com.carrot_left, com.text.len)

				com.carrot_left += 1
			}

			if enter {
				com.last_letter = 'enter'
			} else {
				com.last_letter = letter
			}
			com.text_change_event_fn(app, com)

			return
		}
		com.ctrl_down = true
	}
}
