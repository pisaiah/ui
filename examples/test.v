import iui as ui
import gg

[console]
fn main() {
	// Set UI Theme
	theme := ui.theme_default()

	mut window := ui.window(theme)
	window.init()

	window.bar = ui.menubar(window, window.theme)
	window.bar.items << ui.menuitem('File')
	window.bar.items << ui.menuitem('Edit')

	mut help := ui.menuitem('Help')
	mut theme_menu := ui.menuitem('Themes')
	mut about := ui.menuitem('About iUI')

	for i := 0; i < 3; i++ {
		mut item := ui.menuitem('Item ' + i.str())
		help.items << item
	}

	mut themes := [ui.theme_default(), ui.theme_dark(), ui.theme_dark_hc(),
		ui.theme_black_red(), ui.theme_minty()]
	for theme2 in themes {
		mut item := ui.menuitem(theme2.name)
		item.set_click(theme_click)
		theme_menu.items << item
	}

	help.items << about
	window.bar.items << help
	window.bar.items << theme_menu

	mut btn := ui.button(window, 'A Button')
	btn.x = 30
	btn.y = 40
	btn.height = 25
	btn.width = 100

	btn.set_click(on_click)

	window.components << btn

	mut btn2 := ui.button(window, 'Hello')
	btn2.x = 30
	btn2.y = 70
	btn2.height = 25
	btn2.width = 100

	window.components << btn2

	mut tbox := ui.textbox(window, 'This is a Textbox.')
	tbox.x = 30
	tbox.y = 110
	tbox.width = 320
	tbox.height = 100

	window.components << tbox

	mut cbox := ui.checkbox(window, 'Check me!')
	cbox.x = 150
	cbox.y = 40
	cbox.width = 25
	cbox.height = 25

	mut cbox2 := ui.checkbox(window, 'Check me!')
	cbox2.x = 150
	cbox2.y = 70
	cbox2.width = 25
	cbox2.height = 25
	cbox2.is_selected = true

	window.components << cbox
	window.components << cbox2

	window.gg.run()
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
		'Minty' { theme = ui.theme_minty() }
		else { println('Theme not found: ' + text) }
	}
	win.set_theme(theme)
}
