module iui

import gg
import gx
import v.util.version { full_v_version }

pub struct Menubar {
	Component_A
pub mut:
	tik int = 99
}

pub struct MenuItem {
	Component_A
pub mut:
	icon           &Image
	open           bool
	open_width     int
	sub            u8
	click_event_fn fn (mut Window, MenuItem) = unsafe { nil }
	win_nat        voidptr
}

fn (mut this MenuItem) draw(ctx &GraphicsContext) {
	this.height = 26

	if this.sub == 0 {
		if !isnil(this.icon) {
			this.width = this.icon.width + 14
		} else {
			size := ctx.text_width(this.text)
			this.width = size + 14
		}
	}

	bg := ctx.theme.button_bg_hover

	if this.is_mouse_down || this.open {
		ctx.gg.draw_rect_filled(this.x, this.y, this.width, this.height, bg)
	}

	if this.is_mouse_rele {
		ctx.gg.draw_rect_filled(this.x, this.y, this.width, this.height, bg)
		this.is_mouse_rele = false
		if this.children.len > 0 {
			this.open = !this.open
		} else {
			// deprecated click_event_fn
			mut win := ctx.win
			this.click_event_fn(mut win, *this)
			this.is_mouse_rele = false
			if !isnil(this.parent) {
				mut par := this.get_parent[&MenuItem]() //&MenuItem(this.parent)
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
		ctx.gg.draw_rect_filled(this.x, this.y, this.width, this.height, ctx.theme.button_bg_hover)
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
	}
}

fn (mut this MenuItem) draw_text(ctx &GraphicsContext, y int) {
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
	ctx.draw_text(this.x + 7, y, this.text, ctx.font, gx.TextCfg{
		size: ctx.win.font_size
		color: ctx.theme.text_color
	})
}

fn (mut this MenuItem) draw_open_contents(ctx &GraphicsContext) {
	mut cy := this.y + this.height
	mut cx := this.x + 1

	if this.open && this.sub > 0 {
		cy -= this.height
	}

	if this.sub > 0 {
		mut par := &MenuItem(this.parent)
		cx += par.open_width
	}

	by := if this.open && this.sub > 0 { this.y } else { this.y + this.height }
	ctx.gg.draw_rect_filled(cx, by, this.open_width, this.children.len * 26, ctx.theme.dropdown_background)

	mut hei := 0
	mut wi := 100
	for mut item in this.children {
		item.set_parent(this)
		if mut item is MenuItem {
			if item.sub != 1 {
				item.sub = 1
			}
		}

		item.draw_with_offset(ctx, cx, cy)
		sizee := ctx.text_width(item.text) + 14

		if wi < sizee {
			wi = sizee
		}
		cy += item.height
		hei += item.height
	}
	for mut item in this.children {
		item.width = wi
	}
	this.open_width = wi
	ctx.gg.draw_rect_empty(cx, by, wi, hei, ctx.theme.dropdown_border)
}

fn (mut this Menubar) draw(ctx &GraphicsContext) {
	wid := if this.width > 0 { this.width } else { gg.window_size().width }

	ctx.theme.menu_bar_fill_fn(this.x, this.y, wid - 1, 26, ctx)
	ctx.gg.draw_rect_empty(this.x, this.y, wid, 26, ctx.theme.menubar_border)

	mut x := this.x + 1
	for mut item in this.children {
		item.draw_with_offset(ctx, x, this.y)
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
	text           string
	icon           &Image = unsafe { nil }
	click_event_fn fn (mut Window, MenuItem) = fn (mut win Window, item MenuItem) {}
	children       []&MenuItem
	click_fn       ?fn (voidptr)
}

pub fn MenuItem.new(c MenuItemConfig) &MenuItem {
	mut item := &MenuItem{
		text: c.text
		icon: c.icon
		click_event_fn: c.click_event_fn
	}

	fns := c.click_fn or { unsafe { nil } }

	if !isnil(fns) {
		item.subscribe_event('mouse_up', fns)
	}

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
	about.in_height = 250
	about.in_width = 350

	mut p := panel(
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
		url: 'https://github.com/isaiahpatton/ui'
		bounds: Bounds{
			x: 0
			y: 15
		}
		pack: true
	)
	p.add_child(gh)

	mut copy := Label.new(text: 'Copyright © 2021-2023 Isaiah.')
	copy.set_pos(0, 25)
	copy.set_config(12, true, false)
	p.add_child(copy)
	about.add_child(p)
	return about
}
