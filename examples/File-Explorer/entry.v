module main

import iui as ui
import gg
import os
import time

// A "FileEntry"
struct FileEntry {
	ui.Component_A
mut:
	img   &ui.Image
	name  string
	stat  os.Stat
	dirty bool
	path  string
}

const img_size = 48

const imgg = ui.Image.new(
	file: os.resource_abs_path('assets/folder1.png')
	pack: true
)

const imgg_file = ui.Image.new(
	file: os.resource_abs_path('assets/file.png')
	pack: true
)

const threads = &ThreadManager{}

struct ThreadManager {
mut:
	threads []thread
}

pub fn FileEntry.new(file string, path string) &FileEntry {
	mut e := &FileEntry{
		img:  get_image(path)
		name: file
		stat: os.lstat(path) or { panic(err) }
		path: path
	}

	if path.ends_with('.png') {
		// th := spawn e.load_png_img(path)
		// dump(th)

		// mut th := unsafe { threads }

		// th <<  spawn e.load_png_img(path)
		// spawn e.load_png_img(path)

		// th.wait()
		// e.undirty()
		// return e
		e.dirty = true
		return e
	}

	e.add_child(e.img)
	return e
}

fn (mut e FileEntry) load_png_img(path string) {
	// unsafe {
	e.img = ui.Image.new(
		file: path
		pack: true
	)

	// e.children[0] = e.img
	e.dirty = true
	e.img.text = path
	//}
}

fn get_image(path string) &ui.Image {
	if os.dir(path) == home_path {
		if path in home_folders.map {
			return unsafe { home_folders.map[path] }
		}
	}

	/*
	if path.ends_with('.png') {
		return ui.Image.new(
			file: path
			pack: true
		)
	}
	*/

	return if os.is_dir(path) { imgg } else { imgg_file }
}

fn (e FileEntry) under_mb() bool {
	return e.stat.size < (500 * 1024)
}

fn (mut e FileEntry) undirty() {
	if !e.under_mb() {
		// return
	}

	dump(e.path)
	mut img := MyImage.new(
		file: e.path
		pack: true
	)

	e.add_child(img)
	// e.img = &ui.Image(img)

	// e.children[0] = img
}

fn (mut e FileEntry) draw(g &ui.GraphicsContext) {
	mut p := e.get_parent[&FilePanel]()

	if isnil(e.parent) {
		return
	}

	if e.dirty {
		// mut loading := p.app.loading

		p.app.dirty_hoes << e

		// if loading == 0 {
		// p.app.loading += 1
		// e.children[0] = e.img
		e.dirty = false
		//}
	}

	if e.state == .click {
		sel := p.get_selected[&FileEntry]()

		if sel != none {
			if sel == e {
				new_path := os.join_path(p.dir, e.name)
				if os.is_file(new_path) {
					os.open_uri(new_path) or {}
					p.selected = none
					return
				}

				p.app.load_folder(new_path)
				p.selected = none
			}
		}
		e.state = .normal

		p.set_selected(e)
	}

	if e.state == .hover || e.img.state == .hover {
		g.gg.draw_rounded_rect_filled(e.x, e.y, e.width, e.height, 4, g.theme.button_bg_hover)
	}

	sel := p.get_selected[&FileEntry]()
	if sel != none {
		if sel == e {
			g.draw_corner_rect(e.x, e.y, e.width, e.height, g.theme.accent_fill_third,
				g.theme.button_bg_hover)
		}
	}

	cfg := gg.TextCfg{
		size:  g.font_size
		color: g.theme.text_color
	}

	if p.view == .icons {
		e.draw_icon_view(g, p, cfg)
	}

	if p.view == .details {
		e.draw_details_view(g, p, cfg)
	}

	if p.view == .tiles {
		e.draw_tile_view(g, p, cfg)
	}
}

fn (mut e FileEntry) draw_tile_view(g &ui.GraphicsContext, p &FilePanel, cfg gg.TextCfg) {
	padd := 12
	for mut child in e.children {
		if mut child is ui.Image {
			child.need_pack = false
			child.width = img_size
			child.height = img_size
		}
		child.draw_with_offset(g, e.x + (padd / 2), e.y)
	}

	xp := e.x + img_size + padd
	yp := e.y + (padd / 2)

	h := if g.line_height * 3 > img_size { g.line_height * 3 } else { img_size }

	e.width = img_size + 150 + padd
	e.height = h + (padd / 2)
	g.draw_text(xp, yp, e.name, g.font, cfg)

	// Draw Stats
	path := os.join_path(p.dir, e.name)
	draw_time(g, xp, yp + g.line_height, path, cfg)
	draw_size(g, xp, yp + (g.line_height * 2), path, e.stat.size, cfg)
}

fn (mut e FileEntry) draw_icon_view(g &ui.GraphicsContext, p &FilePanel, cfg gg.TextCfg) {
	x_padd := 32
	y_padd := 12
	mut yp := 0
	for mut child in e.children {
		if mut child is ui.Image {
			child.need_pack = false
			child.width = img_size
			child.height = img_size
		}
		child.draw_with_offset(g, e.x + (x_padd / 2), e.y)
		yp += child.height
	}

	e.width = img_size + x_padd
	// e.height = (img_size + g.line_height) + y_padd

	lines := draw_wrapped_text1(g, e.x + (e.width / 2), e.y + yp, e.name, e.width, cfg)
	e.height = (img_size + (g.line_height * lines)) + y_padd
}

fn (mut e FileEntry) draw_details_view(g &ui.GraphicsContext, p &FilePanel, cfg gg.TextCfg) {
	padd := 12
	mut xp := e.x
	for mut child in e.children {
		if mut child is ui.Image {
			child.need_pack = false
			child.width = 16
			child.height = 16
		}

		child.draw_with_offset(g, e.x + (padd / 2), e.y + (e.height / 2) - (child.height / 2))
		xp += child.width + padd
	}
	e.width = p.width
	e.height = g.line_height + padd

	// todo: configure
	stat_size := 200

	cth := e.y + (e.height / 2) - (g.line_height / 2)
	g.draw_text(xp, cth, e.name, g.font, cfg)

	// Draw Stats
	path := os.join_path(p.dir, e.name)
	draw_time(g, xp + stat_size, cth, path, cfg)
	draw_size(g, xp + stat_size + 130, cth, path, e.stat.size, cfg)
}

fn draw_time(g &ui.GraphicsContext, x int, y int, path string, cfg gg.TextCfg) {
	last_mod := os.file_last_mod_unix(path)
	timed := time.unix(last_mod)
	g.draw_text(x, y, '${timed}', g.font, cfg)
}

fn draw_size(g &ui.GraphicsContext, x int, y int, path string, size u64, cfg gg.TextCfg) {
	sizet := if os.is_dir(path) { '' } else { '${format_size(size)}' }
	g.draw_text(x, y, sizet, g.font, cfg)
}

fn format_size(bytes u64) string {
	kb := f32(bytes) / 1024.0
	if kb < 1024.0 {
		return '${kb:.2f} KB'
	}
	mb := kb / 1024.0
	return '${mb:.2f} MB'
}
