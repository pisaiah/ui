module iui

import gg
import gx

// Checkbox - implements Component interface
pub struct Switch {
	Component_A
pub mut:
	text string
	a    int
}

[params]
pub struct SwitchConfig {
	bounds   Bounds
	selected bool
	text     string
}

pub fn Switch.new(cf SwitchConfig) &Switch {
	return &Switch{
		text: cf.text
		x: cf.bounds.x
		y: cf.bounds.y
		width: cf.bounds.width
		height: cf.bounds.height
		is_selected: cf.selected
		a: if cf.selected { -1 } else { 0 }
	}
}

// Get border color
fn (this &Switch) get_border(is_hover bool, ctx &GraphicsContext) gx.Color {
	if this.is_mouse_down {
		return ctx.theme.button_border_click
	}

	if is_hover {
		return ctx.theme.button_border_hover
	}
	return ctx.theme.button_border_normal
}

// Get background color
fn (this &Switch) get_background(is_hover bool, ctx &GraphicsContext) gx.Color {
	if this.is_mouse_down {
		return ctx.theme.button_bg_click
	}

	if this.is_selected {
		return ctx.theme.checkbox_selected
	}

	if is_hover {
		return ctx.theme.button_bg_hover
	}

	return ctx.theme.checkbox_bg
}

// Draw Switch
pub fn (mut com Switch) draw(ctx &GraphicsContext) {
	// Draw Background & Border
	com.draw_background(ctx)

	// Detect click
	if com.is_mouse_rele {
		com.is_mouse_rele = false
		com.is_selected = !com.is_selected
	}

	if com.a == -1 {
		com.a = com.height
	}

	// Draw checkmark
	if com.is_selected {
		if com.a < com.height {
			com.a += 5
			mut win := ctx.win
			win.refresh_ui()
		}
		if com.a > com.height {
			com.a = com.height
		}
		com.draw_circ(0, ctx)
	} else {
		if com.a > 0 {
			com.a -= 5
			mut win := ctx.win
			win.refresh_ui()
		}
		if com.a < 0 {
			com.a = 0
		}
		com.draw_circ(2, ctx)
	}

	// Draw text
	com.draw_text(ctx)
}

// Draw background & border of Switch
fn (com &Switch) draw_background(ctx &GraphicsContext) {
	half_wid := com.width / 2
	half_hei := com.height / 2

	mid := com.x + half_wid
	midy := com.y + half_hei

	is_hover_x := abs(mid - ctx.win.mouse_x) < half_wid
	is_hover_y := abs(midy - ctx.win.mouse_y) < half_hei
	is_hover := is_hover_x && is_hover_y

	bg := com.get_background(is_hover, ctx)
	border := com.get_border(is_hover, ctx)

	bh := com.height * 2
	h := com.height // - 6
	y := com.y // + 3
	ctx.gg.draw_rounded_rect_filled(com.x, y, bh, h, 8, bg)
	ctx.gg.draw_rounded_rect_empty(com.x, y, bh, h, 8, border)
}

// Draw the text of Switch
fn (this &Switch) draw_text(ctx &GraphicsContext) {
	sizh := ctx.line_height / 2 // ctx.gg.text_height(this.text) / 2
	left := this.height * 2

	ctx.draw_text(this.x + left + 4, this.y + (this.height / 2) - sizh, this.text, ctx.font,
		gx.TextCfg{
		size: ctx.font_size
		color: ctx.theme.text_color
	})
}

fn (com &Switch) draw_circ(o int, g &GraphicsContext) {
	wid := com.height - 3
	x := com.x + com.a + o
	g.gg.draw_rounded_rect_filled(x, com.y + 1, wid, wid, 16, g.theme.button_bg_normal)
	g.gg.draw_rounded_rect_empty(x, com.y + 1, wid, wid, 16, g.theme.button_border_normal)
}
