module iui

import gg
import gx

// Progress bar
struct Progressbar {
pub mut:
	app            &Window
	text           string
	x              int
	y              int
	width          int
	height         int
	last_click     f64
	click_event_fn fn (mut Window, Button)
	is_selected    bool
}

pub fn progressbar(app &Window, val f32) Progressbar {
	return Progressbar{
		app: app
		text: val.str()
	}
}

pub fn (mut bar Progressbar) draw() {
	mut wid := bar.width * (0.01 * bar.text.f32())
	bar.app.gg.draw_rounded_rect(bar.x, bar.y, wid, bar.height, 4, bar.app.theme.progressbar_fill)
	bar.app.gg.draw_empty_rounded_rect(bar.x, bar.y, bar.width, bar.height, 4, bar.app.theme.button_border_normal)

	text := bar.text + '%'
	size := bar.app.gg.text_width(text) / 2
	sizh := bar.app.gg.text_height(text) / 2

	bar.app.gg.draw_text((bar.x + (bar.width / 2)) - size, bar.y + (bar.height / 2) - sizh,
		text, gx.TextCfg{
		size: 14
		color: bar.app.theme.text_color
	})
}
