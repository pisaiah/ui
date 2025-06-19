module iui

import gx
import gg

const numbers_val = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.']

// TextField Component - Single line text input
pub struct TextField {
	Component_A
pub mut:
	carrot_left int
	ctrl_down   bool
	last_letter string
	padding_x   int
	center      bool
	numeric     bool
	blinked     bool
	bind_val    &string = unsafe { nil }
	sel         ?Selection
	reset_sel   bool
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

pub fn numeric_field(val int) &TextField {
	return &TextField{
		text:        val.str()
		numeric:     true
		center:      true
		carrot_left: val.str().len
		sel:         none
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
		text:        c.text
		x:           c.bounds.x
		y:           c.bounds.y
		width:       c.bounds.width
		height:      c.bounds.height
		center:      c.center
		carrot_left: c.text.len
		sel:         none
	}
}

pub fn text_field(cfg FieldCfg) &TextField {
	return TextField.new(cfg)
}

fn (mut txf TextField) draw_background(g &GraphicsContext) {
	click := txf.is_mouse_rele && !txf.is_selected
	bg := if click { g.theme.button_bg_click } else { g.theme.textbox_background }

	mid := txf.x + (txf.width / 2)
	midy := txf.y + (txf.height / 2)

	// Fluent Design
	accent := if click || txf.is_selected {
		g.theme.accent_fill
	} else {
		g.theme.scroll_bar_color
	}

	b_h := if click || txf.is_selected { 2 } else { 1 }

	g.gg.draw_rounded_rect_filled(txf.x, txf.y, txf.width, txf.height, 2, g.theme.textbox_border)
	g.gg.draw_rounded_rect_filled(txf.x + 1, txf.y + 1, txf.width - 2, txf.height, 4,
		accent)
	g.gg.draw_rounded_rect_filled(txf.x + 1, txf.y + 1, txf.width - 2, txf.height - b_h,
		4, bg)

	// Detect Click
	if txf.is_mouse_rele {
		txf.reset_sel = true
		txf.is_selected = true

		if txf.is_selected {
			wasm_keyboard_show(true)
		}

		txf.is_mouse_rele = false
		return
	}

	if g.win.click_x > -1 && !(abs(mid - g.win.mouse_x) < txf.width / 2
		&& abs(midy - g.win.mouse_y) < txf.height / 2) {
		txf.is_selected = false
	}
}

fn wasm_cstr(the_string string) &char {
	return &char(the_string.str)
}

// TODO: Improve keyboard on WASM
fn wasm_keyboard_show(val bool) {
	/*
	$if emscripten ? {
		if val {
			line := "var input = document.createElement('input'); input.type = 'text'; input.id = 'hiddenInput'; input.style.position = 'absolute'; input.style.left = '-1000px'; input.style.top = '-1000px'; document.body.appendChild(input); input.focus(); setTimeout(function() {input.remove() }, 1000)"
			C.emscripten_run_script(wasm_cstr(line))
		} else {
			line := "var input = document.getElementById('input'); if (input !== null) { input.remove() }"
			C.emscripten_run_script(wasm_cstr(line))
		}
	}
	*/
}

fn (mut this TextField) draw(g &GraphicsContext) {
	this.draw_background(g)

	xp := this.x + 4 + this.padding_x
	color := g.theme.text_color

	if this.carrot_left < 0 {
		this.carrot_left = 0
	}

	if this.carrot_left > this.text.len {
		this.carrot_left = this.text.len
	}

	cfg := gx.TextCfg{
		color: color
		size:  g.win.font_size
	}

	wid := g.text_width(this.text[0..this.carrot_left])

	pipe_color := if this.blinked && this.is_selected {
		g.theme.button_bg_hover
	} else {
		color
	}

	if this.width == 0 {
		width := g.text_width(this.text)
		this.width = width + 8 + this.padding_x
	}

	if !isnil(this.bind_val) {
		if this.text != this.bind_val {
			this.text = this.bind_val
		}
	}

	if this.center {
		// Y-center text
		th := g.line_height
		if this.height < th {
			this.height = min_h(g)
		}

		ycp := this.y + (this.height - th) / 2
		g.draw_text(xp, ycp, this.text, g.font, cfg)
		g.gg.draw_line(xp + wid, ycp, xp + wid, ycp + th, pipe_color)
		if this.reset_sel {
			this.draw_selection(g)
		}
	} else {
		g.draw_text(xp, this.y + 4, this.text, g.font, cfg)
		g.gg.draw_line(xp + wid, this.y + 2, xp + wid, this.y + g.line_height, pipe_color)
	}

	this.mouse_down_caret(g)
}

fn (mut this TextField) mouse_down_caret(g &GraphicsContext) {
	if !this.is_mouse_down {
		return
	}

	if this.reset_sel {
		this.sel = none
		this.reset_sel = false
	}

	x := if this.rx != 0 { this.rx } else { this.x }

	mx := g.win.mouse_x - x
	wid_char := g.text_width('A')
	full_wid := g.text_width(this.text)

	mut lv := 0

	if mx > full_wid {
		this.carrot_left = this.text.len
		lv = this.text.len
	}

	for i in 0 .. this.text.len + 1 {
		substr := this.text[0..i]
		wid := g.text_width(substr)

		if abs(mx - wid) <= wid_char {
			this.carrot_left = i
			lv = i
			break
		}
	}

	// Selection
	if this.sel == none {
		this.sel = Selection{
			x0: lv
			y0: 0
		}
	} else {
		this.sel.x1 = lv
		this.sel.y1 = 0
		this.draw_selection(g)
	}
}

fn (mut box TextField) draw_selection(g &GraphicsContext) {
	sel := box.sel or { return }
	ac := g.theme.accent_fill
	color := gx.rgba(ac.r, ac.g, ac.b, 100)

	// Same Line
	minx := if sel.x0 > sel.x1 { sel.x1 } else { sel.x0 }
	maxx := if sel.x0 > sel.x1 { sel.x0 } else { sel.x1 }

	if maxx > box.text.len {
		return
	}

	wba := g.text_width(box.text[0..minx].replace('\t', tabr()))
	wbb := g.text_width(box.text[minx..maxx].replace('\t', tabr()))
	x := box.x + box.padding_x + 4

	th := g.line_height + 4
	g.gg.draw_rect_filled(x + wba, box.y + (box.height - th) / 2, wbb, th, color)
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
	if mod == 2 {
		com.ctrl_down = true
	}
	if key == .backspace {
		com.text = com.text.substr_ni(0, com.carrot_left - 1) +
			com.text.substr_ni(com.carrot_left, com.text.len)
		com.update_bind()
		com.carrot_left -= 1
		com.ctrl_down = false
		invoke_text_change(com, w.graphics_context, 'text_change')
		return
	}

	if mod == 8 {
		// Windows Key
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
		invoke_text_change(com, w.graphics_context, 'text_change')
		// com.text_change_event_fn(w, com)
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
			if letter !in numbers_val {
				com.last_letter = letter
				invoke_text_change(com, w.graphics_context, 'text_change')
				// com.text_change_event_fn(w, com)
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
	invoke_text_change(com, w.graphics_context, 'text_change')
	// com.text_change_event_fn(w, com)
	com.ctrl_down = false
	unsafe {
		resu.free()
	}
}
