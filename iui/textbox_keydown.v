module iui

import gg

fn (mut app Window) key_down(key gg.KeyCode, e &gg.Event) {
	// global keys
	match key {
		.left_alt {
			// app.show_menu_bar = !app.show_menu_bar
			return
		}
		.left_control {
			// TODO: Copy & Paste, Undo & Redo
			return
		}
		else {}
	}
	for mut a in app.components {
		if mut a is Textbox {
			app.key_down_1(key, e, mut a)
		}
		if mut a is Runebox {
			app.runebox_key(key, e, mut a)
		}
		if mut a is TextEdit {
			app.textedit_key_down(key, e, mut a)
		}
		if mut a is Tabbox {
			mut kids := a.kids[a.active_tab]
			for mut comm in kids {
				if mut comm is Textbox {
					app.key_down_1(key, e, mut comm)
				}
				if mut comm is Runebox {
					app.runebox_key(key, e, mut comm)
				}
				if mut comm is TextEdit {
					app.textedit_key_down(key, e, mut comm)
				}
			}
		}
		if mut a is Modal {
			for mut child in a.children {
				if mut child is Textbox {
					app.key_down_1(key, e, mut child)
				}
				if mut child is Runebox {
					app.runebox_key(key, e, mut child)
				}
				if mut child is TextEdit {
					app.textedit_key_down(key, e, mut child)
				}
				if mut child is Tabbox {
					mut active := child.kids[child.active_tab]
					for _, mut kid in active {
						if mut kid is Textbox {
							app.key_down_1(key, e, mut kid)
						}
						if mut kid is Runebox {
							app.runebox_key(key, e, mut kid)
						}
						if mut kid is TextEdit {
							app.textedit_key_down(key, e, mut kid)
						}
					}
				}
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

			if win.shift_pressed && letter in shift_keys {
				letter = shift_keys[letter]
			}

			if win.shift_pressed && letter.len > 0 {
				letter = letter.to_upper()
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

fn (mut app Window) runebox_key(key gg.KeyCode, ev &gg.Event, mut com Runebox) {
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
			com.text = com.text.substr_ni(0, com.carrot_index - 1) +
				com.text.substr_ni(com.carrot_index, com.text.len)
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
			mut res := utf32_to_str(kc)

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
			if letter == 'left_bracket' && app.shift_pressed {
				letter = '{'
			}
			if letter == 'right_bracket' && app.shift_pressed {
				letter = '}'
			}
			if letter == 'equal' && app.shift_pressed {
				letter = '+'
			}
			if letter == 'apostrophe' && app.shift_pressed {
				letter = '"'
			}
			if letter == 'comma' && app.shift_pressed {
				letter = '<'
			}
			if letter == 'period' && app.shift_pressed {
				letter = '>'
			}
			if letter == 'slash' && app.shift_pressed {
				letter = '?'
			}

			if letter == 'semicolon' && app.shift_pressed {
				letter = ':'
			}
			if letter == 'backslash' && app.shift_pressed {
				letter = '|'
			}

			if letter == 'grave_accent' && app.shift_pressed {
				letter = '~'
			}

			if app.shift_pressed && letter.len > 0 {
				letter = letter.to_upper()
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

			mut bevnt := com.before_txtc_event_fn(app, *com)
			if bevnt {
				// 'true' indicates cancel event
				return
			}

			if mod != 2 {
				com.text = com.text.substr_ni(0, com.carrot_index) + strr +
					com.text.substr_ni(com.carrot_index, com.text.len)

				if key == .enter {
					com.carrot_top += 1
				} else {
					com.carrot_left += 1
				}
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
		if letter == 'left_bracket' && app.shift_pressed {
			letter = '{'
		}
		if letter == 'right_bracket' && app.shift_pressed {
			letter = '}'
		}
		if letter == 'equal' && app.shift_pressed {
			letter = '+'
		}
		if letter == 'apostrophe' && app.shift_pressed {
			letter = '"'
		}
		if letter == 'comma' && app.shift_pressed {
			letter = '<'
		}
		if letter == 'period' && app.shift_pressed {
			letter = '>'
		}
		if letter == 'slash' && app.shift_pressed {
			letter = '?'
		}

		if letter == 'semicolon' && app.shift_pressed {
			letter = ':'
		}
		if letter == 'backslash' && app.shift_pressed {
			letter = '|'
		}

		if letter == 'grave_accent' && app.shift_pressed {
			letter = '~'
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
