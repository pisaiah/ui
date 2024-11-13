module iui

import gg
import gx

// Page
pub struct Page {
	Component_A
pub:
	text_cfg gx.TextCfg
pub mut:
	text string

	// needs_init bool
	close      &Button
	top_off    int      = 75
	line_color gx.Color = gx.rgba(0, 0, 0, 90)
}

fn draw_cfg() gx.TextCfg {
	return gx.TextCfg{
		size:  36
		color: gx.white
	}
}

@[params]
pub struct PageCfg {
pub:
	title string
}

pub fn Page.new(c PageCfg) &Page {
	return &Page{
		text:    c.title
		z_index: 500

		// needs_init: true
		text_cfg: draw_cfg()
		close:    unsafe { nil }
	}
}

fn (p &Page) draw_bg(g &GraphicsContext) {
	g.gg.draw_rect_filled(0, 0, p.width, p.height, g.theme.background)
	g.gg.draw_rect_filled(0, 0, p.width, p.top_off, g.theme.accent_fill)
	g.gg.draw_rect_filled(0, p.top_off - 5, p.width, 5, p.line_color)
}

pub fn (mut this Page) draw(ctx &GraphicsContext) {
	ws := gg.window_size()

	this.width = ws.width
	this.height = ws.height

	this.draw_bg(ctx)

	ctx.draw_text(56, 18, this.text, ctx.font, this.text_cfg)

	ctx.reset_text_font()

	// if this.needs_init {
	if isnil(this.close) {
		this.create_close_btn(true)
		this.close.set_accent_filled(true)
		this.close.border_radius = 16

		if !ctx.icon_ttf_exists() {
			// Fallback
			this.close.text = '<'
			this.close.font = 0
		}

		// this.needs_init = false
	}

	y_off := this.y + this.top_off

	if this.children.len == 2 {
		if this.children[0] is Panel || this.children[0] is ScrollView {
			// Content Pane
			if ws.width > 0 {
				this.children[0].width = ws.width
			}
			if ws.height > 5 {
				this.children[0].height = ws.height - y_off - 3
			}
		}
	}

	// this.children.sort(a.z_index < b.z_index)
	for mut com in this.children {
		if !isnil(com.draw_event_fn) {
			mut win := ctx.win
			com.draw_event_fn(mut win, com)
		}
		com.draw_with_offset(ctx, 0, y_off + 2)
	}
}

pub fn (mut this Page) create_close_btn(ce bool) &Button {
	mut close := Button.new(text: '\uf053')
	close.font = 1
	y := 16
	wid := this.top_off - (y * 2)
	close.set_bounds(8, -this.top_off + y, 40, wid)

	if ce {
		close.set_background(gx.rgba(230, 230, 230, 50))
		close.subscribe_event('mouse_up', fn (mut e MouseEvent) {
			e.ctx.win.components = e.ctx.win.components.filter(mut it !is Page)
		})
	}

	this.children << close
	this.close = close
	return close
}

pub fn default_page_close_fn(mut win Window, btn Button) {
	win.components = win.components.filter(mut it !is Page)
}
