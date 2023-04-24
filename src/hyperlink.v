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
		click_event_fn: fn (this &Hyperlink) {
			open_url(this.url)
		}
		url: cfg.url
		need_pack: cfg.pack
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
	line_height := ctx.line_height + 1
	if this.height < (line_height / 2) {
		this.height = line_height
	}

	x := this.x
	y := this.y

	color := if is_in(this, ctx.win.mouse_x, ctx.win.mouse_y) {
		gx.rgb(100, 100, 200)
	} else {
		if ctx.theme.text_color.r > 150 {
			gx.rgb(100, 180, 255)
		} else {
			gx.rgb(0, 128, 255)
		}
	}

	mut my := 0
	for spl in this.text.split('\n') {
		ctx.draw_text(x, y + this.height - line_height + my, fix_tab(spl), ctx.font, gx.TextCfg{
			size: size
			color: color
			bold: this.bold
		})

		ctx.set_cfg(gx.TextCfg{
			size: ctx.font_size
			color: ctx.theme.text_color
			bold: false
		})

		my += line_height
	}
	yp := y + this.height - 2
	ctx.gg.draw_line(x, yp, x + this.width, yp, color)

	this.debug_draw(ctx)
}

pub fn fix_tab(val string) string {
	return val.replace('\t', ' '.repeat(8))
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

	width := ctx.gg.text_width(fix_tab(btn.text))
	btn.width = width + 1
	th := ctx.gg.text_height(btn.text) + 4

	lines := btn.text.split_into_lines()
	btn.height = th * lines.len

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

[deprecated]
pub fn (mut this Hyperlink) set_config(fs int, abs bool, bold bool) {
	this.size = fs
	if abs {
		// Absolute font size
		this.abs_size = true
	}
	this.bold = bold
}

pub fn (mut this Hyperlink) set_click(b fn (voidptr)) {
	this.click_event_fn = b
}
