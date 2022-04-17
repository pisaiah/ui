module iui

import gg
import gx

//
// TextArea Component.
//
struct TextArea {
	Component_A
pub mut:
	win                  &Window
	lines                []string
	caret_left           int
	caret_top            int
	padding_x            int
	padding_y            int
	ml_comment           bool
	last_letter          string
	click_event_fn       fn (voidptr, voidptr)
	before_txtc_event_fn fn (mut Window, TextArea) bool
	text_change_event_fn fn (voidptr, voidptr)
	line_draw_event_fn   fn (voidptr, int, int, int)
	down_pos             CaretPos
	drawn_select         bool
	code_syntax_on       bool
	ctrl_down            bool
}

struct CaretPos {
pub mut:
	left     int = -1
	top      int = -1
	x        int
	y        int
	end_left int = -1
	end_x    int = -1
}

pub fn textarea(win &Window, lines []string) &TextArea {
	return &TextArea{
		win: win
		lines: lines
		padding_x: 4
		click_event_fn: fn (a voidptr, b voidptr) {}
		before_txtc_event_fn: fn (mut a Window, b TextArea) bool {
			return false
		}
		text_change_event_fn: fn (a voidptr, b voidptr) {}
		line_draw_event_fn: fn (a voidptr, b int, c int, d int) {}
		code_syntax_on: true
	}
}

// Delete current line; Moving text to above line if necessary.
// Usages: Backspace on empty line or backspace when caret_left == 0
pub fn (mut this TextArea) delete_current_line() {
	this.lines.delete(this.caret_top)
	this.caret_top -= 1
	this.caret_left = this.lines[this.caret_top].len
}

const keys = ['import', 'fn', 'mut', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '// ', '\t',
	"'", '(', ')', ' as ', '/*', '*/']

const numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

const blue_keys = ['import', 'mut', 'fn', '(', ')', ' as ']

// Draw background box
fn (mut this TextArea) draw_background() {
	mut bg := this.win.theme.textbox_background
	mut border := this.win.theme.textbox_border

	mid := this.x + (this.width / 2)
	midy := this.y + (this.height / 2)

	// Detect Click
	if this.is_mouse_rele {
		if !this.is_selected {
			bg = this.win.theme.button_bg_click
			border = this.win.theme.button_border_click
		}
		this.down_pos.left = -1
		this.down_pos.top = -1
		this.is_selected = true

		this.click_event_fn(this.win, this)
		this.is_mouse_rele = false
	} else {
		if this.win.click_x > -1 && !(abs(mid - this.win.mouse_x) < (this.width / 2)
			&& abs(midy - this.win.mouse_y) < (this.height / 2)) {
			this.is_selected = false
		}
	}
	this.win.draw_filled_rect(this.x, this.y, this.width, this.height, 2, bg, border)
}

fn (mut this TextArea) clamp_values(lines_drawn int) {
	if this.caret_left < 0 {
		this.caret_left = 0
	}

	max_scroll := this.lines.len - lines_drawn

	if this.scroll_i > max_scroll {
		this.scroll_i = max_scroll
	}

	if this.scroll_i < 0 {
		this.scroll_i = 0
	}
}

fn (mut this TextArea) draw() {
	win := this.win
	this.draw_background()

	line_height := text_height(win, 'A!{}')

	cfg := gx.TextCfg{
		size: this.win.font_size
		color: win.theme.text_color
	}

	num_color := (win.theme.button_bg_hover.r + win.theme.text_color.r) / 2
	cfg_num := gx.TextCfg{
		size: this.win.font_size
		color: gx.rgb(num_color, num_color, num_color)
	}

	lines_drawn := this.height / line_height
	this.clamp_values(lines_drawn)

	padding_x := this.padding_x + this.draw_line_number_background()

	for i in this.scroll_i .. this.lines.len {
		if i < 0 {
			continue
		}

		line := this.lines[i]
		y_off := line_height * (i - this.scroll_i) + this.padding_y

		if (y_off + line_height) > this.height {
			this.ml_comment = false
			break
		}

		matched := if this.code_syntax_on { make_match(line, iui.keys) } else { [line] } // TODO: cache
		is_cur_line := this.caret_top == i

		if is_cur_line {
			if this.caret_left > line.len {
				this.caret_left = line.len
			}
		}

		line_number := (i + 1).str()

		if this.code_syntax_on {
			win.gg.draw_text(this.x + (padding_x / 4), this.y + y_off, line_number, cfg_num)
		}

		this.draw_matched_text(this.win, this.x + padding_x, this.y + y_off, matched,
			cfg, is_cur_line, i)
	}
	this.draw_scrollbar(lines_drawn, this.lines.len)
}

fn (this &TextArea) draw_line_number_background() int {
	if this.code_syntax_on {
		padding_x := text_width(this.win, (this.lines.len * 1000).str())
		this.win.draw_bordered_rect(this.x + 1, this.y + 1, padding_x, this.height - 2,
			2, this.win.theme.button_bg_normal, this.win.theme.button_bg_normal)
		return padding_x
	}
	return 4
}

fn (mut this TextArea) draw_caret(win &Window, x int, y int, current_len int, llen int, str_fix_tab string) {
	in_min := this.caret_left >= current_len
	in_max := this.caret_left <= current_len + llen
	caret_zero := this.caret_left == 0 && current_len == 0

	end_pos := this.down_pos.end_left

	if end_pos >= current_len && end_pos <= current_len + llen {
		this.win.gg.draw_rect_filled(this.x + this.down_pos.x, this.y + (17 * this.caret_top),
			(this.down_pos.end_x - this.down_pos.x), 17, gx.rgba(0, 100, 200, 100))
	}

	if caret_zero || (in_min && in_max) {
		caret_pos := this.caret_left - current_len
		pretext := str_fix_tab[0..caret_pos]

		pipe_wid := text_width(win, '|')
		wid := text_width(win, pretext) - pipe_wid

		win.gg.draw_text(x + wid, y, '|', gx.TextCfg{
			color: win.theme.text_color
			size: win.font_size
		})
	}
}

fn (mut this TextArea) move_caret(win &Window, x int, y int, current_len int, llen int, str_fix_tab string, mx int, lw int) {
	rx := x - this.x

	if mx >= rx && mx < rx + lw {
		for i in 0 .. str_fix_tab.len + 1 {
			pretext := str_fix_tab[0..i]
			wid := text_width(win, pretext)

			nx := rx + wid

			cwidth := text_width(win, 'A') / 2

			if abs(mx - nx) < cwidth {
				if this.down_pos.left == -1 {
					this.caret_left = current_len + i
					// this.down_pos.left = this.caret_left
					// this.down_pos.top = this.caret_top
					// this.down_pos.x = nx
					return
				} else {
					// line := this.lines[this.caret_top]
					// this.down_pos.end_left = current_len + i
					// this.down_pos.end_x = nx
					// println(line.substr_ni(this.caret_left, current_len + i))
				}
			}
		}
	}
}

struct SyntaxRules {
	in_comment    bool
	in_str        bool
	current_color gx.Color
}

fn (mut this TextArea) draw_matched_text(win &Window, x int, y int, text []string, cfg gx.TextCfg, is_cur_line bool, line int) {
	mut x_off := 0

	mut color := cfg.color
	mut comment := false
	mut is_str := false
	mut current_len := 0

	for str in text {
		tab_size := ' '.repeat(8)
		str_fix_tab := str.replace('\t', tab_size)
		llen := if str == '\t' { 0 } else { str.len }

		if is_cur_line {
			this.draw_caret(win, x + x_off, y, current_len, llen, str_fix_tab)
		}

		color = cfg.color

		if str == "'" {
			is_str = !is_str
			color = gx.rgb(220, 0, 220)
		}
		if is_str {
			color = gx.rgb(220, 0, 220)
		}

		if str in iui.numbers {
			color = gx.orange
		}
		if str in iui.blue_keys {
			color = gx.rgb(0, 100, 200)
		}

		if str == '/*' && !is_str {
			this.ml_comment = true
		}

		if str == '// ' || comment || this.ml_comment {
			color = gx.rgb(0, 200, 0)
			comment = true
		}

		if str == '*/' {
			this.ml_comment = false
		}

		conf := gx.TextCfg{
			color: color
			size: win.font_size
		}

		wid := text_width(win, str_fix_tab)
		win.gg.draw_text(x + x_off, y, str_fix_tab, conf)

		if this.is_mouse_down {
			this.do_mouse_down(x + x_off, y, current_len, llen, str_fix_tab, wid, line)
		}

		x_off += wid
		current_len += str.len
	}
}

fn (mut this TextArea) do_mouse_down(x int, y int, current_len int, llen int, str_fix_tab string, wid int, line int) {
	mx := this.win.mouse_x - this.x
	my := this.win.mouse_y - this.y
	line_height := text_height(this.win, 'A!{}')
	my_lh := my / line_height

	if this.down_pos.top == -1 {
		this.caret_top = my_lh + this.scroll_i
	}
	if line == this.caret_top {
		this.move_caret(this.win, x, y, current_len, llen, str_fix_tab, mx, wid)
	}
}

// Draw Scrollbar
// TODO: use Slider component.
fn (mut com TextArea) draw_scrollbar(cl int, spl_len int) {
	// Calculate postion for scroll
	sth := int((f32((com.scroll_i)) / f32(spl_len)) * com.height)
	enh := int((f32(cl) / f32(spl_len)) * com.height)
	requires_scrollbar := (com.height - enh) > 0

	// Draw Scroll
	if requires_scrollbar {
		wid := 15
		min := wid + 1

		com.win.draw_bordered_rect(com.x + com.width - min, com.y + 1, wid, com.height - 2,
			2, com.win.theme.scroll_track_color, com.win.theme.button_bg_hover)
		com.win.draw_bordered_rect(com.x + com.width - min, com.y + sth + 1, wid, enh - 2,
			2, com.win.theme.scroll_bar_color, com.win.theme.scroll_track_color)
	}
}
