module iui

import gg
import gx

// Checkbox - implements Component interface
pub struct Checkbox {
	Component_A
}

@[params]
pub struct CheckboxConfig {
pub:
	bounds   Bounds
	selected bool
	text     string
}

pub fn Checkbox.new(conf CheckboxConfig) &Checkbox {
	return &Checkbox{
		text:        conf.text
		x:           conf.bounds.x
		y:           conf.bounds.y
		width:       conf.bounds.width
		height:      conf.bounds.height
		is_selected: conf.selected
	}
}

// Get border color
fn (this &Checkbox) get_border(is_hover bool, ctx &GraphicsContext) gx.Color {
	if this.is_mouse_down {
		return ctx.theme.button_border_click
	}

	if is_hover {
		return ctx.theme.button_border_hover
	}
	return ctx.theme.button_border_normal
}

// Get background color
fn (this &Checkbox) get_background(is_hover bool, ctx &GraphicsContext) gx.Color {
	if this.is_mouse_down {
		return ctx.theme.button_bg_click
	}

	if is_hover {
		return ctx.theme.button_bg_hover
	}
	return ctx.theme.checkbox_bg
}

// Draw checkbox
pub fn (mut com Checkbox) draw(ctx &GraphicsContext) {
	// Draw Background & Border
	com.draw_background(ctx)

	// Detect click
	if com.is_mouse_rele {
		com.is_mouse_rele = false
		com.is_selected = !com.is_selected
	}

	// Draw checkmark
	if com.is_selected {
		com.draw_checkmark(ctx)
	}

	// Draw text
	com.draw_text(ctx)
}

// Draw background & border of Checkbox
fn (com &Checkbox) draw_background(ctx &GraphicsContext) {
	half_wid := com.width / 2
	half_hei := com.height / 2

	mid := com.x + half_wid
	midy := com.y + half_hei

	is_hover_x := abs(mid - ctx.win.mouse_x) < half_wid
	is_hover_y := abs(midy - ctx.win.mouse_y) < half_hei
	is_hover := is_hover_x && is_hover_y

	bg := com.get_background(is_hover, ctx)
	border := com.get_border(is_hover, ctx)

	ctx.win.draw_bordered_rect(com.x, com.y, com.height, com.height, 8, bg, border)
}

// Draw the text of Checkbox
fn (this &Checkbox) draw_text(ctx &GraphicsContext) {
	sizh := ctx.gg.text_height(this.text) / 2

	ctx.draw_text(this.x + this.height + 4, this.y + (this.height / 2) - sizh, this.text,
		ctx.font, gx.TextCfg{
		size:  ctx.font_size
		color: ctx.theme.text_color
	})
}

// TODO: Better Checkmark
fn (com &Checkbox) draw_checkmark(ctx &GraphicsContext) {
	cut := 0
	wid := com.height - (cut * 2)

	ctx.gg.draw_rounded_rect_filled(com.x + cut, com.y + cut, wid, wid, 8, ctx.theme.checkbox_selected)

	// Use Checkmark SVG if icon set loaded
	if ctx.icon_ttf_exists() {
		h := com.height / 2
		ctx.draw_text_ofset(com.x, com.y, h, h, '\uea11', gx.TextCfg{
			size:           ctx.win.font_size
			color:          gx.white
			family:         ctx.win.extra_map['icon_ttf']
			align:          .center
			vertical_align: .middle
		})
		ctx.reset_text_font()

		return
	}

	ctx.gg.draw_image_with_config(gg.DrawImageConfig{
		img_id:   ctx.icon_cache['check_box']
		img_rect: gg.Rect{com.x + 2, com.y + 2, com.height - 5, com.height - 5}
	})

	// draw_checkmark(com.x, com.y, com.height, com.height, 4, gx.green, ctx)
}

fn draw_checkmark(x f32, y f32, width f32, height f32, check_padding f32, c gx.Color, ctx &GraphicsContext) {
	// Calculate the coordinates for the checkmark
	start_x := x + check_padding
	start_y := y + (height / 2)
	mid_x := x + (width / 3)
	mid_y := y + height - check_padding
	end_x := x + width - check_padding
	end_y := y + check_padding

	// Draw the checkmark lines
	ctx.gg.draw_line(start_x, start_y, mid_x, mid_y, c)
	ctx.gg.draw_line(mid_x, mid_y, end_x, end_y, c)
}
