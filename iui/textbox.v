module iui

import gg
import gx
import time
import math
import os

// Textbox - implements Component interface
struct Textbox {
pub mut:
	app            &Window
	text           string
	x              int
	y              int
	width          int
	height         int
	last_click     f64
	click_event_fn fn (mut Window, Textbox)
	is_blink       bool
	last_blink     f64
	wrap           bool = true
	is_selected    bool
	carrot_index   int = 1
	z_index        int
	scroll_i       int
    last_fit       int = 1
}

fn (mut app Window) key_down(key gg.KeyCode, e &gg.Event) {
	// global keys
	match key {
		.escape {
			app.gg.quit()
		}
		.left_alt {
			app.show_menu_bar = !app.show_menu_bar
		}
		else {}
	}
	for mut a in app.components {
		if a is Textbox {
			if a.is_selected {
				kc := u32(gg.KeyCode(e.key_code))
				mut letter := e.key_code.str()
				mut res := utf32_to_str(kc)
				if letter == 'space' {
					letter = ' '
				}
				if letter == 'enter' {
					letter = '\n'
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
				if letter == 'tab' {
					letter = '	'
				}
				if letter == 'semicolon' && app.shift_pressed {
					letter = ':'
				}
				if letter == 'backslash' && app.shift_pressed {
					letter = '|'
				}
				if letter == 'left' {
					a.carrot_index--
					return
				}
				if letter == 'right' {
					a.carrot_index++
					return
				}

				if letter == 'backspace' {
					if a.text.len > 0 {
						a.text = a.text.substr(0, a.text.len - 1)
					}
				} else {
					if app.shift_pressed && letter.len > 0 {
						letter = letter.to_upper()
					}
					if letter.len > 1 {
						letter = res
					}
					a.text = a.text + letter
				}
			}
		}
	}
}

pub fn textbox(app &Window, text string) Textbox {
	return Textbox{
		text: text
		app: app
		click_event_fn: blank_event_tbox
	}
}

pub fn (mut com Textbox) set_click(b fn (mut Window, Textbox)) {
	com.click_event_fn = b
}

pub fn blank_event_tbox(mut win Window, a Textbox) {
}

pub fn (mut com Textbox) draw() {
	mut spl := com.text.split('\n')
	mut y_mult := 0
	size := 14
	padding := 4

	mut app := com.app
	mut bg := app.theme.textbox_background
	mut border := app.theme.textbox_border

	mut mid := (com.x + (com.width / 2))
	mut midy := (com.y + (com.height / 2))

	// Detect Hover
	if (math.abs(mid - app.mouse_x) < (com.width / 2))
		&& (math.abs(midy - app.mouse_y) < (com.height / 2)) {
		border = app.theme.button_border_hover
	}

	// Detect Click
	if (math.abs(mid - app.click_x) < (com.width / 2))
		&& (math.abs(midy - app.click_y) < (com.height / 2)) {
		now := time.now().unix_time_milli()

		if now - com.last_click > 100 && !com.is_selected {
			com.is_selected = true
			com.click_event_fn(app, *com)

			bg = app.theme.button_bg_click
			border = app.theme.button_border_click
			com.last_click = time.now().unix_time_milli()
		}
	} else {
		if app.click_x > -1 {
			com.is_selected = false
		}
	}

	if com.is_selected {
		border = app.theme.button_border_click
	}

	com.app.draw_bordered_rect(com.x, com.y, com.width, com.height, 2, bg, border)

	mut cl := 0
    if com.scroll_i > spl.len - com.last_fit {
        com.scroll_i = spl.len - com.last_fit
    }
    if com.scroll_i < 0 {
        com.scroll_i = 0
    }

    mut last_ym := 0
	space_width := text_width(com.app, ' ')

	for i := com.scroll_i; i < spl.len; i++ {
		mut txt := spl[i]
		txt = txt.replace('\t', '        ')
        mut skip := false

		if y_mult + (text_height(com.app, txt)*2) > com.height {
            com.last_fit = cl
            y_mult = y_mult - last_ym
            skip = true
		} else if com.wrap {
			mut wspl := txt.split(' ')
			mut wmul := 0
			for mut wtxt in wspl {
				if padding + wmul > com.width {
					y_mult += com.app.gg.text_height(wtxt)
					wmul = 0
				}
				com.app.gg.draw_text(com.x + padding + wmul, com.y + y_mult + padding, wtxt, gx.TextCfg{
					size: size
					color: com.app.theme.text_color
					max_width: 20
				})
				wmul += text_width(com.app, wtxt) + 1
			} 
		}

        if !skip {
            if cl < spl.len - 1 {
                last_ym = (com.app.gg.text_height(txt) + com.app.gg.text_height(spl[0])) / 2
                y_mult += last_ym
            }
            cl++
        } else {
            break
        }
	}

    // Calculate postion for scroll
    mut sth := int( (f32((com.scroll_i)) / f32(spl.len)) * com.height)
    mut enh := int( (f32(cl) / f32(spl.len)) * com.height)
    mut requires_scrollbar := (com.height - enh) > 0

    // Draw Scroll
    if requires_scrollbar {
        com.app.draw_bordered_rect(com.x + com.width - 11, com.y + 1, 10, com.height-2, 2, com.app.theme.scroll_track_color, com.app.theme.button_bg_hover)
        com.app.draw_bordered_rect(com.x + com.width - 11, com.y + sth + 1, 10, enh - 2, 2, com.app.theme.scroll_bar_color, com.app.theme.scroll_track_color)
    }

    // Blinking text cursor
	mut now := time.now().unix_time_milli()
	if now - com.last_blink > 1000 {
		com.is_blink = !com.is_blink
		com.last_blink = now
	}
	if com.is_blink {
		mut lw := text_width(com.app, spl[spl.len - 1]) - 1 //(aaa * com.carrot_index)
		com.app.gg.draw_text(com.x + lw + padding, com.y + y_mult + padding, '|', gx.TextCfg{
			size: size
			color: com.app.theme.text_color
		})
	}
}
