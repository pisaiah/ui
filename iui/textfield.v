module iui

import gx

//
// TextField Component
// --------------------
// Single line text input
//
struct TextField {
	Component_A
pub mut:
	win                  &Window
	carrot_top           int
	carrot_left          int
	ctrl_down            bool
	last_letter          string
	click_event_fn       fn (voidptr, voidptr)
	before_txtc_event_fn fn (mut Window, TextField) bool
	text_change_event_fn fn (voidptr, voidptr)
	padding_x            int
}

pub fn textfield(win &Window, text string) &TextField {
	return &TextField{
		win: win
		text: text
		click_event_fn: fn (a voidptr, b voidptr) {}
		before_txtc_event_fn: fn (mut a Window, b TextField) bool {
			return false
		}
		text_change_event_fn: fn (a voidptr, b voidptr) {}
	}
}

fn (mut this TextField) draw_background() {
	mut bg := this.win.theme.textbox_background
	mut border := this.win.theme.textbox_border

	mid := (this.x + (this.width / 2))
	midy := (this.y + (this.height / 2))

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

fn (mut this TextField) draw() {
	ctx := this.win.gg
	this.draw_background()

	xp := this.x + 4
	yp := this.y + 4

	color := this.win.theme.text_color

	this.scroll_i = 0

	if this.carrot_left < 0 {
		this.carrot_left = 0
	}

	if this.carrot_left > this.text.len {
		this.carrot_left = this.text.len
	}

	cfg := gx.TextCfg{
		color: color
	}

	ctx.draw_text(xp, this.y + 4, this.text, cfg)

	pipe_width := text_width(this.win, '|') / 2
	wid := text_width(this.win, this.text[0..this.carrot_left])

	ctx.draw_text(xp + wid - pipe_width, yp, '|', cfg)

	this.mouse_down_caret()
}

fn (mut this TextField) mouse_down_caret() {
	if !this.is_mouse_down {
		return
	}

	x := if this.rx != 0 { this.rx } else { this.x }

	mx := this.win.mouse_x - x
	wid_char := text_width(this.win, 'A')
    full_wid := text_width(this.win, this.text)

    if mx > full_wid {
        this.carrot_left = this.text.len
    }

	for i in 0 .. this.text.len + 1 {
		substr := this.text[0..i]
		wid := text_width(this.win, substr)

		if abs(mx - wid) <= wid_char {
			this.carrot_left = i
			return
		}
	}
}
