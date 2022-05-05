module iui

import gg
import gx

// Hyperlink - implements Component interface
struct Hyperlink {
	Component_A
pub mut:
	app            &Window
	text           string
	click_event_fn fn (voidptr)
	in_modal       bool
	need_pack      bool
	size           int
	bold           bool
	url            string
}

[params]
pub struct HyperlinkConfig {
	bounds Bounds
}

pub fn hyperlink(app &Window, text string, url string, conf HyperlinkConfig) &Hyperlink {
	return &Hyperlink{
		text: text
		app: app
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

pub fn (mut btn Hyperlink) draw(ctx &GraphicsContext) {
	btn.app.draw_hyperlink(btn.x, btn.y, btn.width, btn.height, mut btn)
}

pub fn (mut btn Hyperlink) pack() {
	btn.need_pack = true
}

pub fn (mut btn Hyperlink) pack_do() {
	// Set font size
	btn.app.graphics_context.set_cfg(gx.TextCfg{
		size: btn.app.font_size + btn.size
		color: btn.app.theme.text_color
		bold: btn.bold
	})

	width := text_width(btn.app, btn.text.replace('\t', ' '.repeat(8)))
	btn.width = width + 1
	th := text_height(btn.app, '{!A') + btn.size

	lines := btn.text.split_into_lines()
	hi := (th * lines.len)
	btn.height = hi + 4 + btn.size

	if btn.height < th {
		btn.height = th
	}
	btn.need_pack = false

	// Reset for text_height
	btn.app.graphics_context.set_cfg(gx.TextCfg{
		size: btn.app.font_size
		color: btn.app.theme.text_color
		bold: false
	})
}

fn (mut app Window) draw_hyperlink(x int, y int, width int, height int, mut this Hyperlink) {
	if this.need_pack {
		this.pack_do()
	}

	if this.is_mouse_rele {
		this.is_mouse_rele = false
		this.click_event_fn(this)
	}

	ctx := app.graphics_context
	ctx.set_cfg(gx.TextCfg{
		size: app.font_size + this.size
		color: app.theme.text_color
		bold: this.bold
	})

	// Draw Button Text
	line_height := text_height(app, '1A{W') + 1
	if this.height < (line_height / 2) {
		this.height = line_height
	}

	mut my := 0
	for mut spl in this.text.split('\n') {
		ctx.draw_text(x, y + height - line_height + my, spl.replace('\t', '  '.repeat(8)),
			ctx.font, gx.TextCfg{
			size: app.font_size + this.size
			color: gx.rgb(0, 100, 200)
			bold: this.bold
		})

		ctx.set_cfg(gx.TextCfg{
			size: app.font_size
			color: app.theme.text_color
			bold: false
		})

		my += line_height
	}
	app.gg.draw_line(x, y + height - 2, x + width, y + height - 2, gx.rgb(0, 100, 200))

	if app.debug_draw {
		app.gg.draw_rect_empty(this.x, this.y, this.width, this.height, gx.blue)
		app.gg.draw_line(this.x, this.y, this.x + this.width, this.y + this.height, gx.blue)
		app.gg.draw_line(this.x, this.y + this.height, this.x + this.width, this.y, gx.blue)
	}
}

pub fn (mut this Hyperlink) set_config(fs int, abs bool, bold bool) {
	this.size = fs
	if abs {
		// Absolute font size
		this.size = fs - this.app.font_size
	}
	this.bold = bold
}

pub fn (mut this Hyperlink) set_click(b fn (voidptr)) {
	this.click_event_fn = b
}
