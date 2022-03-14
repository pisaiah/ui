module iui

import gx
import math

//
// Runebox Component
// --------------------
// Textbox replacement that draws by runes
//
struct Runebox {
	Component_A
pub mut:
	win                  &Window
	carrot_top           int
	carrot_left          int
	carrot_index         int
	multiline            bool = true
	ctrl_down            bool
	code_highlight       &SyntaxHighlighter
	last_letter          string
	click_event_fn       fn (voidptr, voidptr)
	before_txtc_event_fn fn (mut Window, Runebox) bool
	text_change_event_fn fn (voidptr, voidptr)
	padding_x            int
}

pub fn runebox(mut win Window, text string) &Runebox {
	return &Runebox{
		win: win
		text: text
		code_highlight: syntax_highlight_for_v()
		click_event_fn: fn (a voidptr, b voidptr) {}
		before_txtc_event_fn: fn (mut a Window, b Runebox) bool {
			return false
		}
		text_change_event_fn: fn (a voidptr, b voidptr) {}
	}
}

fn (mut this Runebox) draw_background() {
	mut bg := this.win.theme.textbox_background
	mut border := this.win.theme.textbox_border

	mut mid := (this.x + (this.width / 2))
	mut midy := (this.y + (this.height / 2))

	// Detect Click
	if this.is_mouse_rele {
		this.is_selected = true
		this.click_event_fn(this.win, this)

		bg = this.win.theme.button_bg_click
		border = this.win.theme.button_border_click

		this.is_mouse_rele = false
	} else {
		if this.win.click_x > -1 && !(abs(mid - this.win.mouse_x) < (this.width / 2)
			&& abs(midy - this.win.mouse_y) < (this.height / 2)) {
			this.is_selected = false
		}
	}
	this.win.draw_filled_rect(this.x, this.y, this.width, this.height, 2, bg, border)
	this.draw_line_number_background()
}

fn (com &Runebox) draw_scrollbar(cl int, spl_len int) {
	// Calculate postion for scroll
	mut scroll_line := 0
	if com.scroll_i > 0 {
		scroll_line = com.scroll_i
	}

	mut sth := int((f32(scroll_line) / f32(spl_len)) * com.height)
	mut enh := int((f32(cl) / f32(spl_len)) * com.height)
	mut requires_scrollbar := ((com.height - enh) > 0) //&& com.multiline

	// Draw Scroll
	if requires_scrollbar {
		com.win.draw_bordered_rect(com.x + com.width - 11, com.y + 1, 10, com.height - 2,
			2, com.win.theme.scroll_track_color, com.win.theme.button_bg_hover)
		com.win.draw_bordered_rect(com.x + com.width - 11, com.y + sth + 1, 10, enh - 2,
			2, com.win.theme.scroll_bar_color, com.win.theme.scroll_track_color)
	}
}

fn (this &Runebox) draw_line_number_background() int {
	if this.code_highlight != 0 {
		padding_x := text_width(this.win, '9000')
		this.win.draw_bordered_rect(this.x + 1, this.y + 1, padding_x - 3, this.height - 2,
			2, this.win.theme.button_bg_normal, this.win.theme.button_bg_normal)
		return padding_x + 4
	}
	return 4
}

fn (mut this Runebox) draw() {
	runes := this.text.runes()

	mut ctx := this.win.gg
	this.draw_background()

	padding_x := this.draw_line_number_background()
	mut xp := padding_x
	mut yp := 4

	mut current_x_index := 0
	mut current_y_index := 0
	mut total_index := 0

	mut color := gx.black
	mut keep_color_for := 0
	mut keep_color_util := ` `

	line_height := ctx.text_height('A{')

	if this.carrot_top < 0 {
		this.carrot_top = 0
	}
	if this.scroll_i < 0 {
		this.scroll_i = 0
	}

	if this.carrot_left < 0 {
		if this.carrot_left == -1 {
			this.carrot_top -= 1
		}
		this.carrot_left = 0
	}

	starting_line := math.max(0, this.scroll_i)
	mut shown_lines := 0

	for ru in runes {
		mut strr := ru.str()

		if keep_color_for == 0 && keep_color_util == ` ` {
			color, keep_color_for, keep_color_util = this.get_color(total_index)
		} else {
			if keep_color_for > 0 {
				keep_color_for -= 1
			}
			if ru == keep_color_util {
				keep_color_util = ` `
			}
		}

		if ru == `\t` {
			strr = ' '.repeat(8)
		}

		if ru != `\n` {
			if !(this.y + yp > this.y + this.height) {
				if current_y_index >= starting_line {
					ctx.draw_text(this.x + xp, this.y + yp, strr, gx.TextCfg{
						color: color
					})
				}
			}
		} else {
			if current_y_index < starting_line {
				current_y_index += 1
			} else {
				if this.y + yp > this.y + this.height {
					current_y_index += 1
					continue
				}
			}
		}
		if current_y_index < starting_line {
			total_index += 1
			continue
		}

		if current_y_index == this.carrot_top {
			if current_x_index == this.carrot_left {
				if current_y_index >= starting_line {
					this.draw_caret(this.x + xp, this.y + yp, total_index)
				}
			}
		}

		wid := ctx.text_width(strr)
		this.mouse_down_caret(line_height, current_x_index, xp, wid)

		// TODO: Why is wid needing -2
		if ru == `:` || ru == `.` || ru == `!` || ru == `1` {
			xp += wid
		} else {
			xp += wid - 1
		}
		current_x_index += 1
		total_index += 1

		if current_y_index == this.carrot_top && ru != `\n` {
			if current_x_index == this.carrot_left {
				if current_y_index >= starting_line {
					this.draw_caret(this.x + xp, this.y + yp, total_index)
				}
			}
		}

		if ru == `\n` {
			if this.carrot_top == current_y_index {
				if this.carrot_left > current_x_index - 1 {
					this.carrot_left = current_x_index - 1
				}
			}

			ctx.draw_text(this.x + 4, this.y + yp, (current_y_index + 1).str(), gx.TextCfg{
				color: this.win.theme.text_color
			})

			current_y_index += 1
			current_x_index = 0
			if current_y_index > starting_line {
				yp += line_height
				shown_lines += 1
			}
			xp = padding_x
		}
	}

	if current_y_index == 0 {
		if this.carrot_left > current_x_index {
			this.carrot_left = current_x_index
		}
	} else {
		this.draw_scrollbar(shown_lines, current_y_index)

		scroll_max := current_y_index - ((this.height / line_height) / 2)
		if this.scroll_i > scroll_max {
			this.scroll_i = scroll_max
		}
		ctx.draw_text(this.x + 4, this.y + yp, (current_y_index + 1).str(), gx.TextCfg{
			color: this.win.theme.text_color
		})
	}
}

fn (mut this Runebox) draw_caret(x int, y int, total_index int) {
	mut ctx := this.win.gg
	ctx.draw_text(x - 1, y, '|', gx.TextCfg{
		color: this.win.theme.text_color
	})
	if this.carrot_index != total_index {
		this.carrot_index = total_index
	}
}

const (
	// blue_words - in textbox.v
	number_words     = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
	words_substr_len = 10
	code_str         = gx.rgb(200, 100, 0)
)

struct SyntaxHighlighter {
mut:
	colors   map[string]gx.Color
	keywords map[string][]string
	between  map[string][]string
}

fn syntax_highlight_for_v() &SyntaxHighlighter {
	mut sh := &SyntaxHighlighter{}

	sh.colors['numbers'] = gx.rgb(240, 200, 0)
	sh.colors['decl'] = gx.rgb(0, 0, 200)
	sh.colors['string'] = gx.rgb(200, 100, 0)
	sh.colors['oper'] = gx.rgb(120, 81, 255)
	sh.colors['comment'] = gx.rgb(0, 150, 0)
	sh.colors['dec2'] = gx.rgb(0, 0, 255)
	sh.colors['dec3'] = gx.rgb(0, 0, 255)

	sh.keywords['numbers'] = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
	sh.keywords['decl'] = 'mut:,pub:,pub mut:,mut,pub ,unsafe ,default ,struct,type ,enum ,struct ,union ,const'.split(',')
	sh.keywords['dec2'] = ['import', 'break ', 'byte ', 'continue ', 'else ', 'false ', 'fn ',
		'for ', 'if ', 'import ', 'interface ']
	sh.keywords['dec3'] = 'is |module |return |select |shared |true |typeof union'.split('|')
	sh.keywords['oper'] = '[,],{,}'.split(',')
	sh.between['string'] = ["'", '"']
	sh.between['comment'] = ['//\n']

	return sh
}

fn syntax_highlight_for_html() &SyntaxHighlighter {
	mut sh := &SyntaxHighlighter{}
	sh.colors['bracket'] = gx.blue
	sh.between['bracket'] = ['<>']
	return sh
}

fn (this &Runebox) get_color(index int) (gx.Color, int, rune) {
	strr := this.text.substr_ni(index, index + iui.words_substr_len)

	sh := this.code_highlight

	for key, color in sh.colors {
		if key in sh.keywords {
			words := sh.keywords[key]
			for word in words {
				if strr.starts_with(word) {
					return color, word.len - 1, ` `
				}
			}
		}
		if key in sh.between {
			words := sh.between[key]
			for word in words {
				runes := word.runes()

				if runes.len > 2 {
					if strr.starts_with(runes[0..(runes.len - 1)].string()) {
						return color, 0, runes[runes.len - 1]
					}
				} else {
					if strr.starts_with(runes[0].str()) {
						return color, 0, runes[runes.len - 1]
					}
				}
			}
		}
	}

	return this.win.theme.text_color, 0, ` `
}

fn (mut this Runebox) mouse_down_caret(line_height int, current_x_index int, xp int, wid int) {
	if this.is_mouse_down {
		mut x := this.x
		if this.rx != 0 {
			x = this.rx
		}
		mut y := this.y
		if this.ry != 0 {
			y = this.ry
		}

		mx := (this.win.mouse_x - x)
		starting_line := math.max(0, this.scroll_i)
		my := ((this.win.mouse_y - y) / line_height) + starting_line

		if abs(mx - xp) < wid / 2 {
			this.carrot_top = my
			this.carrot_left = current_x_index
			this.is_mouse_down = false
		}
	}
}
