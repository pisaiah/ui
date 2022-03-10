module iui

import gg
import gx

//
// Runebox Component
// --------------------
// Textbox replacement that draws by runes
//
struct Runebox {
	Component_A
pub mut:
	win            &Window
	carrot_top     int
	carrot_left    int
	carrot_index   int
	click_event_fn fn (voidptr, voidptr)
}

pub fn runebox(mut win Window, text string) &Runebox {
	return &Runebox{
		win: win
		text: text
		click_event_fn: fn (a voidptr, b voidptr) {}
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
}

fn (mut this Runebox) draw() {
	runes := this.text.runes()

	mut ctx := this.win.gg
	this.draw_background()

	mut xp := 0
	mut yp := 0

	mut current_x_index := 0
	mut current_y_index := 0
	mut total_index := 0

	mut color := gx.black
	mut keep_color_for := 0

	line_height := ctx.text_height('A0{')

	if this.carrot_top < 0 {
		this.carrot_top = 0
	}

	if this.carrot_left < 0 {
		if this.carrot_left == -1 {
			this.carrot_top -= 1
		}
		this.carrot_left = 0
	}

	for ru in runes {
		mut strr := ru.str()

		if keep_color_for == 0 {
			color, keep_color_for = this.get_color(total_index)
		} else {
			keep_color_for -= 1
		}

		if ru == `\t` {
			strr = ' '.repeat(8)
		}

		if ru != `\n` {
			ctx.draw_text(this.x + xp, this.y + yp, strr, gx.TextCfg{
				color: color
			})
		}

		if current_y_index == this.carrot_top {
			if current_x_index == this.carrot_left {
				this.draw_caret(this.x + xp, this.y + yp, total_index)
			}
		}

		wid := ctx.text_width(strr)
		this.mouse_down_caret(line_height, current_x_index, xp, wid)

		// TODO: Why is wid needing -2
		if ru == `:` || ru == `.` {
			xp += wid
		} else {
			xp += wid - 2
		}
		current_x_index += 1
		total_index += 1

		if current_y_index == this.carrot_top && ru != `\n` {
			if current_x_index == this.carrot_left {
				this.draw_caret(this.x + xp, this.y + yp, total_index)
			}
		}

		if ru == `\n` {
			if this.carrot_top == current_y_index {
				if this.carrot_left > current_x_index - 1 {
					this.carrot_left = current_x_index - 1
				}
			}
			current_y_index += 1
			current_x_index = 0
			yp += line_height
			xp = 0
		}
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
	words_substr_len = 4
)

fn (mut this Runebox) get_color(index int) (gx.Color, int) {
	strr := this.text.substr_ni(index, index + iui.words_substr_len)

	for word in blue_words {
		if strr.starts_with(word) {
			return code_blue, word.len - 1
		}
	}

	for word in iui.number_words {
		if strr.starts_with(word) {
			return code_num, 0
		}
	}

	return gx.black, 0
}

fn (mut this Runebox) mouse_down_caret(line_height int, current_x_index int, xp int, wid int) {
	if this.is_mouse_down {
		mx := (this.win.mouse_x - this.x)
		my := (this.win.mouse_y - this.y) / line_height

		if abs(mx - xp) < wid / 2 {
			this.carrot_top = my
			this.carrot_left = current_x_index
			this.is_mouse_down = false
		}
	}
}

/*
const (
	code_str   = gx.rgb(200, 100, 0)
	code_pur   = gx.rgb(200, 100, 200)

	blue_words = ['mut', 'pub', 'fn', 'true', 'false', 'import', 'module', 'struct']
	pur_words  = ['if', 'return', 'else', 'for']
)*/
