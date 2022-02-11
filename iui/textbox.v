module iui

import gg
import gx
import time

// Textbox - implements Component interface
struct Textbox {
	Component_A
pub mut:
	app                  &Window
	text                 string
	click_event_fn       fn (mut Window, Textbox)
	before_txtc_event_fn fn (mut Window, Textbox) bool
	text_change_event_fn fn (mut Window, Textbox)
	is_blink             bool
	last_blink           f64
	wrap                 bool = true
	last_fit             int  = 1
	code_highlight       bool
	code_high_str        bool
	multiline            bool = true
	ctrl_down            bool
	last_letter          string

	carrot_left int
	carrot_top  int
	key_down    bool
	padding_x   int
}

pub fn (mut com Textbox) set_codebox(val bool) {
	com.code_highlight = val
}

fn (mut app Window) key_down(key gg.KeyCode, e &gg.Event) {
	// global keys
	match key {
		.escape {
			app.gg.quit()
		}
		.left_alt {
			app.show_menu_bar = !app.show_menu_bar
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
		if mut a is Tabbox {
			for _, mut val in a.kids {
				for mut comm in val {
					if mut comm is Textbox {
						app.key_down_1(key, e, mut comm)
					}
				}
			}
		}
		if mut a is Modal {
			for mut child in a.children {
				if mut child is Textbox {
					app.key_down_1(key, e, mut child)
				}
			}
		}
	}
}

fn (mut app Window) key_down_1(key gg.KeyCode, e &gg.Event, mut a Textbox) {
	// for mut a in app.components {
	//	if mut a is Textbox {
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
		// if letter == 'tab' {
		//	letter = ' '.repeat(8)
		//}
		if letter == 'semicolon' && app.shift_pressed {
			letter = ':'
		}
		if letter == 'backslash' && app.shift_pressed {
			letter = '|'
		}
		// println(letter)
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

pub fn textbox(app &Window, text string) &Textbox {
	return &Textbox{
		text: text
		app: app
		click_event_fn: fn (mut win Window, a Textbox) {}
		text_change_event_fn: fn (mut win Window, a Textbox) {}
		before_txtc_event_fn: fn (mut win Window, a Textbox) bool {
			return false
		}
	}
}

pub fn (mut com Textbox) set_click(b fn (mut Window, Textbox)) {
	com.click_event_fn = b
}

pub fn (mut com Textbox) set_text_change(b fn (mut Window, Textbox)) {
	com.text_change_event_fn = b
}

pub fn (mut com Textbox) draw() {
	if com.text.contains('\t') {
		// gg currently does not render tabs correctly.
		// possible font issue?
		com.text = com.text.replace('\t', ' '.repeat(4))
	}

	mut spl := com.text.split_into_lines()
	mut y_mult := 0
	size := com.app.font_size
	mut padding_x := 4
	padding_y := 4
	if com.carrot_top >= spl.len {
		com.carrot_top--
	}

	// mut app := com.app
	mut bg := com.app.theme.textbox_background
	mut border := com.app.theme.textbox_border

	mut mid := (com.x + (com.width / 2))
	mut midy := (com.y + (com.height / 2))

	// Detect Hover
	if (abs(mid - com.app.mouse_x) < (com.width / 2))
		&& (abs(midy - com.app.mouse_y) < (com.height / 2)) {
		border = com.app.theme.button_border_hover
	}

	line_height := text_height(com.app, 'A{')

	// Detect Click
	if com.is_mouse_rele {
		com.is_selected = true
		com.click_event_fn(com.app, *com)

		bg = com.app.theme.button_bg_click
		border = com.app.theme.button_border_click

		mut my := com.app.mouse_y - com.y
		mut mx := com.app.mouse_x - com.x

		lw := text_width(com.app, 'A')
		click := com.scroll_i + (my / line_height)

		if click < spl.len {
			com.carrot_top = click
			com.carrot_left = mx / lw
		}

		com.is_mouse_rele = false
	} else {
		if com.app.click_x > -1 && !(abs(mid - com.app.mouse_x) < (com.width / 2)
			&& abs(midy - com.app.mouse_y) < (com.height / 2)) {
			com.is_selected = false
		}
	}

	if com.is_selected {
		border = com.app.theme.button_border_click
	}

	com.app.draw_bordered_rect(com.x, com.y, com.width, com.height, 2, bg, border)

	mut cl := 0
	if com.scroll_i > spl.len - com.last_fit {
		com.scroll_i = spl.len - com.last_fit
	}
	if com.scroll_i < 0 {
		com.scroll_i = 0
	}
	if com.code_highlight {
		padding_x += text_width(com.app, '1000')
		com.app.draw_bordered_rect(com.x + 1, com.y + 1, padding_x - 3, com.height - 2,
			2, com.app.theme.button_bg_normal, com.app.theme.button_bg_normal)
	}

	for i := com.scroll_i; i < spl.len; i++ {
		mut txt := spl[i]
		mut skip := false

		if y_mult + line_height > com.height {
			com.last_fit = cl
			y_mult = y_mult - line_height
			skip = true
		} else if com.wrap {
			mut wspl := txt.split(' ')
			mut wmul := 0

			for mut wtxt in wspl {
				if padding_x + wmul > com.width {
					y_mult += com.app.gg.text_height(wtxt)
					wmul = 0
				}

				com.app.gg.draw_text(com.x + wmul + padding_x, com.y + y_mult + padding_y,
					wtxt, gx.TextCfg{
					size: size
					color: com.text_color(wtxt)
				})

				wmul += text_width(com.app, wtxt + ' ')
			}
		}

		if com.code_highlight && !skip {
			com.app.gg.draw_text(com.x + 4, com.y + y_mult + padding_y, (i + 1).str(),
				gx.TextCfg{
				size: size
				color: com.app.theme.text_color
			})
		}

		if !skip {
			if cl < spl.len - 1 {
				y_mult += line_height
			}
			if y_mult < com.height {
				cl++
			} else {
				cl--
			}
		} else {
			break
		}
	}
	com.padding_x = padding_x

	com.draw_scrollbar(cl, spl.len)
	com.draw_carrot(spl, padding_x, padding_y, line_height, size)
}

fn (mut com Textbox) draw_scrollbar(cl int, spl_len int) {
	// Calculate postion for scroll
	mut sth := int((f32((com.scroll_i)) / f32(spl_len)) * com.height)
	mut enh := int((f32(cl) / f32(spl_len)) * com.height)
	mut requires_scrollbar := ((com.height - enh) > 0) && com.multiline

	// Draw Scroll
	if requires_scrollbar {
		com.app.draw_bordered_rect(com.x + com.width - 11, com.y + 1, 10, com.height - 2,
			2, com.app.theme.scroll_track_color, com.app.theme.button_bg_hover)
		com.app.draw_bordered_rect(com.x + com.width - 11, com.y + sth + 1, 10, enh - 2,
			2, com.app.theme.scroll_bar_color, com.app.theme.scroll_track_color)
	}
}

pub fn (mut com Textbox) draw_carrot(spl []string, padding_x int, padding_y int, line_height int, size int) {
	// Blinking text cursor
	mut now := time.ticks()

	if now - com.last_blink >= 1000 {
		com.is_blink = !com.is_blink
		com.last_blink = now
	}

	mut color := com.app.theme.text_color
	if com.is_blink {
		mut r := ((com.app.theme.text_color.r / 2) + com.app.theme.background.r) / 2
		color = gx.rgb(r, r, r)
	}

	mut indx := com.carrot_top + 1

	mut mtxt := ''

	if spl.len <= 1 {
		if spl.len == 0 {
			mtxt = ''
		} else {
			mtxt = spl[0]
		}
	} else if (indx - 1) < spl.len {
		mtxt = spl[indx - 1]
	}

	mut lt := line_height * (com.carrot_top) - (line_height * com.scroll_i)

	if com.carrot_left > mtxt.len && indx <= spl.len {
		indx++
		if !(indx - 1 >= spl.len) {
			mtxt = spl[indx - 1]
			com.carrot_top++
			lt += line_height
			com.carrot_left = 0
		} else {
			com.carrot_left--
		}
	}

	if com.carrot_left < 0 && indx > 1 {
		indx--
		mtxt = spl[indx - 1]
		com.carrot_top--
		lt -= line_height
		com.carrot_left = 0
	}
	if indx < 0 {
		indx = 0
	}
	if com.carrot_left < 0 {
		com.carrot_left = 0
	}

	mut tw := mtxt.substr_ni(0, com.carrot_left)

	mut lw := 0
	for atxt in tw.split(' ') {
		lw += text_width(com.app, atxt + ' ')
	}

	lw = (lw - text_width(com.app, ' ')) + (padding_x - 4)

	if lw == 0 || lw == (padding_x - 4) {
		lw = padding_x - 4
	}

	if lt < 0 {
		return
	}
	com.app.gg.draw_text(com.x + lw, com.y + lt + padding_y, '|', gx.TextCfg{
		size: size
		color: color
	})
}

const (
	code_blue  = gx.rgb(90, 150, 230)
	code_num   = gx.rgb(240, 200, 0)
	code_str   = gx.rgb(200, 100, 0)
	code_pur   = gx.rgb(200, 100, 200)

	blue_words = ['mut', 'pub', 'fn', 'true', 'false', 'import', 'module', 'struct']
	pur_words  = ['if', 'return', 'else', 'for']
)

pub fn (mut com Textbox) text_color(word string) gx.Color {
	if !com.code_highlight {
		return com.app.theme.text_color
	}

	// mut ch := false
	/*
	if word.contains("'") && com.code_high_str {
		println('end: ' + word)
		com.code_high_str = false
		ch = true
	}

	if word.contains("'") && !ch {
		println(word)
		com.code_high_str = true
	}*/
	if word.contains("('") || word.contains("')") {
		com.code_high_str = !com.code_high_str
	}

	if word in iui.blue_words {
		return iui.code_blue
	}
	if word in iui.pur_words {
		return iui.code_pur
	}

	num := word.int()
	if num == 0 && word != '0' {
		// todo
		// if com.code_high_str {
		//	return code_str
		//}
		return com.app.theme.text_color
	} else {
		return iui.code_num
	}
}
