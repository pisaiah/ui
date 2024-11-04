module iui

import gg
import gx
import v.util.version { full_v_version }
import os

// WinUI3 Guidelines ControlCornerRadius
const menu_item_radius = 4

// Menubar - An implementation of a menu bar.
//			You add MenuItem objects as children of the Menubar to construct a menu. When the
//			user selects a MenuItem object, its associated MenuItem children are displayed.
// Reference:
// https://docs.oracle.com/javase/tutorial/uiswing/components/menu.html
//
pub struct Menubar {
	Component_A
pub mut:
	tik     int = 99
	padding int
	ai      int
	animate bool = true
}

pub fn (mut this Menubar) set_animate(val bool) {
	this.animate = val
}

pub fn (mut this Menubar) set_padding(pad int) {
	this.padding = pad
}

pub struct MenuItem {
	Component_A
pub mut:
	icon           &Image
	uicon          ?string
	open           bool
	open_width     int
	sub            u8
	click_event_fn fn (mut Window, MenuItem) = unsafe { nil }
	ah             int
}

fn (mut this MenuItem) draw(ctx &GraphicsContext) {
	ra := menu_item_radius
	this.height = 26

	if this.sub == 0 {
		if !isnil(this.icon) {
			this.width = this.icon.width + 14
		} else {
			if this.uicon != none {
				size := 23 + ctx.text_width(this.text)
				this.width = size + 14
			} else {
				size := ctx.text_width(this.text)
				this.width = size + 14
			}
		}
	}

	bg := ctx.theme.button_bg_hover

	if this.is_mouse_down || this.open {
		ctx.gg.draw_rounded_rect_filled(this.x, this.y, this.width, this.height, ra, bg)
	}

	if this.is_mouse_rele {
		ctx.gg.draw_rounded_rect_filled(this.x, this.y, this.width, this.height, ra, bg)
		this.is_mouse_rele = false
		if this.children.len > 0 {
			this.open = !this.open
		} else {
			// deprecated click_event_fn
			if !isnil(this.click_event_fn) {
				mut win := ctx.win
				this.click_event_fn(mut win, *this)
			}
			this.is_mouse_rele = false
			if !isnil(this.parent) {
				mut par := this.get_parent[&MenuItem]()
				par.open = false
			}
		}

		if this.text == 'About iUI' {
			about := open_about_modal(ctx.win)
			ctx.win.add_child(about)
			this.is_mouse_rele = false
			this.open = false

			if !isnil(this.parent) {
				mut par := &MenuItem(this.parent)
				par.open = false
			}
		}
	}

	if is_in(this, ctx.win.mouse_x, ctx.win.mouse_y) {
		// ctx.gg.draw_rect_filled(this.x, this.y, this.width, this.height, ctx.theme.button_bg_hover)
		ctx.gg.draw_rounded_rect_filled(this.x, this.y, this.width, this.height, ra, ctx.theme.button_bg_hover)
	}

	y := this.y + ((this.height / 2) - (ctx.line_height / 2))

	// Draw Button Text
	if !isnil(this.icon) {
		image_y := this.y + ((this.height / 2) - (this.icon.height / 2))
		this.icon.set_pos(this.x + (this.width / 2) - (this.icon.width / 2), image_y)
		this.icon.draw(ctx)
	} else {
		this.draw_text(ctx, y)
	}

	if this.open {
		this.draw_open_contents(ctx)
	} else {
		if this.get_parent[&Menubar]().animate {
			this.ah = 20
		}
	}
}

fn (mut this MenuItem) draw_text(ctx &GraphicsContext, y int) {
	/*
	$if windows {
		// Native Text Rendering
		if this.sub == 0 && ctx.theme.text_color == gx.black && !ctx.gg.native_rendering {
			if isnil(this.win_nat) {
				this.win_nat = &WLabel{
					text: this.text
				}
			}
			mut wl := unsafe { &WLabel(this.win_nat) }
			if wl.text != this.text {
				wl.text = this.text
				wl.dirt = true
			}
			wl.x = this.x + 7
			wl.y = y - 2
			this.width = wl.width + 14
			wl.draw(ctx)
			return
		}
	}
	*/

	if this.uicon != none {
		txt := this.uicon or { '' }

		// icon_font := 'C:\\Windows\\Fonts\\SegoeIcons.ttf'
		// icon_font := 'C:\\users\\isaia\\Downloads\\FluentSystemIcons-Regular.ttf'
		// icon_font := 'C:\\users\\isaia\\Downloads\\icomoon.ttf'
		icon_font := ctx.win.extra_map['icon_ttf']

		if os.exists(icon_font) {
			ctx.draw_text(this.x + 7, y, txt, icon_font, gx.TextCfg{
				size:  ctx.win.font_size
				color: ctx.theme.text_color
			})
			wid := ctx.text_width(txt) + 14
			ctx.draw_text(this.x + wid, y, this.text, ctx.font, gx.TextCfg{
				size:  ctx.win.font_size
				color: ctx.theme.text_color
			})
			return
		}
	}

	ctx.draw_text(this.x + 7, y, this.text, ctx.font, gx.TextCfg{
		size:  ctx.win.font_size
		color: ctx.theme.text_color
	})
}

fn (mut this MenuItem) draw_open_contents(ctx &GraphicsContext) {
	mut cy := this.y + this.height - this.ah
	mut cx := this.x + 1

	open_height := this.children.len * 26

	if this.ah > 0 {
		this.ah -= (this.ah / 4)
		if this.ah < 4 {
			this.ah -= 1
		}
	}

	if this.open && this.sub > 0 {
		cy -= this.height
	}

	if this.sub > 0 {
		mut par := &MenuItem(this.parent)
		cx += par.open_width
	}

	by := if this.open && this.sub > 0 { this.y } else { this.y + this.height }

	if this.ah > 0 {
		ws := ctx.gg.window_size()
		ctx.gg.scissor_rect(this.x, this.y + 26, ws.width, open_height)
	}
	ctx.gg.draw_rect_filled(cx, by, this.open_width, open_height - this.ah, ctx.theme.dropdown_background)

	mut hei := 0
	mut wi := 100

	for mut item in this.children {
		item.set_parent(this)
		if mut item is MenuItem {
			if item.sub != 1 {
				item.sub = 1
			}

			pad := if item.uicon == none { 14 } else { 37 }
			sizee := ctx.text_width(item.text) + pad
			if wi < sizee {
				wi = sizee
			}
		}

		item.draw_with_offset(ctx, cx, cy)
		cy += item.height
		hei += item.height
	}

	if this.ah != 0 {
		ws := ctx.gg.window_size()
		ctx.gg.scissor_rect(0, 0, ws.width, ws.height)
	}

	for mut item in this.children {
		item.width = wi
	}
	this.open_width = wi
	ctx.gg.draw_rect_empty(cx, by, wi, hei - this.ah, ctx.theme.dropdown_border)
}

fn (mut this Menubar) draw(ctx &GraphicsContext) {
	wid := if this.width > 0 { this.width } else { gg.window_size().width }

	half_pad := this.padding / 2
	this.height = 26 + this.padding

	ctx.theme.menu_bar_fill_fn(this.x, this.y, wid - 1, 26 + this.padding, ctx)

	// ctx.gg.draw_rect_empty(this.x, this.y, wid, 26, ctx.theme.menubar_border)
	mut x := this.x + 1
	for mut item in this.children {
		item.set_parent(this)
		item.draw_with_offset(ctx, x + half_pad, this.y + half_pad)
		x += item.width
	}
}

fn (mut this Menubar) check_mouse(win &Window, mx int, my int) bool {
	if isnil(win.bar) {
		return false
	}

	for mut item in this.children {
		if mut item is MenuItem {
			if !item.open {
				continue
			}
			res := item.check_mouse(win, mx, my)
			if res {
				return true
			}
		}
	}
	return false
}

fn (mut this MenuItem) check_mouse(win &Window, mx int, my int) bool {
	if !this.open {
		return false
	}

	for mut item in this.children {
		if is_in(item, mx, my) {
			return true
		} else {
			if mut item is MenuItem {
				if item.check_mouse(win, mx, my) {
					return true
				}
			}
		}
	}

	res := point_in_raw(mut this, mx, my)

	if !res {
		this.open = false
	}
	return res
}

@[params]
pub struct MenubarConfig {
	theme &Theme = unsafe { nil }
}

@[deprecated: 'Use Menubar.new']
pub fn menu_bar(cfg MenubarConfig) &Menubar {
	return &Menubar{}
}

pub fn Menubar.new(cfg MenubarConfig) &Menubar {
	return &Menubar{}
}

fn (mut app Window) get_bar() &Menubar {
	return app.bar
}

fn (mut app Window) set_bar_tick(val int) {
	if app.bar != unsafe { nil } {
		app.bar.tik = val
	}
}

@[parms]
pub struct MenuItemConfig {
pub:
	text           string
	icon           &Image                    = unsafe { nil }
	click_event_fn fn (mut Window, MenuItem) = unsafe { nil }
	children       []&MenuItem
	click_fn       ?fn (voidptr)
	uicon          ?string
}

pub fn MenuItem.new(c MenuItemConfig) &MenuItem {
	mut item := &MenuItem{
		text:           c.text
		icon:           c.icon
		click_event_fn: c.click_event_fn
		uicon:          c.uicon
	}

	fns := c.click_fn or { unsafe { nil } }

	if !isnil(fns) {
		item.subscribe_event('mouse_up', fns)
	}

	/*
	if !isnil(c.click_event_fn) {
		item.subscribe_event('mouse_up', fn [c] (mut e MouseEvent) {
			mut target := e.target
			if mut target is MenuItem {
				c.click_event_fn(mut e.ctx.win, target)
			}
		})
	}
	*/

	for kid in c.children {
		item.add_child(kid)
	}
	return item
}

pub fn menu_item(cfg MenuItemConfig) &MenuItem {
	return MenuItem.new(cfg)
}

pub fn (mut com MenuItem) set_click(b fn (mut Window, MenuItem)) {
	com.click_event_fn = b
}

fn open_about_modal(app &Window) &Modal {
	mut about := Modal.new(title: 'About iUI')
	about.in_height = 240
	about.in_width = 1

	mut p := Panel.new(
		layout: BoxLayout{
			ori: 1
		}
	)

	p.set_pos(15, 11)

	ws := app.gg.window_size()
	if 370 > ws.width {
		about.top_off = 20
		about.in_width = ws.width - 10
	}

	about.pack()

	mut title := Label.new(text: 'iUI ')
	title.set_config(16, false, true)
	title.pack()
	p.add_child(title)

	mut lbl := Label.new(
		text: "Isaiah's UI Toolkit for V.\nVersion: ${version}\nCompiled with ${full_v_version(false)}"
	)
	lbl.pack()
	p.add_child(lbl)

	gh := link(
		text: 'Github'
		url:  'https://github.com/pisaiah/ui'
		pack: true
	)
	p.add_child(gh)

	mut blank := Label.new(text: '  ')
	blank.pack()
	p.add_child(blank)

	mut copy := Label.new(text: 'Copyright © 2021-2024 Isaiah.')
	copy.set_config(12, true, false)
	copy.set_bounds(0, 0, 200, 15)
	p.add_child(copy)
	about.add_child(p)
	return about
}
