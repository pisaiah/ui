module iui

import gg
import gx

// TextArea Component.
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
	down_pos             CaretPos
	code_syntax_on       bool
	ctrl_down            bool
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

[deprecated: 'Use text_box']
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

	if this.win.bar != unsafe { nil } && this.win.bar.tik < 90 {
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
	this.win.draw_filled_rect(this.x, this.y, this.width, this.height, 2, bg, border)
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
		ctx.gg.draw_rect_filled(this.x, sel_y, this.width - 1, lh, ctx.theme.button_bg_hover)
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

		if this.code_syntax_on {
			ctx.draw_text(this.x + (padding_x / 4), this.y + y_off, '${(i + 1)}', ctx.font,
				cfg_num)
		}

		this.draw_matched_text(this.win, this.x + padding_x, this.y + y_off, matched,
			cfg, is_cur_line, i)

		invoke_line_draw_event(this, ctx, i)
	}

	ctx.gg.draw_rect_filled(this.x + this.down_pos.x, sel_y, (this.down_pos.end_x - this.down_pos.x),
		lh, gx.rgba(0, 100, 200, 50))
}

pub fn invoke_line_draw_event(com &Component, ctx &GraphicsContext, line int) {
	ev := DrawTextlineEvent{
		target: unsafe { com }
		ctx: ctx
		line: line
	}
	for f in com.events.event_map['text_line_draw'] {
		f(ev)
	}
}

fn (this &TextArea) draw_line_number_background(ctx &GraphicsContext) int {
	if !this.code_syntax_on {
		return 4
	}
	padding_x := ctx.text_width('1000')
	ctx.gg.draw_rect_filled(this.x + 1, this.y + 1, padding_x, this.height - 2, ctx.theme.button_bg_normal)
	return padding_x
}

fn (mut this TextArea) draw_caret(ctx &GraphicsContext, x int, y int, current_len int, llen int, str_fix_tab string) {
	in_min := this.caret_left >= current_len
	in_max := this.caret_left <= current_len + llen
	caret_zero := this.caret_left == 0 && current_len == 0

	if !(caret_zero || (in_min && in_max)) {
		return
	}
	caret_pos := this.caret_left - current_len
	pretext := str_fix_tab[0..caret_pos]

	wid := ctx.text_width(pretext) - 1
	height := get_line_height(ctx) + 1

	pipe_color := ctx.theme.text_color
	ctx.gg.draw_rect_filled(x + wid, y - 1, 1, height, pipe_color)
}

fn (mut this TextArea) move_caret(ctx &GraphicsContext, x int, y int, current_len int, llen int, str_fix_tab string, mx int, lw int) {
	rx := x - this.x

	if mx >= rx && mx < rx + lw {
		for i in 0 .. str_fix_tab.len + 1 {
			pretext := str_fix_tab[0..i]
			wid := ctx.text_width(pretext)

			nx := rx + wid

			cwidth := ctx.text_width('A') / 2

			if abs(mx - nx) < cwidth {
				if this.down_pos.left == -1 {
					this.caret_left = current_len + i
				}
			}
		}
	}
}

pub const keys = ['fn', 'mut', '// ', '\t', "'", '(', ')', ' as ', '/*', '*/']

pub const numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'if', 'else', 'for']

pub const blue_keys = ['fn', 'module', 'import', 'interface', 'map', 'assert', 'sizeof', 'typeof',
	'mut', '[', ']']

pub const purp_keys = ' int,i8,i16,i64,i128,u8,u16,u32,u64,u128,f32,f64, bool, byte,byteptr,charptr, voidptr,string,ustring, rune,(,)'.split(',')

pub const red_keys = '||,&&,&,=,:=,==,<=,>=,>,<,!'.split(',')

pub const colors = 'blue,red,green,yellow,orange,purple,black,gray,pink,white'.split(',')

fn (mut this TextArea) draw_matched_text(win &Window, x int, y int, text []string, cfg gx.TextCfg, is_cur_line bool, line int) {
	mut x_off := 0

	mut color := cfg.color
	mut comment := false
	mut is_str := false
	mut current_len := 0
	ctx := win.graphics_context

	for str in text {
		tab_size := ' '.repeat(8)
		str_fix_tab := str.replace('\t', tab_size)
		llen := if str == '\t' { 0 } else { str.len }

		if is_cur_line {
			this.draw_caret(ctx, x + x_off, y, current_len, llen, str)
		}

		color = cfg.color

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

		wid := ctx.text_width(str_fix_tab)
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
		this.move_caret(this.win.graphics_context, x, y, current_len, llen, str_fix_tab,
			mx, wid)
	}
}

fn is_enter(key gg.KeyCode) bool {
	return key == .enter || key == .kp_enter
}

fn (mut win Window) textarea_key_down(key gg.KeyCode, ev &gg.Event, mut com TextArea) {
	if !com.is_selected {
		return
	}
	if key == .right {
		com.caret_left += 1
	} else if key == .left {
		com.caret_left -= 1
	} else if key == .up {
		if com.caret_top > 0 {
			com.caret_top -= 1
		}
	} else if key == .down {
		if com.caret_top < com.lines.len - 1 {
			com.caret_top += 1
		}
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
			line := com.lines[com.caret_top]

			com.last_letter = 'backspace'
			mut bevnt := com.before_txtc_event_fn(mut win, *com)
			if bevnt {
				// 'true' indicates cancel event
				return
			}

			if com.caret_left == 0 && com.caret_top == 0 {
				return
			}

			if com.caret_left - 1 >= 0 {
				new_line := line.substr(0, com.caret_left - 1) +
					line.substr(com.caret_left, line.len)
				com.lines[com.caret_top] = new_line
				com.caret_left -= 1
			} else {
				// EOL
				line_text := line
				com.delete_current_line()
				com.lines[com.caret_top] = com.lines[com.caret_top] + line_text
			}
		} else {
			win.textarea_key_down_typed(key, ev, mut com)
		}
	}
}

fn (mut win Window) textarea_key_down_typed(key gg.KeyCode, ev &gg.Event, mut com TextArea) {
	mod := ev.modifiers

	mut enter := is_enter(key)

	if key == .left_shift || key == .right_shift {
		win.shift_pressed = true
		return
	}

	mut letter := ''

	if ev.typ == .char {
		resu := utf32_to_str(ev.char_code)
		letter = resu
		com.last_letter = letter
	}

	$if emscripten ? {
		if ev.typ == .char && ev.char_code == 13 {
			enter = true
		}
	}

	if enter {
		com.last_letter = 'enter'
	}

	bevnt := com.before_txtc_event_fn(mut win, *com)
	if bevnt {
		// 'true' indicates cancel event
		return
	}

	if !enter && mod != 2 {
		if com.lines.len == 0 {
			com.lines << ' '
			com.caret_top = 0
		}

		line := com.lines[com.caret_top]

		if letter.len > 1 {
			// For extended unicode
			mut myrunes := line.runes()
			myrunes.insert(com.caret_left, letter.runes()[0])
			com.lines[com.caret_top] = myrunes.string()
			unsafe {
				myrunes.free()
			}
		} else {
			new_line := line.substr_ni(0, com.caret_left) + letter +
				line.substr_ni(com.caret_left, line.len)
			com.lines[com.caret_top] = new_line
		}
	}

	com.last_letter = letter
	com.text_change_event_fn(win, com)

	if enter {
		current_line := com.lines[com.caret_top]
		if com.caret_left == current_line.len {
			com.caret_top += 1
			com.lines.insert(com.caret_top, '')
			if current_line.starts_with('\t') {
				com.lines[com.caret_top] = '\t'
			}
		} else {
			keep_line := current_line.substr(0, com.caret_left)
			new_line := current_line.substr_ni(com.caret_left, current_line.len)

			com.lines[com.caret_top] = keep_line

			com.caret_top += 1
			com.lines.insert(com.caret_top, '')
			com.lines[com.caret_top] = new_line
			com.caret_left = 0
		}
	} else if mod != 2 {
		if letter.len > 0 {
			com.caret_left += 1
		}
	}
}
