module iui

import gg
import gx

// Progress bar - implements Component interface
struct Progressbar {
pub mut:
	win            &Window
	text           string
	x              int
	y              int
	width          int
	height         int
	last_click     f64
	click_event_fn fn (mut Window, Button)
	is_selected    bool
	carrot_index   int = 1
    z_index        int
}

// Return new Progressbar
pub fn progressbar(win &Window, val f32) Progressbar {
	return Progressbar{
		win: win
		text: val.str()
	}
}

// Draw this component
pub fn (mut bar Progressbar) draw() {
	mut wid := bar.width * (0.01 * bar.text.f32())
	bar.win.gg.draw_rounded_rect(bar.x, bar.y, wid, bar.height, 4, bar.win.theme.progressbar_fill)
	bar.win.gg.draw_empty_rounded_rect(bar.x, bar.y, bar.width, bar.height, 4, bar.win.theme.button_border_normal)

	text := bar.text + '%'
	size := bar.win.text_width(text) / 2
	sizh := bar.win.text_height(text) / 2

	bar.win.gg.draw_text((bar.x + (bar.width / 2)) - size, bar.y + (bar.height / 2) - sizh,
		text, gx.TextCfg{
		size: 14
		color: bar.win.theme.text_color
	})
}
