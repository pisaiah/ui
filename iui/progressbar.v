module iui

import gg
import gx

// Progress bar - implements Component interface
struct Progressbar {
	Component_A
pub mut:
	win            &Window
	text           string
	click_event_fn fn (mut Window, Button)
}

// Return new Progressbar
pub fn progressbar(win &Window, val f32) &Progressbar {
	return &Progressbar{
		win: win
		text: val.str()
	}
}

// Draw this component
pub fn (mut bar Progressbar) draw() {
	mut wid := bar.width * (0.01 * bar.text.f32())
	bar.win.gg.draw_rounded_rect_filled(bar.x, bar.y, wid, bar.height, 4, bar.win.theme.checkbox_selected)
	bar.win.gg.draw_rounded_rect_empty(bar.x, bar.y, bar.width, bar.height, 4, bar.win.theme.button_border_normal)

	text := bar.text + '%'
	size := text_width(bar.win, text) / 2
	sizh := text_height(bar.win, text) / 2

	bar.win.gg.draw_text((bar.x + (bar.width / 2)) - size, bar.y + (bar.height / 2) - sizh,
		text, gx.TextCfg{
		size: bar.win.font_size
		color: bar.win.theme.text_color
	})
}
