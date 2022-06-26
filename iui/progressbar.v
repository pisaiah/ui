module iui

import gg
import gx

// Progress bar - implements Component interface
pub struct Progressbar {
	Component_A
pub mut:
	text           string
	click_event_fn fn (mut Window, Button)
}

// Return new Progressbar
pub fn progressbar(val f32) &Progressbar {
	return &Progressbar{
		text: val.str()
	}
}

// Draw this component
pub fn (mut bar Progressbar) draw(ctx &GraphicsContext) {
	wid := bar.width * (0.01 * bar.text.f32())
	ctx.gg.draw_rounded_rect_filled(bar.x, bar.y, wid, bar.height, 4, ctx.theme.checkbox_selected)
	ctx.gg.draw_rounded_rect_empty(bar.x, bar.y, bar.width, bar.height, 4, ctx.theme.button_border_normal)

	bar.draw_text(ctx)
}

fn (bar &Progressbar) draw_text(ctx &GraphicsContext) {
	text := bar.text + '%'
	size := ctx.gg.text_width(text) / 2
	sizh := ctx.gg.text_height(text) / 2

	ctx.draw_text((bar.x + (bar.width / 2)) - size, bar.y + (bar.height / 2) - sizh, text,
		ctx.font, gx.TextCfg{
		size: ctx.font_size
		color: ctx.theme.text_color
	})
}
