import gg
import iui as ui
import gx

fn main() {
	// Create Window
	mut window := ui.Window.new(theme: ui.get_system_theme(), title: 'Test', width: 400, height: 300)

	mut lbl := ui.label(window, 'Text Width Test:')
	lbl.set_pos(4, 4)
	lbl.pack()

	lbl.draw_event_fn = fn (mut win ui.Window, com &ui.Component) {
		mut y := 30
		y += test_sen(win, y, 'The quick brown fox jumps over the lazy dog')
		y += test_sen(win, y, 'public static void main(String[] args) {}')
		y += test_sen(win, y, 'Hello world, this is a test!')
	}

	// Show Window
	window.add_child(lbl)
	window.gg.run()
}

fn test_sen(win &ui.Window, sy int, full string) int {
	words := full.split(' ')
	win.gg.draw_text(10, sy, full)

	x0 := text_width(win, full + ' ')
	x2 := text_width2(win, full + ' ')

	black := gx.TextCfg{
		color: gx.black
	}
	blue := gx.TextCfg{
		color: gx.blue
	}
	orang := gx.TextCfg{
		color: gx.rgb(0, 150, 0)
	}

	mut x := 0
	mut x1 := 0
	for word in words {
		wo := word + ' '
		win.gg.draw_text(10 + x1, sy + 2, wo, orang)
		win.gg.draw_text(10 + x, sy + 5, wo, blue)
		x += text_width(win, wo)
		x1 += int(text_width2(win, wo))
	}
	win.gg.draw_text(10, sy + 20, 'A: ${x0}, B ${x2}, C: ${x}, D: ${x1}', black)
	return 40
}

pub fn text_width(win &ui.Window, text string) int {
	return win.gg.text_width(text)
}

// why is this not the default?
pub fn text_width2(win &ui.Window, text string) int {
	ctx := win.gg
	adv := ctx.ft.fons.text_bounds(0, 0, text, &f32(0))
	return int(adv / ctx.scale)
}

// on click event function
// The Label we want to update is sent as data.
fn on_click(win &ui.Window, btn voidptr, data voidptr) {
	println('Click!')
}
