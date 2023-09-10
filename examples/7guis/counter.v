// Based on the Counter example at
// https://eugenkiss.github.io/7guis/tasks
import gg
import iui as ui

[heap]
struct App {
mut:
	lbl &ui.Label
}

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title: 'Counter'
		width: 230
		height: 200
	)

	// Create an Panel
	mut p := ui.Panel.new(
		// Vertical Box layout
		layout: ui.BoxLayout.new(ori: 1)
	)

	// Create the Label
	mut lbl := ui.Label.new(text: '0')
	lbl.pack()

	// Create Count Button
	mut btn := ui.button(
		text: 'Count'
		should_pack: true
	)

	mut app := &App{
		lbl: lbl
	}

	btn.subscribe_event('mouse_up', app.btn_click_fn)

	// Add to panel
	p.add_child(lbl)
	p.add_child(btn)

	// Show Window
	window.add_child(p)
	window.gg.run()
}

fn (mut app App) btn_click_fn(mut e ui.MouseEvent) {
	current_value := app.lbl.text.int()
	app.lbl.text = (current_value + 1).str()
	app.lbl.pack()
}
