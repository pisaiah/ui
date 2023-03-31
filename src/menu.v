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
	click_event_fn fn (mut Window, MenuItem)
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
				mut par := &MenuItem(this.parent)
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
		ctx.draw_text(this.x + 7, y, this.text, ctx.font, gx.TextCfg{
			size: ctx.win.font_size
			color: ctx.theme.text_color
		})
	}

	if this.open {
		this.draw_open_contents(ctx)
	}
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
		item.parent = this
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

[params]
pub struct MenubarConfig {
	theme &Theme = unsafe { nil }
}

pub fn menu_bar(cfg MenubarConfig) &Menubar {
	return &Menubar{
		// theme: cfg.theme
	}
}

[deprecated]
pub fn menubar(app &Window, theme Theme) &Menubar {
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

[parms]
pub struct MenuItemConfig {
	text           string
	icon           &Image = unsafe { nil }
	click_event_fn fn (mut Window, MenuItem) = fn (mut win Window, item MenuItem) {}
	children       []&MenuItem
}

// [deprecated: 'Replaced with menu_item(MenuItemConfig)']
pub fn menuitem(text string) &MenuItem {
	return &MenuItem{
		text: text
		icon: 0
		click_event_fn: fn (mut win Window, item MenuItem) {}
	}
}

pub fn menu_item(confg MenuItemConfig) &MenuItem {
	mut item := &MenuItem{
		text: confg.text
		icon: confg.icon
		click_event_fn: confg.click_event_fn
	}
	for kid in confg.children {
		item.add_child(kid)
	}
	return item
}

pub fn (mut com MenuItem) set_click(b fn (mut Window, MenuItem)) {
	com.click_event_fn = b
}

fn open_about_modal(app &Window) &Modal {
	mut about := modal(app, 'About iUI')
	about.in_height = 250
	about.in_width = 370

	mut title := label(app, 'iUI ')
	title.set_pos(40, 16)
	title.set_config(16, false, true)
	title.pack()
	about.add_child(title)

	mut lbl := label(app, "Isaiah's UI Toolkit for V.\nVersion: ${version}\nCompiled with " +
		full_v_version(false))
	lbl.set_pos(40, 70)
	about.add_child(lbl)

	gh := link(
		text: 'Github'
		url: 'https://github.com/isaiahpatton/ui'
		bounds: Bounds{
			x: 40
			y: 135
		}
		pack: true
	)
	about.add_child(gh)

	mut copy := label(app, 'Copyright © 2021-2023 Isaiah.')
	copy.set_pos(40, 185)
	copy.set_config(12, true, false)
	about.add_child(copy)
	return about
}
