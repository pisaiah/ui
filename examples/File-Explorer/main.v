module main

import iui as ui
import gg
import os

// Our App
@[heap]
struct App {
mut:
	win        &ui.Window
	fp         &FilePanel
	path_field &ui.TextField
	loading    int
	dirty_hoes []&FileEntry
	hoe_tick   int
	text       &string
	stat_lbl   &ui.Label
}

fn main() {
	mut win := ui.Window.new(
		title:           'Simple Files'
		width:           600
		height:          400
		custom_titlebar: true
		theme:           theme_default()
		ui_mode:         true
	)

	str := 'File Explorer'

	mut app := &App{
		win:        win
		fp:         unsafe { nil }
		path_field: ui.TextField.new()
		text:       &str
		stat_lbl:   ui.Label.new()
	}

	app.make_menus()
	app.make_content_pane()

	app.win.run()
}

fn (mut app App) make_content_pane() {
	mut p := ui.Panel.new(
		layout:   ui.BorderLayout.new(
			hgap:  0
			vgap:  4
			style: 1
		)
		children: [
			ui.Panel.new(
				layout:   ui.BorderLayout.new(vgap: 0)
				children: [
					ui.ScrollView.new(
						view: app.center_panel()
					),
					// ui.Button.new(text: 'Center')
				]
			),
			app.make_north_panel(),
			ui.Panel.new(
				layout:   ui.FlowLayout.new(vgap: 0)
				children: [
					ui.Label.new(
						text: 'Simple File Explorer - Trial Version - © 2025 Isaiah.'
						pack: true
					),
					app.stat_lbl,
				]
			),
			ui.Panel.new(
				children: [
					// ui.Button.new(text: 'East')
				]
			),
			ui.Panel.new(
				layout:   ui.FlowLayout.new(hgap: 0, vgap: 0)
				children: [
					/*
					ui.NavPane.new(
						collapsed: true
					)
					*/
					// ui.Button.new(text: 'West')
				]
			),
			// ui.NavPane.new()
		]
	)

	app.win.add_child(p)
}

fn (mut app App) image_button(cfg ui.ButtonConfig) &ui.Button {
	mut img := ui.Image.new(
		file:   os.resource_abs_path('assets/${cfg.text}')
		width:  32
		height: 32
	)
	id := img.get_id(app.win.graphics_context)

	mut btn := ui.Button.new(cfg)
	btn.text = ''
	btn.border_radius = -1
	btn.set_area_filled_state(false, .normal)
	btn.icon = id
	return btn
}

fn (mut app App) make_north_panel() &ui.Panel {
	mut back_btn := app.image_button(text: 'back.png', width: 30, height: 30)
	mut frwrd_btn := app.image_button(text: 'forward1.png', width: 30, height: 30)
	mut upd_btn := app.image_button(text: 'Up.png', width: 30, height: 30)
	mut home_btn := app.image_button(text: 'home.png', width: 30, height: 30)
	mut btngo := app.image_button(text: 'go.png', width: 30, height: 30)

	upd_btn.subscribe_event('mouse_up', fn [mut app] (mut e ui.MouseEvent) {
		app.go_up_folder()
	})

	home_btn.subscribe_event('mouse_up', fn [mut app] (mut e ui.MouseEvent) {
		app.load_home()
	})

	mut controls := ui.Panel.new(
		layout:   ui.BoxLayout.new(vgap: 0, hgap: 4)
		children: [
			back_btn,
			frwrd_btn,
			upd_btn,
			home_btn,
		]
	)
	mut p := ui.Panel.new(
		layout:   ui.BorderLayout.new(hgap: 4)
		children: [
			app.path_field,
			controls,
			btngo,
		]
		flags:    [
			ui.borderlayout_center,
			ui.borderlayout_west,
			ui.borderlayout_east,
		]
	)

	// p.set_bounds(0, 0, 0, 40)
	p.height = 40
	controls.set_bounds(0, 0, 0, 40)
	return p
}

enum FolderView {
	details
	icons
	tiles
}

struct FilePanel {
	ui.Panel
mut:
	dir      string
	app      &App
	view     FolderView
	selected ?voidptr
}

pub fn (mut p FilePanel) get_selected[T]() ?T {
	return unsafe { ?T(p.selected or { return none }) }
}

pub fn (mut p FilePanel) set_selected(ptr voidptr) {
	p.selected = ptr
}

fn (mut p FilePanel) draw_update_size(e &ui.DrawEvent) {
	// Set width to parent & let Panel pack height
	p.width = p.parent.width
	p.height = 0

	e.ctx.draw_corner_rect(p.x, p.parent.y, p.width, p.parent.height, e.ctx.theme.textbox_background,
		e.ctx.theme.textbox_background)

	if p.children.len < 10 {
		for mut child in p.children {
			if child is ui.Container {
				child.width = p.parent.width - 10
				child.height = 0
			}
		}
	}

	if p.app.dirty_hoes.len > 0 {
		spawn p.app.undirty()

		/*
		mut dirt := p.app.dirty_hoes.pop_left()
		if !isnil(dirt) {
			p.app.stat_lbl.text = 'Loading thumbnail: ${dirt.name}'
			
			dirt.undirty()
			p.app.win.refresh_ui()
		}
		
		if p.app.dirty_hoes.len == 0 {
			gc_collect()
			p.app.stat_lbl.text = ''
		}
		*/
	}
}

fn (mut app App) undirty() {
	for app.dirty_hoes.len > 0 {
		mut dirt := app.dirty_hoes.pop_left()
		dirt.undirty()
	}
}

fn (mut app App) center_panel() &ui.Panel {
	mut p := &FilePanel{
		app:    app
		layout: ui.FlowLayout.new()
		view:   .icons
		dir:    os.home_dir()
	}

	app.fp = p

	p.subscribe_event('draw', p.draw_update_size)

	// app.load_folder(p.dir)
	app.load_home()

	return &ui.Panel(p)
}

fn (mut app App) go_up_folder() {
	app.load_folder(os.join_path(app.fp.dir, '..'))
}

fn (mut app App) clear_files() {
	app.fp.children.clear()

	unsafe {
		app.fp.children.free()
	}

	app.fp.children = []
}

fn (mut app App) load_home() {
	app.path_field.text = ''
	app.path_field.carrot_left = 0
	app.clear_files()

	app.fp.dir = ''

	drives := get_drives()

	mut dp := ui.Panel.new()

	mut qa := ui.Panel.new(
		children: [
			TextEntry.new(
				name: 'Desktop'
				path: os.join_path(os.home_dir(), 'Desktop')
				icon: 'assets/desktop.png'
				view: .icons
			),
			TextEntry.new(
				name: 'Documents'
				path: os.join_path(os.home_dir(), 'Documents')
				icon: 'assets/documents.png'
				view: .icons
			),
			TextEntry.new(
				name: 'Pictures'
				path: os.join_path(os.home_dir(), 'Pictures')
				icon: 'assets/pictures.png'
				view: .icons
			),
			TextEntry.new(
				name: 'Downloads'
				path: os.join_path(os.home_dir(), 'Downloads')
				icon: 'assets/downloads.png'
				view: .icons
			),
		]
	)

	for drive in drives {
		path := drive.path

		mut lbl := TextEntry.new(
			name: path
			path: path
			icon: 'assets/Local Disk.png'
			info: drive
			view: .tiles
		)

		dp.add_child(lbl)
	}

	app.fp.add_child(ui.Label.new(text: 'Devices and drives', em_size: 1, pack: true))
	app.fp.add_child(dp)

	app.fp.add_child(ui.Label.new(text: 'Quick Access', em_size: 1, pack: true))
	app.fp.add_child(qa)
}

fn (mut app App) load_folder(dir_raw string) {
	dir := os.norm_path(dir_raw)
	app.path_field.text = dir
	app.path_field.carrot_left = dir.len
	mut files := os.ls(dir) or {
		println('not a dir')
		return
	}
	files.insert(0, '..')

	app.clear_files()
	app.fp.dir = dir

	for file in files {
		path := os.join_path(dir, file)
		mut lbl := FileEntry.new(file, path)

		app.fp.add_child(lbl)
	}
}

//	Default Theme - Memics Windows
pub fn theme_default() &ui.Theme {
	return &ui.Theme{
		name: 'Default'

		accent_text:        ui.light_accent_text
		accent_fill:        ui.light_accent_fill
		accent_fill_second: ui.light_accent_fill_second
		accent_fill_third:  ui.light_accent_fill_third

		text_color:           gg.black
		background:           gg.rgb(230, 230, 230) // gg.rgb(239, 238, 227)
		button_bg_normal:     gg.rgb(255, 255, 255)
		button_bg_hover:      gg.rgb(229, 241, 251)
		button_bg_click:      gg.rgb(204, 228, 247)
		button_border_normal: gg.rgb(190, 190, 190)
		button_border_hover:  gg.rgb(0, 120, 215)
		button_border_click:  gg.rgb(0, 84, 153)
		menubar_background:   gg.rgb(59, 119, 188) // gg.rgb(100, 151, 226) // gg.rgb(59, 119, 188)
		menubar_border:       gg.white
		dropdown_background:  gg.white
		dropdown_border:      gg.rgb(224, 224, 224)
		textbox_background:   gg.rgb(239, 238, 227) // gg.white
		textbox_border:       gg.rgb(230, 230, 230)
		scroll_track_color:   gg.rgba(238, 238, 238, 230)
		scroll_bar_color:     gg.rgb(170, 170, 170)
	}
}
