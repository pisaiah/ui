module iui

import gx
import gg

const numbers_val = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.']

// TextField Component - Single line text input
pub struct TextField {
	Component_A
pub mut:
	carrot_left          int
	ctrl_down            bool
	last_letter          string
	text_change_event_fn fn (voidptr, voidptr) = fn (a voidptr, b voidptr) {}
	padding_x            int
	center               bool
	numeric              bool
	blinked              bool
	bind_val             &string = unsafe { nil }
}

pub fn (mut tf TextField) bind_to(val &string) {
	unsafe {
		tf.bind_val = val
	}
}

pub fn (mut tf TextField) update_bind() {
	if isnil(tf.bind_val) {
		return
	}

	unsafe {
		*tf.bind_val = tf.text
	}
}

pub fn (mut box TextField) set_text_change(b fn (a voidptr, b voidptr)) {
	box.text_change_event_fn = b
}

pub fn numeric_field(val int) &TextField {
	return &TextField{
		text: val.str()
		numeric: true
		center: true
		carrot_left: val.str().len
	}
}

@[params]
pub struct FieldCfg {
pub:
	text   string
	center bool = true
	bounds Bounds
}

pub fn TextField.new(c FieldCfg) &TextField {
	return &TextField{
		text: c.text
		x: c.bounds.x
		y: c.bounds.y
		width: c.bounds.width
		height: c.bounds.height
		center: c.center
		carrot_left: c.text.len
	}
}

pub fn text_field(cfg FieldCfg) &TextField {
	return TextField.new(cfg)
}

fn (mut this TextField) draw_background(ctx &GraphicsContext) {
	click := this.is_mouse_rele
	bg := if click { ctx.theme.button_bg_click } else { ctx.theme.textbox_background }

	mid := this.x + (this.width / 2)
	midy := this.y + (this.height / 2)

	ctx.gg.draw_rect_filled(this.x, this.y, this.width, this.height, bg)
	ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, ctx.theme.textbox_border)

	if click || this.is_selected {
		ctx.gg.draw_rect_filled(this.x, this.y + this.height - 1, this.width, 2, ctx.theme.button_border_click)
	}

	// Detect Click
	if this.is_mouse_rele {
		this.is_selected = true

		// this.click_event_fn(ctx.win, this)
		this.is_mouse_rele = false
		return
	}

	if ctx.win.click_x > -1 && !(abs(mid - ctx.win.mouse_x) < this.width / 2
		&& abs(midy - ctx.win.mouse_y) < this.height / 2) {
		this.is_selected = false
	}
}

fn (mut this TextField) draw(ctx &GraphicsContext) {
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

	wid := ctx.text_width(this.text[0..this.carrot_left])

	pipe_color := if this.blinked && this.is_selected {
		ctx.theme.button_bg_hover
	} else {
		color
	}

	if this.width == 0 {
		width := ctx.text_width(this.text)
		this.width = width + 8 + this.padding_x
	}

	if !isnil(this.bind_val) {
		if this.text != this.bind_val {
			this.text = this.bind_val
		}
	}

	if this.center {
		// Y-center text
		th := ctx.line_height
		if this.height < th {
			this.height = min_h(ctx)
		}

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
	wid_char := ctx.text_width('A')
	full_wid := ctx.text_width(this.text)

	if mx > full_wid {
		this.carrot_left = this.text.len
	}

	for i in 0 .. this.text.len + 1 {
		substr := this.text[0..i]
		wid := ctx.text_width(substr)

		if abs(mx - wid) <= wid_char {
			this.carrot_left = i
			return
		}
	}
}

fn (mut w Window) runebox_key(key gg.KeyCode, ev &gg.Event, mut com TextField) {
	if !com.is_selected {
		return
	}

	if key == .right {
		com.carrot_left += 1
		return
	} else if key == .left {
		com.carrot_left -= 1
		return
	}
	mod := ev.modifiers
	if mod == 8 {
		// Windows Key
		return
	}
	if mod == 2 {
		com.ctrl_down = true
	}
	if key == .backspace {
		com.text = com.text.substr_ni(0, com.carrot_left - 1) +
			com.text.substr_ni(com.carrot_left, com.text.len)
		com.update_bind()
		com.carrot_left -= 1
		com.ctrl_down = false
		return
	}

	if key == .left_shift || key == .right_shift {
		w.shift_pressed = true
		return
	}

	enter := is_enter(key)

	if enter {
		com.last_letter = 'enter'
		bevnt := invoke_text_change(com, w.graphics_context, 'before_text_change')
		if bevnt || key == .up || key == .down {
			return
		}
		com.text_change_event_fn(w, com)
		com.ctrl_down = false
		return
	}

	if ev.typ == .key_down {
		return
	}

	resu := utf32_to_str(ev.char_code)
	letter := resu

	com.last_letter = letter

	bevnt := invoke_text_change(com, w.graphics_context, 'before_text_change')
	if bevnt || key == .up || key == .down {
		// 'true' indicates cancel event
		return
	}

	if mod != 2 && !enter {
		if com.numeric {
			if letter !in iui.numbers_val {
				com.last_letter = letter
				com.text_change_event_fn(w, com)
				return
			}
		}

		com.text = com.text.substr_ni(0, com.carrot_left) + letter +
			com.text.substr_ni(com.carrot_left, com.text.len)
		com.update_bind()

		com.carrot_left += 1
	}

	if enter {
		com.last_letter = 'enter'
	} else {
		com.last_letter = letter
	}
	com.text_change_event_fn(w, com)
	com.ctrl_down = false
	unsafe {
		resu.free()
	}
}
