module iui

import gg
import gx

//
// TextArea Component.
//
[minify]
pub struct TextArea {
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
	hide_border          bool
	keys                 []string
	needs_pack           bool
}

[minify]
pub struct CaretPos {
pub mut:
	left     int = -1
	top      int = -1
	x        int
	y        int
	end_left int = -1
	end_x    int = -1
}

pub fn (mut this TextArea) pack() {
	this.needs_pack = true
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

// Draw background box
fn (mut this TextArea) draw_background() {
	mut bg := this.win.theme.textbox_background
	mut border := this.win.theme.textbox_border

	mid := this.x + (this.width / 2)
	midy := this.y + (this.height / 2)

	if this.win.bar != voidptr(0) && this.win.bar.tik < 90 {
		this.is_mouse_down = false
		this.is_mouse_rele = false
	}

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
	if this.hide_border {
		border = bg
		this.win.gg.draw_rect_filled(this.x, this.y, this.width, this.height, bg)
	} else {
		this.win.draw_filled_rect(this.x, this.y, this.width, this.height, 2, bg, border)
	}
}

fn (mut this TextArea) clamp_values(lines_drawn int) {
	if this.caret_left < 0 {
		this.caret_left = 0
	}

	if this.caret_top > this.lines.len - 1 {
		this.caret_top = this.lines.len - 1
	}

	max_scroll := (this.lines.len - lines_drawn) + 1

	if this.scroll_i > max_scroll {
		this.scroll_i = max_scroll
	}

	if this.scroll_i < 0 {
		this.scroll_i = 0
	}
}

pub fn get_line_height(ctx &GraphicsContext) int {
	return ctx.line_height + 2
}

fn (mut this TextArea) draw(ctx &GraphicsContext) {
	if this.keys.len == 0 {
		this.keys << iui.blue_keys
		this.keys << iui.purp_keys
		this.keys << iui.numbers
		this.keys << iui.keys
		this.keys << iui.red_keys
		this.keys << iui.colors
	}

	lh := get_line_height(ctx)
	line_height := get_line_height(ctx)

	this.draw_background()

	sel_y := this.y + (lh * (this.caret_top - this.scroll_i)) + this.padding_y
	if sel_y > this.y {
		ctx.gg.draw_rect_filled(this.x, sel_y - 1, this.width, lh + 2, ctx.theme.button_bg_hover)
	}

	cfg := gx.TextCfg{
		size: ctx.font_size
		color: ctx.theme.text_color
	}

	num_color := (ctx.theme.button_bg_hover.r + ctx.theme.text_color.r) / 2
	cfg_num := gx.TextCfg{
		size: ctx.font_size
		color: gx.rgb(num_color, num_color, num_color)
	}

	lines_drawn := this.height / line_height
	this.clamp_values(lines_drawn)

	line_bg_width := this.draw_line_number_background(ctx)
	padding_x := this.padding_x + line_bg_width

	if this.needs_pack {
		// Pack
		y_off := (line_height * this.lines.len) + this.padding_y
		this.height = y_off
	}

	ws := ctx.gg.window_size()

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

		if (this.y + y_off) < 0 {
			continue
		}

		if (this.y + y_off) > ws.height {
			this.ml_comment = false
			break
		}

		matched := if this.code_syntax_on { make_match(line, this.keys) } else { [
				line,
			] } // TODO: cache
		is_cur_line := this.caret_top == i

		if is_cur_line {
			if this.caret_left > line.len {
				this.caret_left = line.len
			}
		}

		line_number := (i + 1).str()

		if this.code_syntax_on {
			ctx.draw_text(this.x + (padding_x / 4), this.y + y_off, line_number, ctx.font,
				cfg_num)
		}

		this.draw_matched_text(this.win, this.x + padding_x, this.y + y_off, matched,
			cfg, is_cur_line, i)
	}
	this.draw_scrollbar(lines_drawn, this.lines.len)

	ctx.gg.draw_rect_filled(this.x + this.down_pos.x, sel_y, (this.down_pos.end_x - this.down_pos.x),
		lh, gx.rgba(0, 100, 200, 50))
}

fn (this &TextArea) draw_line_number_background(ctx &GraphicsContext) int {
	if this.code_syntax_on {
		padding_x := text_width(this.win, (this.lines.len * 1000).str())
		this.win.draw_bordered_rect(this.x + 1, this.y + 1, padding_x, this.height - 2,
			2, ctx.theme.button_bg_normal, ctx.theme.button_bg_normal)
		return padding_x
	}
	return 4
}

fn (mut this TextArea) draw_caret(win &Window, x int, y int, current_len int, llen int, str_fix_tab string) {
	in_min := this.caret_left >= current_len
	in_max := this.caret_left <= current_len + llen
	caret_zero := this.caret_left == 0 && current_len == 0

	if caret_zero || (in_min && in_max) {
		caret_pos := this.caret_left - current_len
		pretext := str_fix_tab[0..caret_pos]
		ctx := win.graphics_context

		wid := text_width(win, pretext) - 1
		height := get_line_height(ctx) + 1

		ctx.gg.draw_rect_filled(x + wid, y - 1, 2, height, ctx.theme.text_color)
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

pub struct SyntaxRules {
	in_comment    bool
	in_str        bool
	current_color gx.Color
}

const keys = ['fn', 'mut', '// ', '\t', "'", '(', ')', ' as ', '/*', '*/']

const numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'if', 'else', 'for']

const blue_keys = ['fn', 'module', 'import', 'interface', 'map', 'assert', 'sizeof', 'typeof',
	'mut', '[', ']']

const purp_keys = ' int,i8,i16,i64,i128,u8,u16,u32,u64,u128,f32,f64, bool, byte,byteptr,charptr, voidptr,string,ustring, rune,(,)'.split(',')

const red_keys = '||,&&,&,=,:=,==,<=,>=,>,<,!'.split(',')

const colors = 'blue,red,green,yellow,orange,purple,black,gray,pink,white'.split(',')

fn (this &TextArea) draw_tab_dots(ctx &GraphicsContext, current_len int, x int, y int) {
	if current_len <= 0 {
		// Ignore first tab
		return
	}

	height := get_line_height(ctx)
	xpos := x + 1

	ctx.gg.draw_line_with_config(xpos, y, xpos, y + height, gg.PenConfig{
		color: ctx.theme.text_color
		line_type: .dotted
		thickness: 1
	})
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
			this.draw_caret(win, x + x_off, y, current_len, llen, str)
		}

		color = cfg.color

		if str == '\t' {
			ctx := win.graphics_context
			xpos := x + x_off + 1
			this.draw_tab_dots(ctx, current_len, xpos, y)
		}

		if str in iui.colors {
			color = gx.color_from_string(str)
		}

		if str in iui.numbers {
			color = gx.orange
		}
		if str in iui.blue_keys {
			color = gx.rgb(51, 153, 255)
		}
		if str in iui.red_keys {
			color = gx.red
		}

		if str in iui.purp_keys {
			color = gx.rgb(190, 40, 250)
		}

		if str == "'" {
			is_str = !is_str
			color = gx.rgb(205, 145, 120)
		}
		if is_str {
			color = gx.rgb(205, 145, 120)
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
		ctx := win.graphics_context
		ctx.draw_text(x + x_off, y, str_fix_tab, ctx.font, conf)

		if this.is_mouse_down {
			this.do_mouse_down(x + x_off, y, current_len, llen, str_fix_tab, wid, line)
		}

		x_off += wid
		current_len += str.len
	}
}

fn (mut this TextArea) do_mouse_down(x int, y int, current_len int, llen int, str_fix_tab string, wid int, line int) {
	mx := this.win.mouse_x - this.x
	my := this.win.mouse_y - this.y - this.padding_y
	line_height := get_line_height(this.win.graphics_context)
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

		com.win.gg.draw_rounded_rect_filled(com.x + com.width - min, com.y + sth + 1,
			wid, enh - 2, 16, com.win.theme.scroll_bar_color)
	}
}
