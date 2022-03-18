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

pub fn hyperlink(app &Window, text string, url string) &Hyperlink {
	return &Hyperlink{
		text: text
		app: app
		click_event_fn: fn (a voidptr) {}
		url: url
	}
}

pub fn (mut btn Hyperlink) draw() {
	btn.app.draw_hyperlink(btn.x, btn.y, btn.width, btn.height, mut btn)
}

pub fn (mut btn Hyperlink) pack() {
	btn.need_pack = true
}

pub fn (mut btn Hyperlink) pack_do() {
	// Set font size
	btn.app.gg.set_cfg(gx.TextCfg{
		size: btn.app.font_size + btn.size
		color: btn.app.theme.text_color
		bold: btn.bold
	})

	width := text_width(btn.app, btn.text + 'ab')
	btn.width = width
	btn.height = text_height(btn.app, btn.text) + 4 + (btn.size)
	btn.need_pack = false

	// Reset for text_height
	btn.app.gg.set_cfg(gx.TextCfg{
		size: btn.app.font_size
		color: btn.app.theme.text_color
		bold: false
	})
}

fn (mut app Window) draw_hyperlink(x int, y int, width int, height int, mut this Hyperlink) {
	if this.need_pack {
		this.pack_do()
	}

	text := this.text
	sizh := text_height(app, text) / 2

	if this.is_mouse_rele {
		this.is_mouse_rele = false
		this.click_event_fn(this)
		println('clicked')
		open_url(this.url)
	}

	// Draw Button Text
	mut line_height := text_height(app, '1A{')
	mut my := 0
	for mut spl in text.split('\n') {
		app.gg.draw_text(x, y + (height / 2) - sizh + my, spl.replace('\t', '  '.repeat(8)),
			gx.TextCfg{
			size: app.font_size + this.size
			color: gx.rgb(0, 100, 200)
			bold: this.bold
		})
		// if this.size != (app.font_size + this.size) {
		// Reset for text_height
		app.gg.set_cfg(gx.TextCfg{
			size: app.font_size
			color: app.theme.text_color
			bold: false
		})
		//}

		my += line_height
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
