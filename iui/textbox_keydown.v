module iui

import gg

fn (mut app Window) check_box(key gg.KeyCode, e &gg.Event, mut a Component) bool {
	if mut a is Textbox {
		app.key_down_1(key, e, mut a)
	}
	if mut a is TextField {
		app.runebox_key(key, e, mut a)
		return a.is_selected
	}
	if mut a is TextEdit {
		app.textedit_key_down(key, e, mut a)
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
	if mut a is VBox {
		for mut comm in a.children {
			if app.check_box(key, e, mut comm) {
				return true
			}
		}
	}
	if mut a is HBox {
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
	}
	app.key_down_event(app, key, e)
}

fn (mut win Window) textedit_key_down(key gg.KeyCode, ev &gg.Event, mut com TextEdit) {
	if !com.is_selected {
		return
	}
	if key == .right {
		com.carrot_left += 1
	} else if key == .left {
		com.carrot_left -= 1
	} else if key == .up {
		com.carrot_top -= 1
	} else if key == .down {
		com.carrot_top += 1
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
			line := com.lines[com.carrot_top]

			com.last_letter = 'backspace'
			mut bevnt := com.before_txtc_event_fn(win, *com)
			if bevnt {
				// 'true' indicates cancel event
				return
			}

			if com.carrot_left == 0 && com.carrot_top == 0 {
				return
			}

			if com.carrot_left - 1 >= 0 {
				new_line := line.substr(0, com.carrot_left - 1) +
					line.substr(com.carrot_left, line.len)
				com.lines[com.carrot_top] = new_line
				com.carrot_left -= 1
			} else {
				// EOL
				line_text := line
				com.delete_current_line()
				com.lines[com.carrot_top] = com.lines[com.carrot_top] + line_text
			}
		} else {
			mut strr := key.str()
			if key == .space {
				strr = ' '
			}
			if key == .enter {
				strr = '\n'
			}

			kc := u32(gg.KeyCode(ev.key_code))
			mut letter := ev.key_code.str()
			mut res := utf32_to_str(kc)

			if letter == 'left_shift' || letter == 'right_shift' {
				letter = ''
				win.shift_pressed = true
				return
			}

			if letter.starts_with('_') {
				letter = letter.replace('_', '')
				nums := [')', '!', '@', '#', '$', '%', '^', '&', '*', '(']
				if win.shift_pressed && letter.len > 0 {
					letter = nums[letter.u32()]
				}
			}

			if win.shift_pressed {
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

			mut bevnt := com.before_txtc_event_fn(win, *com)
			if bevnt {
				// 'true' indicates cancel event
				return
			}

			if key != .enter && mod != 2 {
				if com.lines.len == 0 {
					com.lines << ' '
					com.carrot_top = 0
				}

				line := com.lines[com.carrot_top]

				new_line := line.substr_ni(0, com.carrot_left) + strr +
					line.substr_ni(com.carrot_left, line.len)
				com.lines[com.carrot_top] = new_line
			}

			com.last_letter = letter
			com.text_change_event_fn(win, com)

			if key == .enter {
				current_line := com.lines[com.carrot_top]
				if com.carrot_left == current_line.len {
					com.carrot_top += 1
					com.lines.insert(com.carrot_top, '')
					if current_line.starts_with('\t') {
						com.lines[com.carrot_top] = '\t'
					}
				} else {
					keep_line := current_line.substr(0, com.carrot_left)
					new_line := current_line.substr_ni(com.carrot_left, current_line.len)

					com.lines[com.carrot_top] = keep_line

					com.carrot_top += 1
					com.lines.insert(com.carrot_top, '')
					com.lines[com.carrot_top] = new_line
					com.carrot_left = 0
				}
			} else if mod != 2 {
				com.carrot_left += 1
			}
		}
	}
}

fn get_shifted_letter(letter string) string {
	shift_keys := {
		'minus':         '_'
		'left_bracket':  '{'
		'right_bracket': '}'
		'equal':         '+'
		'apostrophe':    '"'
		'comma':         '>'
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
			if key == .enter {
				strr = '\n'
			}

			// if strr.len > 1 {
			kc := u32(gg.KeyCode(ev.key_code))
			mut letter := ev.key_code.str()
			res := utf32_to_str(kc)

			//}
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

			bevnt := com.before_txtc_event_fn(app, *com)
			if bevnt || key == .up || key == .down {
				// 'true' indicates cancel event
				return
			}

			if mod != 2 && key != .enter {
				com.text = com.text.substr_ni(0, com.carrot_left) + strr +
					com.text.substr_ni(com.carrot_left, com.text.len)

				com.carrot_left += 1
			}

			com.last_letter = letter
			com.text_change_event_fn(app, com)

			return
		}
		com.ctrl_down = true
	}
}

fn (mut app Window) key_down_1(key gg.KeyCode, e &gg.Event, mut a Textbox) {
	if a.is_selected {
		mod := e.modifiers
		if mod == 8 {
			// Windows Key
			return
		}
		if mod == 2 {
			a.ctrl_down = true
		}
		a.key_down = true
		kc := u32(gg.KeyCode(e.key_code))
		mut letter := e.key_code.str()
		mut res := utf32_to_str(kc)
		if letter == 'space' {
			letter = ' '
		}
		if letter == 'enter' {
			if a.multiline {
				letter = '\n'
			} else {
				letter = ''
			}
		}
		if letter == 'left_shift' || letter == 'right_shift' {
			letter = ''
			app.shift_pressed = true
			return
		}
		if letter.starts_with('_') {
			letter = letter.replace('_', '')
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

		if letter == 'left' {
			a.carrot_left--
			a.key_down = false
			return
		}
		if letter == 'right' {
			a.carrot_left++
			a.key_down = false
			return
		}
		if letter == 'down' {
			a.carrot_top++
			a.key_down = false
			return
		}
		if letter == 'up' {
			a.carrot_top--
			a.key_down = false
			return
		}

		a.last_letter = letter
		mut bevnt := a.before_txtc_event_fn(app, *a)
		if bevnt {
			// 'true' indicates cancel event
			return
		}

		mut spl := a.text.split_into_lines()
		if spl.len == 0 && letter == 'backspace' {
			a.text = ''
			return
		}
		if letter == 'backspace' {
			if spl.len == 0 {
				// No Text
				return
			}
			if a.carrot_top >= spl.len && spl.len > 0 {
				a.carrot_top--
			}
			if a.carrot_top < 0 {
				a.carrot_top = 0
			}
			mut lie := spl[a.carrot_top]
			if lie.len == 0 {
				spl.pop()
				a.carrot_top = spl.len - 1
				a.text = spl.join('\n')

				// return
			}

			if a.carrot_left - 1 > 0 {
				if a.carrot_left != lie.len {
					lie = lie.substr_ni(0, a.carrot_left - 1) +
						lie.substr_ni(a.carrot_left, lie.len)
				} else {
					lie = lie.substr_ni(0, a.carrot_left - 1)
				}
			} else {
				lie = '_TO_REMOVE_LIE_' + lie
			}
			spl[a.carrot_top] = lie

			mut nt := ''
			for mut str in spl {
				if nt.len == 0 {
					if str.starts_with('_TO_REMOVE_LIE_') {
						if str.len > '_TO_REMOVE_LIE_'.len {
							nt = nt + str.replace('_TO_REMOVE_LIE_', '')
							nt = nt.substr_ni(1, nt.len - 1)
						}
					} else {
						nt = nt + str
					}
				} else {
					if str.starts_with('_TO_REMOVE_LIE_') {
						if str.len > '_TO_REMOVE_LIE_'.len {
							nt = nt + str.replace('_TO_REMOVE_LIE_', '')
						}
					} else {
						nt = nt + '\n' + str
					}
				}
			}
			a.text = nt
			a.carrot_left--
			if a.carrot_top >= spl.len && spl.len > 0 {
				a.carrot_top = spl.len - 1
			}
		} else if mod != 2 {
			if app.shift_pressed && letter.len > 0 {
				letter = letter.to_upper()
			}
			if letter.len > 1 {
				if letter == 'tab' {
					letter = ' '.repeat(4)
				} else {
					letter = res
				}
			}

			if spl.len == 0 {
				spl = a.text.split('\n')
			}
			if a.carrot_top < 0 {
				a.carrot_top = 0
			}
			mut lie := spl[a.carrot_top]
			lie = lie.substr_ni(0, a.carrot_left) + letter + lie.substr_ni(a.carrot_left, lie.len)
			spl[a.carrot_top] = lie

			mut nt := ''
			for mut str in spl {
				if nt.len == 0 {
					nt = nt + str
				} else {
					nt = nt + '\n' + str
				}
			}
			a.text = nt
			if letter.len >= 4 {
				a.carrot_left += letter.len - 1
			}
			a.carrot_left++
		}
		a.last_letter = letter
		a.text_change_event_fn(app, *a)
		if letter == '\n' && (a.carrot_top + 1) == spl.len {
			a.text = a.text + '\n'
		}
		a.key_down = false
		a.ctrl_down = false
	}
}
