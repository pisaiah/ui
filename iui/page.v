module iui

import gg
import gx

// Page - Full Page Alternative to Modal
//
// Style Guides:
// 	https://w3schools.com/w3css/w3css_color_generator.asp
//  https://w3schools.com/w3css/w3css_color_schemes.asp
//  Colorhex: #337299
//
pub struct Page {
	Component_A
pub:
	text_cfg gx.TextCfg
pub mut:
	window     &Window
	text       string
	needs_init bool
	close      &Button
	in_height  int
	top_off    int = 78
	xs         int
}

fn draw_cfg() gx.TextCfg {
	return gx.TextCfg{
		size: 36
		color: gx.white
	}
}

pub fn page(app &Window, title string) &Page {
	return &Page{
		text: title
		window: app
		z_index: 500
		needs_init: true
		draw_event_fn: fn (mut win Window, mut com Component) {
			if mut com is Page {
				for mut kid in com.children {
					kid.draw_event_fn(mut win, kid)
				}
			}
		}
		text_cfg: draw_cfg()
		in_height: 300
		close: 0
	}
}

fn (this &Page) draw_bg(ctx &GraphicsContext) {
	bg := gx.rgb(51, 114, 153)
	ctx.gg.draw_rect_filled(0, 0, this.width, this.height, ctx.theme.background)
	ctx.gg.draw_rect_filled(0, 0, this.width, this.height, gx.rgba(bg.r, bg.g, bg.b, 20))
	ctx.gg.draw_rect_filled(0, 0, this.width, 78, bg)
	ctx.gg.draw_rect_filled(0, 0, this.width, 12, gx.rgba(0, 0, 0, 90))
}

pub fn (mut this Page) draw(ctx &GraphicsContext) {
	mut app := this.window
	ws := gg.window_size()

	this.width = ws.width
	this.height = ws.height

	this.draw_bg(ctx)

	title := this.text
	ctx.draw_text(56, 28, title, ctx.font, this.text_cfg)

	ctx.gg.set_cfg(gx.TextCfg{
		size: ctx.font_size
		color: ctx.theme.text_color
	})

	// Do component draw event again to fix z-index
	this.draw_event_fn(mut app, &Component(this))

	if this.needs_init {
		this.create_close_btn(mut app, true)
		this.needs_init = false
	}

	y_off := this.y + this.top_off
	for mut com in this.children {
		com.draw_event_fn(mut app, com)
		app.draw_with_offset(mut com, 0, y_off + 2)
	}
}

pub fn (mut this Page) create_close_btn(mut app Window, ce bool) &Button {
	mut close := button(app, '<')
	close.set_bounds(8, -56, 40, 42)

	if ce {
		close.set_click(default_page_close_fn)
	}

	ref := &close
	this.children << ref
	this.close = ref
	return ref
}

pub fn default_page_close_fn(mut win Window, btn Button) {
	win.components = win.components.filter(mut it !is Page)
}
