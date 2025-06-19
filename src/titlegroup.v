module iui

import gx

// Titlebox -
//	Titled border around children
pub struct Titlebox {
	Component_A
pub mut:
	padding int = 8
	compact bool
}

@[params]
pub struct TitleboxConfig {
pub:
	text     string
	children []Component
	padding  int = 8
	compact  bool
	width    int
	height   int
}

pub fn Titlebox.new(c TitleboxConfig) &Titlebox {
	return &Titlebox{
		text:     c.text
		children: c.children
		padding:  c.padding
		compact:  c.compact
		width:    c.width
		height:   c.height
	}
}

// Draw this component
pub fn (mut this Titlebox) draw(ctx &GraphicsContext) {
	text_height := ctx.line_height / 2

	for mut kid in this.children {
		y := this.y + this.padding + text_height + 5
		kid.draw_with_offset(ctx, this.x + this.padding, y)

		wid := kid.x + kid.width + (this.padding * 2)
		if wid > this.width {
			this.width = wid
		}

		hei := kid.y + kid.height + (this.padding * 2) + text_height + 5
		if hei > this.height {
			this.height = hei
		}
	}

	y := this.y + text_height
	x := this.x + 12
	hei := this.height - text_height

	wid := ctx.text_width(this.text)

	ctx.gg.draw_rect_empty(this.x, y, this.width, hei, ctx.theme.button_border_normal)

	if this.compact {
		ctx.gg.draw_rect_filled(this.x, this.y, wid, text_height + 1, ctx.theme.background)
		ctx.draw_text(this.x, this.y, this.text, ctx.font, gx.TextCfg{
			color: ctx.theme.text_color
			size:  ctx.font_size
		})
		return
	}

	ctx.gg.draw_rect_filled(x - 8, this.y, wid + 16, text_height + 1, ctx.theme.background)
	ctx.draw_text(x, this.y, this.text, ctx.font, gx.TextCfg{
		color: ctx.theme.text_color
		size:  ctx.font_size
	})
}
