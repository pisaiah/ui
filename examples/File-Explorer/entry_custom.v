module main

import iui as ui
import gg
import os

// A "TextEntry"
struct TextEntry {
	ui.Component_A
mut:
	img  &ui.Image
	name string
	path string
	info ?DriveInfo
	view FolderView = .tiles
}

fn get_icon(info ?DriveInfo, def string) string {
	if info != none {
		typ := info.drive_type
		if typ.contains('SSD') || typ.contains('HDD') {
			return 'assets/ssd.png'
		}
		if typ.contains('USB') || typ.contains('Removable') {
			return 'assets/usb.png'
		}
		if typ.contains('DVD') || typ.contains('CD') {
			return 'assets/cd.png'
		}
		return 'assets/Local Disk.png'
	}
	return def
}

@[params]
pub struct TextEntryConfig {
	name string
	path string
	icon string
	info ?DriveInfo
	view FolderView
}

pub fn TextEntry.new(c TextEntryConfig) &TextEntry {
	mut e := &TextEntry{
		img:  ui.Image.new(file: os.resource_abs_path(get_icon(c.info, c.icon)))
		name: c.name
		path: c.path
		info: c.info
		view: c.view
	}
	e.add_child(e.img)
	return e
}

fn (mut e TextEntry) draw(g &ui.GraphicsContext) {
	mut p := e.parent.get_parent[&FilePanel]()

	if isnil(e.parent) {
		return
	}

	if e.state == .click {
		sel := p.get_selected[&TextEntry]()
		if sel != none {
			if sel == e {
				p.app.load_folder(e.path)
				p.selected = none
			}
		}
		e.state = .normal
		p.set_selected(e)
	}

	if e.state == .hover {
		g.gg.draw_rounded_rect_filled(e.x, e.y, e.width, e.height, 4, g.theme.button_bg_hover)
	}

	sel := p.get_selected[&TextEntry]()
	if sel != none {
		if sel == e {
			g.draw_corner_rect(e.x, e.y, e.width, e.height, g.theme.accent_fill_third,
				g.theme.button_bg_hover)
		}
	}

	cfg := gg.TextCfg{
		size:  g.win.font_size
		color: g.theme.text_color
	}

	if e.view == .icons {
		e.draw_icon_view(g, p, cfg)
	}

	if e.view == .tiles {
		e.draw_tile_view(g, p, cfg)
	}
}

fn (mut e TextEntry) draw_tile_view(g &ui.GraphicsContext, p &FilePanel, cfg gg.TextCfg) {
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
	if e.info != none {
		g.draw_text(xp, yp + (g.line_height), e.info.drive_type, g.font, cfg)
		g.draw_text(xp, yp + (g.line_height * 2), e.info.get_used_size(), g.font, cfg)
	}
}

fn (mut e TextEntry) draw_icon_view(g &ui.GraphicsContext, p &FilePanel, cfg gg.TextCfg) {
	padd := 20
	mut yp := 0
	for mut child in e.children {
		if mut child is ui.Image {
			child.need_pack = false
			child.width = img_size
			child.height = img_size
		}
		child.draw_with_offset(g, e.x + (padd / 2), e.y)
		yp += child.height
	}

	tw := g.text_width(e.name)
	e.width = img_size + padd
	e.height = (img_size + g.line_height) + padd
	g.draw_text(e.x + (e.width / 2) - (tw / 2), e.y + yp, e.name, g.font, cfg)
}
