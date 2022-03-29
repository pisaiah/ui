import gg
import iui as ui

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.get_system_theme(), 'My Window', 520, 500)

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)
	window.bar.add_child(ui.menuitem(' '))

	mut table := ui.table(window, 10, 10)
	table.set_bounds(0, 25, 500, 565)

	mut lbl := ui.label(window, 'Label test')
	lbl.set_bounds(0, 25, 50, 30)
	lbl.pack()
	table.set_content(0, 1, lbl)

	window.add_child(table)

	window.gg.run()
}
