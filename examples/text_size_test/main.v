module main

import iui as ui
import gg

[console]
fn main() {
	// Create Window
	mut window := ui.window_with_config(ui.get_system_theme(), 'My Window', 520, 500,
		ui.WindowConfig{
		//font_size: 18
	})

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)
	window.bar.add_child(ui.menuitem(' '))

	mut lbl := ui.label(window, 'Label test')
	lbl.set_bounds(16, 27, 500, 300)
	//lbl.pack()

	window.add_child(lbl)

	lbl.draw_event_fn = fn (mut win ui.Window, com &ui.Component) {
		mut this := *com

        current_gg := get_text(win, false)
        ours := get_text(win, true)

        if mut this is ui.Label {
            this.text = 'Current gg text_width:\n\t' + current_gg + '\n\nNew text_width:\n\t' + ours
            this.pack()
        }
	}

	window.gg.run()
}

fn get_text(win &ui.Window, use_custom bool) string {
	hello_world, hello_world_size := get_info(win.gg, 'Hello world this is a test lazy dog', use_custom)
	hello, hello_size := get_info(win.gg, 'Hello world this i', use_custom)
	world, world_size := get_info(win.gg, 's a test lazy dog', use_custom)

    total_ := hello_size.str() + ' + ' + world_size.str() + ' = '
	total := total_ + (hello_size + world_size).str() + ', should be equal to ' + hello_world_size.str()
	return [hello_world, hello, world, ' ', total].join('\n\t')
}

fn get_info(ctx &gg.Context, input string, use_custom bool) (string, int) {
	size := if use_custom { text_width(ctx, input) } else { ctx.text_width(input) }
	text := 'text_width of "' + input + '" is ' + size.str()
	return text, size
}

// text_width returns the width of the `string` `s` in pixels.
pub fn text_width(ctx &gg.Context, s string) int {
	$if macos {
		if ctx.native_rendering {
			return C.darwin_text_width(s)
		}
	}
	// ctx.set_cfg(cfg) TODO
	if !ctx.font_inited {
		return 0
	}
	mut buf := [4]f32{}
	ctx.ft.fons.text_bounds(0, 0, s, &buf[0])
	if s.ends_with(' ') {
		return int((buf[2] - buf[0]) / ctx.scale) +
			ctx.text_width('i') // TODO fix this in fontstash?
	}
	res := int((buf[2] + buf[0]) / ctx.scale)
    dump(s)
    dump(buf)
	// println('TW "$s" = $res')
	$if macos {
		if ctx.native_rendering {
			return res * 2
		}
	}
	return int((buf[2] + buf[0]) / ctx.scale)
}
