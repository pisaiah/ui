module iui

import gx

// TextField Component - Single line text input
pub struct TextField {
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
	center               bool
	numeric              bool
	blinked              bool
}

pub fn (mut box TextField) set_text_change(b fn (a voidptr, b voidptr)) {
	box.text_change_event_fn = b
}

pub fn numeric_field(val int) &TextField {
	return &TextField{
		win: unsafe { nil }
		text: val.str()
		numeric: true
		center: true
		click_event_fn: fn (a voidptr, b voidptr) {}
		before_txtc_event_fn: fn (mut a Window, b TextField) bool {
			return false
		}
		text_change_event_fn: fn (a voidptr, b voidptr) {}
		carrot_left: val.str().len
	}
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
		carrot_left: text.len
	}
}

fn (mut this TextField) draw_background() {
	mut bg := this.win.theme.textbox_background
	mut border := this.win.theme.textbox_border

	mid := this.x + (this.width / 2)
	midy := this.y + (this.height / 2)

	// Detect Click
	if this.is_mouse_rele {
		this.is_selected = true
		this.click_event_fn(this.win, this)

		bg = this.win.theme.button_bg_click
		border = this.win.theme.button_border_click

		this.is_mouse_rele = false
	} else {
		if this.win.click_x > -1 && !(abs(mid - this.win.mouse_x) < this.width / 2
			&& abs(midy - this.win.mouse_y) < this.height / 2) {
			this.is_selected = false
		}
	}
	this.win.draw_filled_rect(this.x, this.y, this.width, this.height, 2, bg, border)
}

fn (mut this TextField) draw(ctx &GraphicsContext) {
	if this.win == unsafe { nil } {
		// TODO: Update textfield
		this.win = ctx.win
	}
	// if ctx.win.second_pass == 1 {
	//	this.blinked = !this.blinked
	//}

	this.draw_background()

	xp := this.x + 4 + this.padding_x
	yp := this.y + 4

	color := ctx.theme.text_color

	this.scroll_i = 0

	if this.carrot_left < 0 {
		this.carrot_left = 0
	}

	if this.carrot_left > this.text.len {
		this.carrot_left = this.text.len
	}

	cfg := gx.TextCfg{
		color: color
		size: this.win.font_size
	}

	// pipe_width := text_width(this.win, '|') / 2
	wid := text_width(this.win, this.text[0..this.carrot_left])

	pipe_color := if this.blinked && this.is_selected {
		ctx.theme.button_bg_hover
	} else {
		color
	}

	if this.center {
		// Y-center text
		th := ctx.gg.text_height(this.text)
		ycp := this.y + (this.height - th) / 2
		ctx.draw_text(xp, ycp, this.text, ctx.font, cfg)
		ctx.gg.draw_line(xp + wid, ycp, xp + wid, ycp + th, pipe_color)
	} else {
		ctx.draw_text(xp, this.y + 4, this.text, ctx.font, cfg)
		ctx.gg.draw_line(xp + wid, this.y + 2, xp + wid, this.y + ctx.line_height, pipe_color)
	}

	this.mouse_down_caret()
}

fn (mut this TextField) mouse_down_caret() {
	if !this.is_mouse_down {
		return
	}

	if this.win.bar != unsafe { nil } {
		if this.win.bar.tik < 90 {
			this.is_mouse_down = false
			return
		}
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
