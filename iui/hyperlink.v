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
		click_event_fn: fn (a voidptr) {
			this := &Hyperlink(a)
			open_url(this.url)
		}
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

	width := text_width(btn.app, btn.text.replace('\t', ' '.repeat(8)))
	btn.width = width
	th := text_height(btn.app, '{!A')

	// btn.height = (th * btn.text.split('\n').len) + 4 + (btn.size)

	mut hi := 0
	for line in btn.text.split_into_lines() {
		if line.trim_space().len > 0 {
			hi += text_height(btn.app, line)
		} else {
			hi += th
		}
	}
	btn.height = hi + 4 + btn.size

	if btn.height < th {
		btn.height = th
	}
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
	sizh := (text_height(app, '!{A') + 1) / 2

	if this.is_mouse_rele {
		this.is_mouse_rele = false

		this.click_event_fn(this)
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

		app.gg.set_cfg(gx.TextCfg{
			size: app.font_size
			color: app.theme.text_color
			bold: false
		})

		my += line_height
	}
	app.gg.draw_line(x, y + height - 2, x + width, y + height - 2, gx.rgb(0, 100, 200))
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
