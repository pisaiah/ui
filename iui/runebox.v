module iui

import gx
import math

//
// Runebox Component
// --------------------
// Single line text input
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
}

fn (mut this Runebox) draw() {
	runes := this.text.runes()

	mut ctx := this.win.gg
	this.draw_background()

	padding_x := 4
	mut xp := padding_x
	mut yp := 4

	mut current_x_index := 0
	mut total_index := 0

	mut color := this.win.theme.text_color

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

	for ru in runes {
		mut strr := ru.str()

		if ru == `\t` {
			strr = ' '.repeat(8)
		}

		if !(this.y + yp > this.y + this.height) {
			ctx.draw_text(this.x + xp, this.y + yp, strr, gx.TextCfg{
				color: color
			})
		}

		if current_x_index == this.carrot_left {
			this.draw_caret(this.x + xp, this.y + yp, total_index)
		}

		wid := ctx.text_width(strr)
		this.mouse_down_caret(line_height, current_x_index, xp, wid)

		// TODO: Why is wid needing -1
		if ru == `:` || ru == `.` || ru == `!` || ru == `1` {
			xp += wid
		} else {
			xp += wid - 1
		}
		current_x_index += 1
		total_index += 1

		if current_x_index == this.carrot_left {
			this.draw_caret(this.x + xp, this.y + yp, total_index)
		}
	}

	if this.carrot_left > current_x_index {
		this.carrot_left = current_x_index
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

[deprecated]
fn (this &Runebox) get_color(index int) (gx.Color, int, rune) {
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
