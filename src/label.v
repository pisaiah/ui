module iui

import gg
import gx

// Label - implements Component interface
pub struct Label {
	Component_A
pub mut:
	app           &Window
	text          string
	need_pack     bool
	size          int
	bold          bool
	abs_fsize     bool
	center_text_y bool
	color         gx.Color
}

@[params]
pub struct LabelConfig {
	should_pack bool
	x           int
	y           int
	height      int
	width       int
	text        string
}

pub fn Label.new(conf LabelConfig) &Label {
	return &Label{
		app: unsafe { nil }
		text: conf.text
		x: conf.x
		y: conf.y
		color: gx.rgba(0, 0, 0, 0)
		height: conf.height
		width: conf.width
		need_pack: conf.should_pack
	}
}

pub fn (mut btn Label) draw(ctx &GraphicsContext) {
	if btn.app == unsafe { nil } {
		btn.app = ctx.win
	}
	ctx.win.draw_label(btn.x, btn.y, btn.width, btn.height, mut btn, ctx)
}

pub fn (mut this Label) pack() {
	this.need_pack = true
}

pub fn (mut btn Label) pack_do(ctx &GraphicsContext) {
	// Set font size
	ctx.set_cfg(gx.TextCfg{
		size: ctx.win.font_size + btn.size
		color: ctx.win.theme.text_color
		bold: btn.bold
	})

	lines := btn.text.split_into_lines()

	mut min_width := 0
	for line in lines {
		width := ctx.text_width(line)
		if min_width < width {
			min_width = width
		}
	}
	btn.width = min_width

	th := text_height(ctx.win, '{!A')
	hi := th * lines.len

	// font_size := btn.size
	btn.height = hi + 4 // + (font_size * lines.len)
	if btn.height < th {
		btn.height = th
	}

	btn.need_pack = false

	// Reset for text_height
	ctx.set_cfg(gx.TextCfg{
		size: ctx.win.font_size
		color: ctx.win.theme.text_color
		bold: false
	})
}

fn (this &Label) get_color() gx.Color {
	if this.color.a != 0 {
		return this.color
	} else {
		return this.app.theme.text_color
	}
}

fn (app Window) draw_label(x int, y int, width int, height int, mut this Label, ctx &GraphicsContext) {
	if this.need_pack {
		this.pack_do(ctx)
		this.need_pack = false
	}

	text := this.text
	sizh := text_height(app, text) / 2

	if this.is_mouse_rele {
		this.is_mouse_rele = false
	}

	size := if this.abs_fsize {
		this.size
	} else {
		this.size + app.font_size
	}

	// Draw Button Text
	mut my := 0
	for spl in text.split('\n') {
		yp := if this.center_text_y { y + (height / 2) - sizh + my } else { y + my }

		ctx.draw_text(x, yp, spl.replace('\t', '  '.repeat(8)), ctx.font, gx.TextCfg{
			size: size
			color: this.get_color()
			bold: this.bold
		})
		if this.size != (app.font_size + this.size) {
			// Reset for text_height
			if this.size == 0 {
				app.reset_text_config(ctx)
			}
		}

		if this.size > 0 {
			my += text_height(app, spl)
			app.reset_text_config(ctx)
		} else {
			my += ctx.line_height
		}
	}

	app.reset_text_config(ctx)
	this.debug_draw()
}

fn (app &Window) reset_text_config(ctx &GraphicsContext) {
	ctx.set_cfg(gx.TextCfg{
		size: app.font_size
		color: app.theme.text_color
		bold: false
	})
}

fn (this &Label) debug_draw() {
	if !this.app.debug_draw {
		return
	}
	this.app.gg.draw_rect_empty(this.x, this.y, this.width, this.height, gx.blue)
	this.app.gg.draw_line(this.x, this.y, this.x + this.width, this.y + this.height, gx.blue)
	this.app.gg.draw_line(this.x, this.y + this.height, this.x + this.width, this.y, gx.blue)
}

pub fn (mut this Label) set_config(fs int, abs bool, bold bool) {
	this.size = fs
	this.abs_fsize = abs
	this.bold = bold
}
