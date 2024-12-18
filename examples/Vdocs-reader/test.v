module main

import iui as ui
import net.http
import net.html

const doc_main = 'https://docs.vlang.io/'
const doc_url = 'https://docs.vlang.io/introduction.html'

@[heap]
struct App {
mut:
	window &ui.Window
	p      &ui.Panel
	doc    html.DocumentObjectModel
	main   &ui.Panel
}

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title:  'V Documentation Viewer'
		width:  800
		height: 400
		theme:  ui.theme_default()
	)

	// TODO run this async?
	txt := http.get_text(doc_url)

	mut app := &App{
		window: window
		p:      ui.Panel.new(layout: ui.BorderLayout.new(vgap: 0))
		doc:    html.parse(txt)
		main:   ui.Panel.new(layout: ui.BoxLayout.new(ori: 1))
	}

	app.setup_window()
	app.run()
}

fn menu_click(mut e ui.MouseEvent) {
	e.ctx.win.set_theme(ui.theme_by_name(e.target.text))
}

fn (mut app App) setup_window() {
	// MenuBar
	mut bar := ui.Menubar.new()

	mut item0 := ui.MenuItem.new(text: 'File')
	mut item1 := ui.MenuItem.new(text: 'Edit')

	mut item2 := ui.MenuItem.new(
		text:     'Theme'
		children: [
			ui.MenuItem.new(
				text:     'Default'
				click_fn: menu_click
			),
			ui.MenuItem.new(
				text:     'Dark'
				click_fn: menu_click
			),
			ui.MenuItem.new(
				text:     'Dark (Red Accent)'
				click_fn: menu_click
			),
			ui.MenuItem.new(
				text:     'Dark (RGB)'
				click_fn: menu_click
			),
		]
	)
	bar.add_child(item0)
	bar.add_child(item1)
	bar.add_child(item2)
	app.window.bar = bar

	// Content Pane
	app.setup_navbar()
	app.window.add_child(app.p)
}

struct DocNavItem {
	ui.NavPaneItem
	tag &html.Tag
}

fn DocNavItem.new(tag &html.Tag, c ui.NavPaneItemConfig) &DocNavItem {
	mut item := &DocNavItem{
		icon:       c.icon
		lock_width: c.lock_width
		text:       c.text
		tag:        tag
	}

	item.subscribe_event('mouse_up', item.NavPaneItem.set_selected_on_mouse_up)

	return item
}

fn (mut app App) nav_item_click(mut e ui.MouseEvent) {
	mut item := e.target
	if mut item is DocNavItem {
		app.nav_item_click_load_doc(item, e)
	}
}

fn (mut app App) nav_item_click_load_doc(item &DocNavItem, e &ui.MouseEvent) {
	dump(item.tag)

	href := doc_main + item.tag.attributes['href']
	dump(href)

	txt := http.get_text(href)
	doc := html.parse(txt)

	app.main.children.clear()
	app.main.width = 0
	app.main.height = 0

	mut tag := doc.get_tags(name: 'main')[0]

	for t in tag.children {
		if t.name == 'h1' {
			mut lbl := ui.Label.new(
				text:    t.content
				pack:    true
				em_size: 2
			)
			app.main.add_child(lbl)
			continue
		}

		clz := t.attributes['class']

		if clz.starts_with('language-') {
			mut tb := ui.Textbox.new(
				lines:        t.content.trim_space().split('\n')
				pack:         true
				not_editable: true
			)
			tb.no_line_numbers = true
			tb.set_bounds(0, 0, 0, e.ctx.line_height * tb.lines.len)
			app.main.add_child(tb)
			continue
		}

		mut lbl := ui.Label.new(
			text: t.str()
			pack: true
		)

		dump(lbl.text)

		app.main.add_child(lbl)
	}
}

// Setup Navbar
fn (mut app App) setup_navbar() {
	mut nav := ui.NavPane.new(
		collapsed: false
	)

	// Get item tags
	tags := app.doc.get_tags_by_class_name('items')

	if tags.len == 0 {
		return
	}

	item_tag := tags[0]

	mut last_main := &DocNavItem(unsafe { nil })

	// Create NavPaneItem from tag
	for tag in item_tag.children {
		mut item := DocNavItem.new(tag,
			text: tag.content
			icon: '\ue130'
		)

		item.subscribe_event('mouse_up', app.nav_item_click)

		is_subtopic := tag.attributes['class'].contains('subtopic')
		if is_subtopic {
			last_main.add_child(item)
		} else {
			last_main = item
			nav.add_child(item)
		}
	}

	// Settings Item
	mut settings_item := ui.NavPaneItem.new(
		text: 'Settings'
		icon: '\uE713'
	)
	nav.add_child(settings_item)

	mut sv := ui.ScrollView.new(
		view: app.main
	)

	app.p.add_child(nav, value: ui.borderlayout_west)
	app.p.add_child(sv, value: ui.borderlayout_center)
}

fn (mut app App) run() {
	app.window.run()
}
