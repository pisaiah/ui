module iui

import gx

// TextField Component - Single line text input
pub struct TextField {
	Component_A
pub mut:
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

[params]
pub struct FieldCfg {
	text   string
	center bool = true
	bounds Bounds
}

pub fn text_field(cfg FieldCfg) &TextField {
	return &TextField{
		text: cfg.text
		click_event_fn: fn (a voidptr, b voidptr) {}
		before_txtc_event_fn: fn (mut a Window, b TextField) bool {
			return false
		}
		x: cfg.bounds.x
		y: cfg.bounds.y
		width: cfg.bounds.width
		height: cfg.bounds.height
		center: cfg.center
		text_change_event_fn: fn (a voidptr, b voidptr) {}
		carrot_left: cfg.text.len
	}
}

[deprecated]
pub fn textfield(win &Window, text string) &TextField {
	return text_field(text: text)
}

fn (mut this TextField) draw_background(ctx &GraphicsContext) {
	click := this.is_mouse_rele
	bg := if click { ctx.theme.button_bg_click } else { ctx.theme.textbox_background }
	border := if click { ctx.theme.button_border_click } else { ctx.theme.textbox_border }

	mid := this.x + (this.width / 2)
	midy := this.y + (this.height / 2)

	// Detect Click
	if this.is_mouse_rele {
		this.is_selected = true
		this.click_event_fn(ctx.win, this)
		this.is_mouse_rele = false
	} else {
		if ctx.win.click_x > -1 && !(abs(mid - ctx.win.mouse_x) < this.width / 2
			&& abs(midy - ctx.win.mouse_y) < this.height / 2) {
			this.is_selected = false
		}
	}
	ctx.gg.draw_rect_filled(this.x, this.y, this.width, this.height, bg)
	ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, border)
}

fn (mut this TextField) draw(ctx &GraphicsContext) {
	// if ctx.win.second_pass == 1 {
	//	this.blinked = !this.blinked
	//}

	this.draw_background(ctx)

	xp := this.x + 4 + this.padding_x

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
		size: ctx.win.font_size
	}

	wid := ctx.gg.text_width(this.text[0..this.carrot_left])

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

	this.mouse_down_caret(ctx)
}

fn (mut this TextField) mouse_down_caret(ctx &GraphicsContext) {
	if !this.is_mouse_down {
		return
	}

	if ctx.win.bar != unsafe { nil } {
		if ctx.win.bar.tik < 90 {
			this.is_mouse_down = false
			return
		}
	}

	x := if this.rx != 0 { this.rx } else { this.x }

	mx := ctx.win.mouse_x - x
	wid_char := text_width(ctx.win, 'A')
	full_wid := text_width(ctx.win, this.text)

	if mx > full_wid {
		this.carrot_left = this.text.len
	}

	for i in 0 .. this.text.len + 1 {
		substr := this.text[0..i]
		wid := text_width(ctx.win, substr)

		if abs(mx - wid) <= wid_char {
			this.carrot_left = i
			return
		}
	}
}
