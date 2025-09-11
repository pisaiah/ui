module iui

import gg

// Progress bar - implements Component interface
pub struct Progressbar {
	Component_A
pub mut:
	text     string
	bind_val &f32
}

@[params]
pub struct ProgressbarConfig {
pub mut:
	val  f32
	bind ?&f32
}

// Return new Progressbar
pub fn Progressbar.new(c ProgressbarConfig) &Progressbar {
	return &Progressbar{
		text:     c.val.str()
		bind_val: c.bind or { unsafe { nil } }
	}
}

pub fn (mut this Progressbar) bind_to(val &f32) {
	unsafe {
		this.bind_val = val
	}
}

pub fn (bar &Progressbar) get_val() f32 {
	if isnil(bar.bind_val) {
		return bar.text.f32()
	} else {
		return *bar.bind_val
	}
}

// Draw this component
pub fn (mut bar Progressbar) draw(g &GraphicsContext) {
	val := bar.get_val()
	wid := bar.width * (0.01 * val)

	g.gg.draw_rounded_rect_filled(bar.x, bar.y, bar.width, bar.height, 4, g.theme.button_border_normal)
	g.gg.draw_rounded_rect_filled(bar.x + 1, bar.y + 1, wid - 2, bar.height - 2, 4, g.theme.accent_fill)

	c := if wid > bar.width / 2 { g.theme.accent_text } else { g.theme.text_color }

	bar.draw_text(g, val, c)
}

fn (bar &Progressbar) draw_text(g &GraphicsContext, val f32, c gg.Color) {
	text := '${val}%'
	size := g.gg.text_width(text) / 2
	sizh := g.line_height / 2

	g.draw_text((bar.x + (bar.width / 2)) - size, bar.y + (bar.height / 2) - sizh, text,
		g.font, gg.TextCfg{
		size:  g.font_size
		color: c
	})
}
