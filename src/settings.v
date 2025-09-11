module iui

import gg
import os

// Reference:
// https://github.com/CommunityToolkit/Labs-Windows/issues/216
// https://github.com/microsoft/WinUI-Gallery/blob/main/WinUIGallery/SettingsPage.xaml

//
pub struct SettingsCard implements Container {
	Component_A
pub mut:
	text              string
	desc              string
	uicon             ?string
	stretch           bool
	container_pass_ev bool = true
	padding           int  = 16
}

@[params]
pub struct SettingsCardConfig {
pub:
	text        string
	description string
	uicon       ?string
	stretch     bool
	padding     int = 16
}

// TODO
pub fn SettingsCard.new(c SettingsCardConfig) &SettingsCard {
	return &SettingsCard{
		text:    c.text
		desc:    c.description
		uicon:   c.uicon
		stretch: c.stretch
		padding: c.padding
	}
}

// TODO: improve icons in .ttf
pub fn (this SettingsCard) draw_uicon(ctx &GraphicsContext, y int) int {
	txt := this.uicon or { return 0 }

	icon_font := ctx.win.extra_map['icon_ttf']

	if os.exists(icon_font) {
		ctx.draw_text(this.x + 12, y, txt, icon_font, gg.TextCfg{
			size:  ctx.win.font_size * 2
			color: ctx.theme.text_color
		})
		wid := ctx.text_width(txt) + 10
		return wid
	}
	return 0
}

pub fn (mut this SettingsCard) draw(ctx &GraphicsContext) {
	margin_side := 8

	if this.width <= 0 || this.stretch {
		nw := this.parent.width - (margin_side * 2)
		if nw > 0 {
			this.width = nw
		}
	}

	ctx.gg.draw_rounded_rect_filled(this.x, this.y, this.width, this.height, 4, ctx.theme.button_bg_normal)
	ctx.gg.draw_rounded_rect_empty(this.x, this.y, this.width, this.height, 4, ctx.theme.textbox_border)

	mut y := this.y + this.padding
	mut x := this.x + this.draw_uicon(ctx, y) + this.padding

	// Draw Title
	ctx.draw_text(x, y - 4, this.text, ctx.font, gg.TextCfg{
		size:  ctx.win.font_size + 4
		color: ctx.theme.text_color
		bold:  true
	})
	y += ctx.gg.text_height(this.text)

	// Draw Desc
	ctx.draw_text(x, y, this.desc, ctx.font, gg.TextCfg{
		size:  ctx.win.font_size
		color: ctx.theme.text_color
		bold:  true
	})

	if this.height == 0 {
		this.height = (this.padding * 2) + (ctx.line_height * 2)
	}

	cx := this.x + this.width - margin_side
	cy := this.y + this.padding

	for mut child in this.children {
		child.draw_with_offset(ctx, cx - child.width, cy)
	}
}

//
struct SettingsExpander {
	Component_A
}
