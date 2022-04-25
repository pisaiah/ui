module iui

import gg
import gx

// Checkbox - implements Component interface
struct Checkbox {
	Component_A
pub mut:
	app            &Window
	text           string
	click_event_fn fn (mut Window, Checkbox)
}

[params]
pub struct CheckboxConfig {
	bounds    Bounds
	user_data voidptr
	selected  bool
}

pub fn checkbox(app &Window, text string, conf CheckboxConfig) Checkbox {
	return Checkbox{
		text: text
		app: app
		x: conf.bounds.x
		y: conf.bounds.y
		width: conf.bounds.width
		height: conf.bounds.height
		is_selected: conf.selected
		click_event_fn: blank_event_cbox
	}
}

pub fn (mut com Checkbox) set_click(b fn (mut Window, Checkbox)) {
	com.click_event_fn = b
}

pub fn blank_event_cbox(mut win Window, a Checkbox) {
}

// Get border color
fn (this &Checkbox) get_border(is_hover bool) gx.Color {
	if this.is_mouse_down {
		return this.app.theme.button_border_click
	}

	if is_hover {
		return this.app.theme.button_border_hover
	}
	return this.app.theme.button_border_normal
}

// Get background color
fn (this &Checkbox) get_background(is_hover bool) gx.Color {
	if this.is_mouse_down {
		return this.app.theme.button_bg_click
	}

	if is_hover {
		return this.app.theme.button_bg_hover
	}
	return this.app.theme.checkbox_bg
}

// Draw checkbox
pub fn (mut com Checkbox) draw(ctx &GraphicsContext) {
	// Draw Background & Border
	com.draw_background()

	// Detect click
	if com.is_mouse_rele {
		com.is_mouse_rele = false
		com.is_selected = !com.is_selected
		com.click_event_fn(com.app, *com)
	}

	// Draw checkmark
	if com.is_selected {
		com.draw_checkmark()
	}

	// Draw text
	com.draw_text()
}

// Draw background & border of Checkbox
fn (com &Checkbox) draw_background() {
	half_wid := com.width / 2
	half_hei := com.height / 2

	mid := com.x + half_wid
	midy := com.y + half_hei

	is_hover_x := abs(mid - com.app.mouse_x) < half_wid
	is_hover_y := abs(midy - com.app.mouse_y) < half_hei
	is_hover := is_hover_x && is_hover_y

	bg := com.get_background(is_hover)
	border := com.get_border(is_hover)

	com.app.draw_bordered_rect(com.x, com.y, com.height, com.height, 2, bg, border)
}

// Draw the text of Checkbox
fn (this &Checkbox) draw_text() {
	sizh := this.app.gg.text_height(this.text) / 2
	this.app.gg.draw_text(this.x + this.height + 4, this.y + (this.height / 2) - sizh,
		this.text, gx.TextCfg{
		size: this.app.font_size
		color: this.app.theme.text_color
	})
}

// TODO: Better Checkmark
fn (com &Checkbox) draw_checkmark() {
	cut := 4
	com.app.draw_bordered_rect(com.x + cut, com.y + cut, com.height - (cut * 2), com.height - (cut * 2),
		2, com.app.theme.checkbox_selected, com.app.theme.checkbox_selected)
}
