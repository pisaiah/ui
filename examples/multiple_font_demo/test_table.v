import gg
import iui as ui
import os

const (
	txt_text = 'The quick brown fox jumps over the lazy dog. 1234567890'
)

[console]
fn main() {
	mut app_data := &App{}
	app_data.fonts = FontSet{}

	// Create Window
	mut window := ui.window_with_config(ui.get_system_theme(), 'My Window', 600, 350,
		ui.WindowConfig{
		font_path: 'C:/windows/fonts/segoeui.ttf'
		ui_mode: true
		font_size: 18
	})

	window.id_map['data'] = app_data

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)

	mut fonts_menu := ui.menu_item(
		text: 'Fonts'
	)

	sys_font_paths := os.glob('C:/windows/fonts/*.ttf') or { panic(err) }
	mut font_paths := os.glob('./examples/multiple_font_demo/*.ttf') or { panic(err) }
	mut sys_paths := []string{}
	font_paths << 'segoeui.ttf'
	font_paths << 'arial.ttf'
	font_paths << 'calibri.ttf'

	for path in sys_font_paths {
		low := path.to_lower()

		// if sys_paths.len > 70 {
		//	break
		//}
		if low.ends_with('b.ttf') || low.ends_with('bi.ttf') {
			continue
		}
		if sys_paths.contains(low.replace('i.ttf', '')) {
			continue
		}
		sys_paths << path
	}

	for path in font_paths {
		fonts_menu.add_child(ui.menu_item(
			text: path
			click_event_fn: change_font
		))
	}

	mut m := map[string]&ui.MenuItem{}

	mut ab_menu := ui.menu_item(text: 'A-B')
	mut cd_menu := ui.menu_item(text: 'C-D')
	mut ef_menu := ui.menu_item(text: 'E-F')
	mut gh_menu := ui.menu_item(text: 'G-H')
	mut ij_menu := ui.menu_item(text: 'I-J')
	mut kl_menu := ui.menu_item(text: 'K-L')

	m['a'] = ab_menu
	m['b'] = ab_menu
	m['c'] = cd_menu
	m['d'] = cd_menu
	m['e'] = ef_menu
	m['f'] = ef_menu
	m['g'] = gh_menu
	m['h'] = gh_menu
	m['i'] = ij_menu
	m['j'] = ij_menu
	m['k'] = kl_menu
	m['l'] = kl_menu
	m['m'] = fonts_menu
	m['n'] = fonts_menu
	m['o'] = fonts_menu
	m['p'] = fonts_menu
	m['q'] = fonts_menu
	m['r'] = fonts_menu
	m['s'] = fonts_menu
	m['t'] = fonts_menu
	m['u'] = fonts_menu
	m['v'] = fonts_menu
	m['w'] = fonts_menu
	m['x'] = fonts_menu
	m['y'] = fonts_menu
	m['z'] = fonts_menu

	for path in sys_paths {
		elem := ui.menu_item(
			text: path
			click_event_fn: change_font
		)
		low := path.to_lower()
		first := low.substr(0, 1)
		dump(first)
		m[first].add_child(elem)
	}

	window.bar.add_child(fonts_menu)
	window.bar.add_child(ab_menu)
	window.bar.add_child(cd_menu)
	window.bar.add_child(ef_menu)
	window.bar.add_child(gh_menu)

	mut lbl := ui.label(window, txt_text)
	lbl.set_bounds(4, 49, 50, 30)
	lbl.pack()
	lbl.draw_event_fn = fn (mut win ui.Window, com &ui.Component) {
		mut app := &App(win.id_map['data'])

		font := app.fonts.hash['symbol']

		mut this := *com
		this.set_font(font)
	}
	window.add_child(lbl)

	window.gg.run()
}

fn change_font(mut win ui.Window, item ui.MenuItem) {
	println('change_font')
	mut app := &App(win.id_map['data'])

	path := if item.text.contains('System ') {
		os.join_path('C:/windows/fonts/', item.text.split('System ')[1])
	} else {
		os.resource_abs_path(item.text)
	}

	if !os.exists(path) {
		app.add_font(mut win, 'symbol', os.join_path('C:/windows/fonts/', item.text))
	}

	app.add_font(mut win, 'symbol', path)
}

// fonts
struct FontSet {
mut:
	hash map[string]int
}

struct App {
mut:
	fonts FontSet
}

pub fn (mut app App) add_font(mut ui ui.Window, font_name string, font_path string) {
	bytes := os.read_bytes(font_path) or { []u8{} }

	if bytes.len > 0 {
		font := ui.gg.ft.fons.add_font_mem('sans', bytes, false)
		if font >= 0 {
			app.fonts.hash[font_name] = font
			ui.gg.ft.fons.set_font(font)
		} else {
			// Error
		}
	} else {
		// Unreadable
	}
}
