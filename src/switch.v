module iui

import gx

// Checkbox - implements Component interface
pub struct Switch {
	Component_A
pub mut:
	pack     bool
	text     string
	bind_val &bool = unsafe { nil }
	cut      int   = 4
	thumb_x  int
}

pub fn (mut s Switch) get_thumb_x(g &GraphicsContext) int {
	if s.is_selected && s.thumb_x < s.height + s.cut {
		s.thumb_x += 2
		g.refresh_ui()
	}

	if !s.is_selected && s.thumb_x > s.cut {
		s.thumb_x -= 2
		g.refresh_ui()
	}

	return s.x + s.thumb_x
}

pub fn (mut s Switch) bind_to(val &bool) {
	unsafe {
		s.bind_val = val
	}
}

pub fn (mut s Switch) update_bind() {
	if isnil(s.bind_val) {
		return
	}

	unsafe {
		*s.bind_val = s.is_selected
	}
}

@[params]
pub struct SwitchConfig {
pub:
	bounds   Bounds
	selected bool
	text     string
}

pub fn Switch.new(cf SwitchConfig) &Switch {
	return &Switch{
		text:        cf.text
		x:           cf.bounds.x
		y:           cf.bounds.y
		width:       cf.bounds.width
		height:      cf.bounds.height
		is_selected: cf.selected
		thumb_x:     0
		pack:        true
	}
}

// Get border color
fn (this &Switch) get_border(is_hover bool, g &GraphicsContext) gx.Color {
	if this.is_mouse_down {
		return g.theme.accent_fill_third
	}

	if is_hover {
		return g.theme.accent_fill_second
	}
	return g.theme.button_border_normal
}

// Get background color
fn (this &Switch) get_background(is_hover bool, g &GraphicsContext) gx.Color {
	if this.is_selected {
		if this.is_mouse_down {
			return g.theme.accent_fill_third
		}
		if is_hover {
			return g.theme.accent_fill_second
		}
		return g.theme.accent_fill
	}

	if this.is_mouse_down {
		return g.theme.button_bg_click
	}

	if this.is_selected {
		return g.theme.accent_fill
	}

	if is_hover {
		return g.theme.button_bg_hover
	}

	return g.theme.button_bg_normal
}

// Draw Switch
pub fn (mut sw Switch) draw(g &GraphicsContext) {
	// Draw Background & Border
	sw.draw_background(g)

	// Detect click
	if sw.is_mouse_rele {
		sw.is_mouse_rele = false
		sw.is_selected = !sw.is_selected
		invoke_switch(sw, g)
		sw.update_bind()
	}

	if !isnil(sw.bind_val) {
		if sw.is_selected != sw.bind_val {
			sw.is_selected = sw.bind_val
		}
	}

	if sw.pack && sw.height == 0 {
		// WinUI3 design
		sw.width = g.text_width(sw.text) + 48
		sw.height = 20
	}

	// Pack width
	if sw.width == 0 && sw.height > 0 {
		sw.width = (sw.height * 2) + g.text_width(sw.text) + 8
	}

	if sw.thumb_x == 0 {
		sw.thumb_x = if sw.is_selected { sw.height + sw.cut } else { sw.cut }
	}

	// Draw thumb/handle
	tx := sw.get_thumb_x(g)
	wid := sw.height - sw.cut * 2

	fill_color := if sw.is_selected { g.theme.button_bg_normal } else { g.theme.text_color }

	g.gg.draw_rounded_rect_filled(tx, sw.y + sw.cut, wid, wid, 64, g.theme.button_border_normal)
	g.gg.draw_rounded_rect_filled(tx + 1, sw.y + sw.cut + 1, wid - 2, wid - 2, 64, fill_color)

	// Draw text
	sw.draw_text(g)
}

// Draw background & border of Switch
fn (sw &Switch) draw_background(g &GraphicsContext) {
	is_hover := is_in(sw, g.win.mouse_x, g.win.mouse_y)

	bg := sw.get_background(is_hover, g)
	border := sw.get_border(is_hover, g)

	bh := sw.height * 2
	h := sw.height

	g.gg.draw_rounded_rect_filled(sw.x, sw.y, bh, h, 16, border)
	g.gg.draw_rounded_rect_filled(sw.x + 1, sw.y + 1, bh - 2, h - 2, 16, bg)
}

// Draw the text of Switch
fn (this &Switch) draw_text(ctx &GraphicsContext) {
	sizh := ctx.line_height / 2 // ctx.gg.text_height(this.text) / 2
	left := this.height * 2

	ctx.draw_text(this.x + left + 4, this.y + (this.height / 2) - sizh, this.text, ctx.font,
		gx.TextCfg{
		size:  ctx.font_size
		color: ctx.theme.text_color
	})
}

fn (sw &Switch) draw_circ(o int, g &GraphicsContext) {
}

pub struct SwitchEvent {
	ComponentEventGeneric[Switch]
}

pub fn invoke_switch(sw &Switch, ctx &GraphicsContext) {
	ev := SwitchEvent{
		target: sw
		ctx:    ctx
	}

	for f in sw.events.event_map['change'] {
		f(ev)
	}
}
