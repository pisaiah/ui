// Isaiah's UI Widgets for V.
// (c) 2022 Isaiah.
module iui

import gg
import gx

//
// Replacement for Textbox
//
struct TextEdit {
	Component_A
pub mut:
	win                  &Window
	lines                []string
	carrot_top           int
	carrot_left          int
	code_highlight       &SyntaxHighlighter
	code_syntax_on       bool = true
	draw_line_numbers    bool = true
	last_letter          string
	click_event_fn       fn (voidptr, voidptr)
	before_txtc_event_fn fn (mut Window, TextEdit) bool
	text_change_event_fn fn (voidptr, voidptr)
	padding_x            int
	padding_y            int
	ctrl_down            bool
	hint                 string
	hint_top             int = -1
	line_draw_event_fn   fn (voidptr, int, int, int)
}

struct NumberHover {
	line       int
	hover_text string
	box_color  gx.Color
}

pub fn (mut this TextEdit) add_number_hover_action(action &NumberHover) {
}

// Return new reference to Component.
pub fn textedit(window voidptr, text string) &TextEdit {
	return &TextEdit{
		win: &Window(window)
		lines: text.split('\n')
		code_highlight: syntax_highlight_for_v()
		click_event_fn: fn (a voidptr, b voidptr) {}
		before_txtc_event_fn: fn (mut a Window, b TextEdit) bool {
			return false
		}
		text_change_event_fn: fn (a voidptr, b voidptr) {}
		line_draw_event_fn: fn (a voidptr, b int, c int, d int) {}
	}
}

pub fn textedit_from_array(window voidptr, text []string) &TextEdit {
	return &TextEdit{
		win: &Window(window)
		lines: text
		code_highlight: syntax_highlight_for_v()
		click_event_fn: fn (a voidptr, b voidptr) {}
		before_txtc_event_fn: fn (mut a Window, b TextEdit) bool {
			return false
		}
		text_change_event_fn: fn (a voidptr, b voidptr) {}
		line_draw_event_fn: fn (a voidptr, b int, c int, d int) {}
	}
}

// Draw line numbers
fn (this &TextEdit) draw_line_number_background() int {
	if this.code_highlight != 0 && this.code_syntax_on {
		padding_x := text_width(this.win, (this.lines.len * 10).str())
		this.win.draw_bordered_rect(this.x + 1, this.y + 1, padding_x, this.height - 2,
			2, this.win.theme.button_bg_normal, this.win.theme.button_bg_normal)
		return padding_x + 4
	}
	return 4
}

// Delete current line; Moving text to above line if necessary.
// Usages: Backspace on empty line or backspace when caret_left == 0
pub fn (mut this TextEdit) delete_current_line() {
	this.lines.delete(this.carrot_top)
	this.carrot_top -= 1
	this.carrot_left = this.lines[this.carrot_top].len
}

// Draw caret text "|"
fn (this &TextEdit) draw_caret(x int, y int, confg gx.TextCfg) {
	wid := x - (text_width(this.win, '|') / 2)
	this.win.gg.draw_text(this.x + wid, y, '|', confg)
}

// Retrieve the syntax highlight color for the text
fn (this &TextEdit) get_color(index int, linec int) (gx.Color, int, rune) {
	line := this.lines[linec]
	strr := line.substr_ni(index, index + 10)

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

// Draw background box
fn (mut this TextEdit) draw_background() {
	mut bg := this.win.theme.textbox_background
	mut border := this.win.theme.textbox_border

	mut mid := (this.x + (this.width / 2))
	mut midy := (this.y + (this.height / 2))

	// Detect Click
	if this.is_mouse_rele {
		if !this.is_selected {
			bg = this.win.theme.button_bg_click
			border = this.win.theme.button_border_click
		}
		this.is_selected = true

		this.click_event_fn(this.win, this)
		this.change_caret_on_click()

		this.is_mouse_rele = false
	} else {
		if this.win.click_x > -1 && !(abs(mid - this.win.mouse_x) < (this.width / 2)
			&& abs(midy - this.win.mouse_y) < (this.height / 2)) {
			this.is_selected = false
		}
	}
	this.win.draw_filled_rect(this.x, this.y, this.width, this.height, 2, bg, border)
}

fn (mut this TextEdit) change_caret_on_click() {
	mx := this.win.mouse_x - (this.x + this.padding_x)
	my := this.win.mouse_y - this.y

	line_height := text_height(this.win, 'A0{')

	selected_line_int := (my / line_height) + this.scroll_i

	if selected_line_int >= this.lines.len {
		return
	}

	line := this.lines[selected_line_int]
	mut xo := 0
	mut left := 0
	this.carrot_top = selected_line_int
	mut smalla := -1
	mut smallb := 0
	for r in line.runes() {
		mut strr := r.str()
		if r == `\t` {
			strr = ' '.repeat(8)
		}

		rwid := text_width(this.win, strr)

		if r == ` ` {
			xo += text_width(this.win, '.')
		} else {
			if rwid > 5 {
				xo += rwid - 1
			} else {
				xo += rwid
			}
		}

		left += 1
		smallc := abs(mx - xo)
		if smallc < smalla || smalla == -1 {
			smalla = smallc
			smallb = left
		}
	}
	this.carrot_left = smallb
}

// Draw Scrollbar
// TODO: use Slider component.
fn (mut com TextEdit) draw_scrollbar(cl int, spl_len int) {
	// Calculate postion for scroll
	mut sth := int((f32((com.scroll_i)) / f32(spl_len)) * com.height)
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

// Clamp caret
fn (mut this TextEdit) clamp_caret() {
    if this.carrot_top < 0 {
        this.carrot_top = 0
    }
    
    max_top := this.lines.len - 1
    if this.carrot_top > max_top {
        this.carrot_top = max_top
    }

	if this.carrot_left < 0 {
		this.carrot_left = 0
	}
}

// Main draw function.
// TODO: simplify, split function.
fn (mut this TextEdit) draw() {
	this.draw_background()

	if this.text.contains('\r') {
		this.text = this.text.replace('\r\n', '\n')
	}

	lines := this.lines

	line_height := text_height(this.win, 'A0{')
	padding_x := this.draw_line_number_background()
	this.padding_x = padding_x

	mut oy := this.y + this.padding_y

	confg := gx.TextCfg{
		size: this.win.font_size
		color: this.win.theme.text_color
	}

    this.clamp_caret()

	if this.scroll_i < 0 {
		this.scroll_i = 0
	}

	mut shown := 0
	for line_count in this.scroll_i .. lines.len {
		line := lines[line_count]

		if line_count == this.carrot_top {
			if this.carrot_left > line.len {
				this.carrot_left = line.len
			}

			padd := padding_x - 4
			if this.code_syntax_on || lines.len > 1 {
				this.win.gg.draw_rect_filled(this.x + padd, oy, this.width - padd, line_height,
					this.win.theme.button_bg_hover)
			}
		}

		line_num := line_count + 1
		if lines.len > 1 && this.draw_line_numbers {
			this.win.gg.draw_text(this.x, oy, line_num.str(), confg)
		}

		runes := line.runes()
		mut xo := padding_x
		mut left := 0

		mut color := this.win.theme.text_color
		mut keep_color_for := 0
		mut keep_color_util := ` `

		// TODO: Calculate matches, so we don't have to draw every rune.
		for r in runes {
			if keep_color_for == 0 && keep_color_util == ` ` {
				if this.code_syntax_on {
					color, keep_color_for, keep_color_util = this.get_color(left, line_count)
				}
			} else {
				if keep_color_for > 0 {
					keep_color_for -= 1
				}
				if r == keep_color_util {
					keep_color_util = ` `
				}
			}

			if xo > this.width {
				break
			}

			mut strr := r.str()
			if r == `\t` {
				strr = ' '.repeat(8)
			}

			if !(r == ` ` || r == `\t`) {
				this.win.gg.draw_text(this.x + xo, oy, strr, gx.TextCfg{
					color: color
					size: confg.size
				})
			}

			rwid := text_width(this.win, strr)

			if line_count == this.carrot_top {
				if left == this.carrot_left {
					this.draw_caret(xo, oy, confg)
				}
			}

			if r == ` ` {
				xo += text_width(this.win, '.')
			} else {
				if rwid > 5 {
					xo += rwid - 1
				} else {
					xo += rwid
				}
			}
			left += 1

			if line_count == this.carrot_top {
				if left == this.carrot_left {
					this.draw_caret(xo, oy, confg)
				}
			}
		}

		this.line_draw_event_fn(this, line_count, xo, oy)

		if runes.len == 0 && line_count == this.carrot_top {
			this.draw_caret(xo, oy, confg)
		}

		if oy > (this.y + this.height) {
			break
		}
		shown += 1
		oy += line_height
	}
	this.draw_scrollbar(shown, this.lines.len)
}

// Syntax Highlight
struct SyntaxHighlighter {
pub mut:
	colors   map[string]gx.Color
	keywords map[string][]string
	between  map[string][]string
}

pub fn syntax_highlight_for_v() &SyntaxHighlighter {
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
