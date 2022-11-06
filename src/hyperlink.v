module iui

import gg
import gx

// Hyperlink - implements Component interface
pub struct Hyperlink {
	Component_A
pub mut:
	text           string
	click_event_fn fn (voidptr)
	in_modal       bool
	need_pack      bool
	size           int
	abs_size       bool
	bold           bool
	url            string
}

[params]
pub struct HyperlinkConfig {
	text   string
	url    string
	bounds Bounds
	pack   bool
}

pub fn link(cfg HyperlinkConfig) &Hyperlink {
	return &Hyperlink{
		text: cfg.text
		x: cfg.bounds.x
		y: cfg.bounds.y
		width: cfg.bounds.width
		height: cfg.bounds.height
		click_event_fn: fn (a voidptr) {
			this := &Hyperlink(a)
			open_url(this.url)
		}
		url: cfg.url
		need_pack: cfg.pack
	}
}

[deprecated: 'Replaced by link(HyperlinkConfig)']
pub fn hyperlink(app &Window, text string, url string, conf HyperlinkConfig) &Hyperlink {
	return &Hyperlink{
		text: text
		x: conf.bounds.x
		y: conf.bounds.y
		width: conf.bounds.width
		height: conf.bounds.height
		click_event_fn: fn (a voidptr) {
			this := &Hyperlink(a)
			open_url(this.url)
		}
		url: url
	}
}

pub fn (mut this Hyperlink) draw(ctx &GraphicsContext) {
	if this.need_pack {
		this.pack_do(ctx)
	}

	if this.is_mouse_rele {
		this.is_mouse_rele = false
		this.click_event_fn(this)
	}

	size := this.get_font_size(ctx)

	ctx.set_cfg(gx.TextCfg{
		size: size
		color: ctx.theme.text_color
		bold: this.bold
	})

	// Draw Button Text
	line_height := ctx.line_height + 5
	if this.height < (line_height / 2) {
		this.height = line_height
	}

	x := this.x
	y := this.y
	width := this.width
	height := this.height

	mut my := 0
	for mut spl in this.text.split('\n') {
		ctx.draw_text(x, y + height - line_height + my, spl.replace('\t', '  '.repeat(8)),
			ctx.font, gx.TextCfg{
			size: size
			color: gx.rgb(0, 100, 200)
			bold: this.bold
		})

		ctx.set_cfg(gx.TextCfg{
			size: ctx.font_size
			color: ctx.theme.text_color
			bold: false
		})

		my += line_height
	}
	ctx.gg.draw_line(x, y + height - 2, x + width, y + height - 2, gx.rgb(0, 100, 200))

	this.debug_draw(ctx)
}

pub fn (mut btn Hyperlink) pack() {
	btn.need_pack = true
}

fn (this &Hyperlink) get_font_size(ctx &GraphicsContext) int {
	if this.abs_size {
		return this.size
	}
	return ctx.win.font_size + this.size
}

pub fn (mut btn Hyperlink) pack_do(ctx &GraphicsContext) {
	// Set font size
	size := btn.get_font_size(ctx)

	ctx.set_cfg(gx.TextCfg{
		size: size
		color: ctx.theme.text_color
		bold: btn.bold
	})

	width := ctx.gg.text_width(btn.text.replace('\t', ' '.repeat(8)))
	btn.width = width + 1
	th := ctx.gg.text_height(btn.text) + 5

	lines := btn.text.split_into_lines()
	hi := (th * lines.len)
	btn.height = hi

	if btn.height < th {
		btn.height = th
	}
	btn.need_pack = false

	// Reset for text_height
	ctx.set_cfg(gx.TextCfg{
		size: ctx.win.font_size
		color: ctx.theme.text_color
		bold: false
	})
}

fn (this &Hyperlink) debug_draw(ctx &GraphicsContext) {
	if !ctx.win.debug_draw {
		return
	}
	ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, gx.blue)
	ctx.gg.draw_line(this.x, this.y, this.x + this.width, this.y + this.height, gx.blue)
	ctx.gg.draw_line(this.x, this.y + this.height, this.x + this.width, this.y, gx.blue)
}

pub fn (mut this Hyperlink) set_config(fs int, abs bool, bold bool) {
	this.size = fs
	if abs {
		// Absolute font size
		// this.size = fs - this.app.font_size
		this.abs_size = true
	}
	this.bold = bold
}

pub fn (mut this Hyperlink) set_click(b fn (voidptr)) {
	this.click_event_fn = b
}
