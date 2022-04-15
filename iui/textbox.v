module iui

import gx

// Textbox - implements Component interface
// Deprecated - Replaced by better TextArea/TextField
[deprecated: 'Replaced with TextArea (multiline), TextField (singleline-only)']
struct Textbox {
	Component_A
pub mut:
	app                  &Window
	text                 string
	click_event_fn       fn (mut Window, Textbox)
	before_txtc_event_fn fn (mut Window, Textbox) bool
	text_change_event_fn fn (mut Window, Textbox)
	multiline            bool = true
	ctrl_down            bool
	last_letter          string
	carrot_left          int
	key_down             bool
}

[deprecated]
pub fn (mut com Textbox) set_codebox(val bool) {
	// com.code_highlight = val
}

[deprecated: 'Replaced with TextArea/TextField']
pub fn textbox(app &Window, text string) &Textbox {
	return &Textbox{
		text: text
		app: app
		click_event_fn: fn (mut win Window, a Textbox) {}
		text_change_event_fn: fn (mut win Window, a Textbox) {}
		before_txtc_event_fn: fn (mut win Window, a Textbox) bool {
			return false
		}
	}
}

[deprecated]
pub fn (mut com Textbox) set_click(b fn (mut Window, Textbox)) {
	com.click_event_fn = b
}

[deprecated]
pub fn (mut com Textbox) set_text_change(b fn (mut Window, Textbox)) {
	com.text_change_event_fn = b
}

pub fn (mut this Textbox) draw() {
	ctx := this.app.gg
	this.draw_background()

	xp := this.x + 4
	yp := this.y + 4

	color := this.app.theme.text_color

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

	pipe_width := text_width(this.app, '|') / 2
	wid := text_width(this.app, this.text[0..this.carrot_left])

	ctx.draw_text(xp + wid - pipe_width, yp, '|', cfg)
}

fn (mut this Textbox) mouse_down_caret() {
	if !this.is_mouse_down {
		return
	}

	x := if this.rx != 0 { this.rx } else { this.x }

	mx := this.app.mouse_x - x
	wid_char := text_width(this.app, 'A')
	full_wid := text_width(this.app, this.text)

	if mx > full_wid {
		this.carrot_left = this.text.len
	}

	for i in 0 .. this.text.len + 1 {
		substr := this.text[0..i]
		wid := text_width(this.app, substr)

		if abs(mx - wid) <= wid_char {
			this.carrot_left = i
			return
		}
	}
}

fn (mut this Textbox) draw_background() {
	mut bg := this.app.theme.textbox_background
	mut border := this.app.theme.textbox_border

	mid := (this.x + (this.width / 2))
	midy := (this.y + (this.height / 2))

	// Detect Click
	if this.is_mouse_rele {
		this.is_selected = true
		this.click_event_fn(this.app, *this)

		bg = this.app.theme.button_bg_click
		border = this.app.theme.button_border_click

		this.is_mouse_rele = false
	} else {
		if this.app.click_x > -1 && !(abs(mid - this.app.mouse_x) < (this.width / 2)
			&& abs(midy - this.app.mouse_y) < (this.height / 2)) {
			this.is_selected = false
		}
	}
	this.app.draw_filled_rect(this.x, this.y, this.width, this.height, 2, bg, border)
}
