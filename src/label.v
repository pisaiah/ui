module iui

import gg

// Label - implements Component interface
pub struct Label {
	Component_A
pub mut:
	text           string
	need_pack      bool
	size           int
	bold           bool
	abs_fsize      bool
	center_text_y  bool
	vertical_align gg.VerticalAlign
	color          gg.Color
	em_size        f32
}

@[params]
pub struct LabelConfig {
pub:
	should_pack    bool
	pack           bool
	x              int
	y              int
	height         int
	width          int
	text           string
	vertical_align gg.VerticalAlign
	// = .middle
	bold    bool
	em_size f32
}

pub enum SizeUnit {
	em
	// Em quadrat, (ex 1em)
	px
	// Pixel Size, (ex 16px)
}

pub fn Label.new(c LabelConfig) &Label {
	return &Label{
		text:           c.text
		x:              c.x
		y:              c.y
		color:          gg.rgba(0, 0, 0, 0)
		height:         c.height
		width:          c.width
		need_pack:      c.should_pack || c.pack
		bold:           c.bold
		em_size:        c.em_size
		vertical_align: c.vertical_align
	}
}

// set the font size of the Label
pub fn (mut l Label) set_font_size(val f32, unit SizeUnit) {
	if unit == .px {
		l.size = int(val)
		l.abs_fsize = true
		return
	}
	l.abs_fsize = false
	l.em_size = val
}

pub fn (mut l Label) set_size_em(val f32) {
	l.em_size = val
}

fn (l &Label) font_size(ctx &GraphicsContext) int {
	if l.em_size == 0 {
		if l.abs_fsize {
			return l.size
		}
		return l.size + ctx.font_size
	}
	return int(l.em_size * ctx.font_size)
}

pub fn (mut lbl Label) draw(ctx &GraphicsContext) {
	// deprecated old center_text_y
	if lbl.center_text_y {
		lbl.vertical_align = .middle
	}

	if lbl.need_pack {
		lbl.pack_do(ctx)
		lbl.need_pack = false
	}

	if lbl.is_mouse_rele {
		lbl.is_mouse_rele = false
	}

	lbl.draw_label(ctx)
}

pub fn (mut this Label) pack() {
	if this.center_text_y {
		this.vertical_align = .middle
	}

	this.need_pack = true
}

pub fn (mut lbl Label) pack_do(ctx &GraphicsContext) {
	// Set font size
	ctx.set_cfg(gg.TextCfg{
		size: lbl.font_size(ctx)
		// ctx.win.font_size + lbl.size
		color: ctx.win.theme.text_color
		bold:  lbl.bold
	})

	lines := lbl.text.split_into_lines()

	for line in lines {
		width := ctx.text_width(line)
		if lbl.width < width {
			lbl.width = width
		}
	}

	th := ctx.gg.text_height('${lbl.text} {!A;')
	hi := th * lines.len

	lbl.height = hi
	if lbl.height < hi {
		lbl.height = hi
	}

	if lbl.height < ctx.line_height {
		lbl.height = ctx.line_height
	}

	lbl.need_pack = false
	reset_text_config(ctx)
}

fn (this &Label) get_color(ctx &GraphicsContext) gg.Color {
	if this.color.a != 0 {
		return this.color
	} else {
		return ctx.theme.text_color
	}
}

fn (this &Label) draw_label(ctx &GraphicsContext) {
	// Avoid sending draw instructions if our parent's parent is out of bounds
	if !isnil(this.parent) {
		if !isnil(this.parent.parent) {
			ph := this.parent.parent.y + this.parent.parent.height
			if this.y > ph {
				return
			}
		}
	}

	size := this.font_size(ctx)

	cfg := gg.TextCfg{
		size:           size
		color:          this.get_color(ctx)
		vertical_align: this.vertical_align
		bold:           this.bold
	}

	ctx.set_cfg(cfg)

	lines := this.text.split('\n')
	sizh := (this.height / 2) - ctx.line_height * (lines.len / 2)

	// Draw Button Text
	mut my := 0
	for spl in lines {
		yp := if this.vertical_align == .middle { this.y + sizh + my } else { this.y + my }
		my += if size != ctx.font_size { ctx.gg.text_height(spl) } else { ctx.line_height }

		if !isnil(this.parent) {
			if yp < 0 {
				continue
			}
		}

		ctx.draw_text(this.x, yp, spl.replace('\t', '  '.repeat(8)), ctx.font, cfg)
	}

	reset_text_config(ctx)
	this.debug_draw(ctx)
}

fn reset_text_config(ctx &GraphicsContext) {
	ctx.set_cfg(gg.TextCfg{
		size:  ctx.font_size
		color: ctx.theme.text_color
		bold:  false
	})
}

fn (this &Label) debug_draw(ctx &GraphicsContext) {
	if !ctx.win.debug_draw {
		return
	}
	ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, gg.blue)
	ctx.gg.draw_line(this.x, this.y, this.x + this.width, this.y + this.height, gg.blue)
	ctx.gg.draw_line(this.x, this.y + this.height, this.x + this.width, this.y, gg.blue)
}

@[deprecated: 'Use Label.set_size_em, Label.set_bold']
pub fn (mut this Label) set_config(fs int, abs bool, bold bool) {
	this.size = fs
	this.abs_fsize = abs
	this.bold = bold
}

pub fn (mut this Label) set_bold(val bool) {
	this.bold = val
}
