module main

import iui as ui

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title:  'NavPane Testing'
		width:  520
		height: 400
		theme:  ui.theme_default()
	)

	mut bar := ui.Menubar.new()
	bar.set_padding(4)
	bar.add_child(create_theme_menu())
	window.bar = bar

	mut p := ui.Panel.new(
		layout: ui.BorderLayout.new(vgap: 0, hgap: 0)
	)

	mut icons := [
		'\uE156',
		'\uE12E',
		'\uE167',
		'\uE193',
	]

	mut np := ui.NavPane.new(
		pack:      true
		collapsed: true
	)

	mut card_panel := ui.Panel.new(
		layout: ui.CardLayout.new()
	)

	for i in 0 .. icons.len {
		mut item := ui.NavPaneItem.new(
			text: 'Hello ${i}'
			icon: icons[i]
		)

		item.subscribe_event('mouse_up', fn [mut card_panel] (e &ui.MouseEvent) {
			mut layout := card_panel.get_layout()
			id := '${e.target.text.split(' ')[1]}-card'
			if mut layout is ui.CardLayout {
				layout.selected = id
			}
		})

		mut lbl := ui.Label.new(text: 'Label #${i}')
		card_panel.add_child(lbl, value: '${i}-card')

		np.add_child(item)
	}
	
	mut item := ui.NavPaneItem.new(
		text: 'Hello there!'
		icon: '\ue713'
	)
	
	mut subitem := ui.NavPaneItem.new(
		text: 'A subitem!'
		icon: '\ue167'
	)
	
	item.add_child(subitem)
	
	np.add_child(item)
	
	

	p.add_child(np, value: ui.borderlayout_west)
	p.add_child(card_panel, value: ui.borderlayout_center)

	window.add_child(p)

	// Start GG / Show Window
	// window.run()
	mut win := *window

	win.run()
}

// Make a 'Theme' menu item to select themes
fn create_theme_menu() &ui.MenuItem {
	mut theme_menu := ui.MenuItem.new(
		text: 'Themes'
	)

	themes := ui.get_all_themes()
	for theme in themes {
		item := ui.MenuItem.new(
			text:           theme.name
			click_event_fn: theme_click
		)
		theme_menu.add_child(item)
	}
	return theme_menu
}

// MenuItem in the Theme section click event
fn theme_click(mut win ui.Window, com ui.MenuItem) {
	text := com.text
	theme := ui.theme_by_name(text)
	win.set_theme(theme)
}
