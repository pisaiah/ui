module iui

import gg

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
	on_click ?fn (voidptr)
}

pub fn Checkbox.new(c CheckboxConfig) &Checkbox {
	mut b := &Checkbox{
		text:        c.text
		x:           c.bounds.x
		y:           c.bounds.y
		width:       c.bounds.width
		height:      c.bounds.height
		is_selected: c.selected
	}
	if c.on_click != none {
		b.subscribe_event('mouse_up', c.on_click)
	}
	return b
}

// Get border color
fn (cb &Checkbox) get_border(is_hover bool, g &GraphicsContext) gg.Color {
	if cb.is_mouse_down {
		return g.theme.accent_fill_third
	}

	if cb.is_selected {
		if is_hover {
			return g.theme.accent_fill_third
		}
		return g.theme.accent_fill
	}

	if is_hover {
		return g.theme.accent_fill_second
	}

	return g.theme.button_border_normal
}

// Get background color
fn (cb &Checkbox) get_background(is_hover bool, g &GraphicsContext) gg.Color {
	if cb.is_selected {
		if cb.is_mouse_down {
			return g.theme.accent_fill_third
		}
		if is_hover {
			return g.theme.accent_fill_second
		}
		return g.theme.accent_fill
	}

	if cb.is_mouse_down {
		return g.theme.button_bg_click
	}

	if is_hover {
		return g.theme.button_bg_hover
	}

	return g.theme.background
}

// Draw checkbox
pub fn (mut cb Checkbox) draw(g &GraphicsContext) {
	// Draw Background & Border
	cb.draw_background(g)

	// Detect click
	if cb.is_mouse_rele {
		cb.is_mouse_rele = false
		cb.is_selected = !cb.is_selected
	}

	// Draw checkmark
	if cb.is_selected {
		cb.draw_checkmark(g)
	}

	// Draw text
	cb.draw_text(g)
}

// Draw background & border of Checkbox
fn (cb &Checkbox) draw_background(g &GraphicsContext) {
	half_wid := cb.width / 2
	half_hei := cb.height / 2

	mid := cb.x + half_wid
	midy := cb.y + half_hei

	is_hover_x := abs(mid - g.win.mouse_x) < half_wid
	is_hover_y := abs(midy - g.win.mouse_y) < half_hei
	is_hover := is_hover_x && is_hover_y

	bg := cb.get_background(is_hover, g)
	border := cb.get_border(is_hover, g)

	g.draw_rounded_rect(cb.x, cb.y, cb.height, cb.height, control_corner_radius, border,
		bg)
}

// Draw the text of Checkbox
fn (cb &Checkbox) draw_text(g &GraphicsContext) {
	sizh := g.gg.text_height(cb.text) / 2

	g.draw_text(cb.x + cb.height + 4, cb.y + (cb.height / 2) - sizh, cb.text, g.font,
		gg.TextCfg{
		size:  g.font_size
		color: g.theme.text_color
	})
}

// TODO: Better Checkmark
fn (cb &Checkbox) draw_checkmark(g &GraphicsContext) {
	// Use Checkmark SVG if icon set loaded
	if g.icon_ttf_exists() {
		h := cb.height / 2
		g.draw_text_ofset(cb.x, cb.y, h, h, '\uea11', gg.TextCfg{
			size:           g.win.font_size
			color:          gg.white
			family:         g.win.extra_map['icon_ttf']
			align:          .center
			vertical_align: .middle
		})
		g.reset_text_font()

		return
	}

	g.gg.draw_image_with_config(gg.DrawImageConfig{
		img_id:   g.icon_cache['check_box']
		img_rect: gg.Rect{cb.x + 2, cb.y + 2, cb.height - 5, cb.height - 5}
	})
}

fn draw_checkmark(x f32, y f32, w f32, h f32, check_padding f32, c gg.Color, g &GraphicsContext) {
	// Calculate the coordinates for the checkmark
	start_x := x + check_padding
	start_y := y + (h / 2)
	mid_x := x + (w / 3)
	mid_y := y + h - check_padding
	end_x := x + w - check_padding
	end_y := y + check_padding

	// Draw the checkmark lines
	g.gg.draw_line(start_x, start_y, mid_x, mid_y, c)
	g.gg.draw_line(mid_x, mid_y, end_x, end_y, c)
}
