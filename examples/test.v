import iui as ui
import gg

[console]
fn main() {
	// Set UI Theme
	theme := ui.theme_dark_hc()

	mut app := ui.window(theme)

	app.bar = ui.menubar(app, app.theme)
	app.bar.items << ui.menuitem('File')
	app.bar.items << ui.menuitem('Edit')

	mut help := ui.menuitem('Help')
	mut theme_menu := ui.menuitem('Themes')
	mut about := ui.menuitem('About iUI')

	for i := 0; i < 3; i++ {
		mut item := ui.menuitem('Item ' + i.str())
		help.items << item
	}

	mut themes := [ui.theme_default(), ui.theme_dark(), ui.theme_dark_hc(),
		ui.theme_black_red()]
	for theme2 in themes {
		mut item := ui.menuitem(theme2.name)
		item.set_click(theme_click)
		theme_menu.items << item
	}

	help.items << about
	app.bar.items << help
	app.bar.items << theme_menu

	mut btn := ui.button(app, 'Hello')
	btn.x = 40
	btn.y = 40
	btn.height = 25
	btn.width = 100

	btn.set_click(on_click)

	app.components << btn

	mut btn2 := ui.button(app, 'Hello')
	btn2.x = 280
	btn2.y = 280
	btn2.height = 25
	btn2.width = 100

	app.components << btn2

	app.gg.run()
}

fn on_click(mut win ui.Window, com ui.Button) {
	println('on_click')
}

fn theme_click(mut win ui.Window, com ui.MenuItem) {
	mut text := com.text
	println(text)
	mut theme := ui.theme_default()
	match text {
		'Default' { theme = ui.theme_default() }
		'Dark' { theme = ui.theme_dark() }
		'Dark High Contrast' { theme = ui.theme_dark_hc() }
		'Black Red' { theme = ui.theme_black_red() }
		else { println('Theme not found: ' + text) }
	}
	win.set_theme(theme)
}
