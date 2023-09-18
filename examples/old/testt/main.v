module main

import iui as ui

struct App {
	win &ui.Window
}

fn main() {
	mut win := ui.make_window(
		title: 'Button Demo'
		width: 520
		height: 400
	)

	mut app := &App{
		win: win
	}

	win.set_theme(ui.theme_ocean())

	mut hbox := ui.HBox.new()

	// Set bounds for the button; If `bounds` is not
	// set, then the button will pack to the text size.
	button_bounds := ui.Bounds{5, 5, 100, 30}

	mut left_button := ui.button(
		text: 'Left Button'
		bounds: button_bounds
	)

	mut mid_button := ui.button(
		text: 'Middle Button'
		bounds: button_bounds
	)

	mut right_button := ui.button(
		text: 'Right Button'
		bounds: button_bounds
	)

	right_button.subscribe_event('mouse_up', right_button_clicked)

	hbox.add_child(left_button)
	hbox.add_child(mid_button)
	hbox.add_child(right_button)

	hbox.pack()

	tb := app.make_selectbox_section()
	win.add_child(tb)

	tb1 := app.make_select_box_section()
	win.add_child(tb1)

	win.add_child(hbox)

	win.run()
}

fn (mut app App) make_selectbox_section() &ui.Titlebox {
	mut sel := ui.selector(app.win, 'Selectbox')
	sel.set_bounds(0, 0, 100, 25)

	for i := 0; i < 3; i++ {
		sel.items << (25 * (i + 1)).str() + '%'
	}

	// sel.set_change(sel_change)
	mut title_box := ui.title_box('Selector', [sel])
	title_box.set_bounds(8, 40, 120, 150)

	// app.pane.add_child(title_box)
	mut btn := ui.button(
		text: 'Hello'
		bounds: ui.Bounds{0, 70, 60, 40}
	)
	btn.subscribe_event('mouse_up', fn (mut e ui.MouseEvent) {
		dump('CLICK!')
	})
	title_box.add_child(btn)

	return title_box
}

fn (mut app App) make_select_box_section() &ui.Titlebox {
	mut sel := ui.select_box(text: 'Selectbox')
	sel.set_bounds(0, 0, 100, 25)

	for i := 0; i < 3; i++ {
		sel.items << (25 * (i + 1)).str() + '%'
	}

	// sel.set_change(sel_change)
	sel.subscribe_event('item_change', fn (mut e ui.ItemChangeEvent) {
		dump(e.new_val)
	})

	mut title_box := ui.title_box('Selector', [sel])
	title_box.set_bounds(130, 40, 120, 150)

	// app.pane.add_child(title_box)
	mut btn := ui.button(
		text: 'Hello'
		bounds: ui.Bounds{0, 70, 60, 40}
	)
	btn.subscribe_event('mouse_up', fn (mut e ui.MouseEvent) {
		dump('CLICK!')
	})
	title_box.add_child(btn)

	return title_box
}

// Invoked when the user clicks the button
fn right_button_clicked(mut e ui.MouseEvent) {
	e.target.text = 'Clicked'
}
