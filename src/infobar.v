module iui

import gx
import os

// https://learn.microsoft.com/en-us/windows/apps/design/controls/infobar
pub struct InfoBar {
	Component_A
pub mut:
	text     string
	title    string
	closable bool
}

@[params]
pub struct InfoBarConfig {
pub:
	title    string
	text     string
	closable bool
}

pub fn InfoBar.new(c InfoBarConfig) &InfoBar {
	mut bar := &InfoBar{
		text:     c.text
		title:    c.title
		closable: c.closable
	}

	if c.closable {
		mut close := Button.new(
			text:      '\uE8BB'
			font_size: 9
			width:     32
			height:    16
		)
		close.font = 1
		bar.add_child(close)
	}
	return bar
}

// Draw Background & Border
fn (bar &InfoBar) draw_background(g &GraphicsContext) {
	g.draw_corner_rect(bar.x, bar.y, bar.width, bar.height, g.theme.textbox_border, g.theme.textbox_background)
}

fn (mut bar InfoBar) draw(g &GraphicsContext) {
	cfg_bold := gx.TextCfg{
		size:  g.font_size
		bold:  true
		color: g.theme.text_color
	}
	cfg_norm := gx.TextCfg{
		size:  g.font_size
		bold:  false
		color: g.theme.text_color
	}

	g.set_cfg(cfg_bold)

	lines := bar.text.split('\n')
	sizh := (bar.height / 2) - g.line_height * (lines.len / 2)

	padd := 8

	if bar.width == 0 {
		if bar.parent != unsafe { nil } {
			bar.width = bar.parent.width
		}
	}

	if bar.height == 0 {
		bar.height = (lines.len * g.line_height) + padd * 2
	}

	bar.draw_background(g)

	uicon := '\ue949'
	icon_font := g.win.extra_map['icon_ttf']

	mut xp := 0
	mut my := padd

	if os.exists(icon_font) {
		g.draw_text(bar.x + 4, bar.y + padd, uicon, icon_font, gx.TextCfg{
			size:  g.win.font_size
			color: g.theme.accent_fill
		})
		xp += g.text_width(uicon) + padd + 4
	}

	g.draw_text(bar.x + xp, bar.y + my, bar.title, g.font, cfg_bold)
	xp += g.text_width(bar.title) + 16

	g.set_cfg(cfg_norm)

	// Draw Button Text
	for spl in lines {
		g.draw_text(bar.x + xp, bar.y + my, spl.replace('\t', '  '.repeat(8)), g.font,
			cfg_norm)
		my += g.line_height
	}

	reset_text_config(g)

	// Children
	for mut child in bar.children {
		if isnil(child.parent) {
			child.set_parent(bar)
		}

		child.draw_with_offset(g, bar.x + bar.width - child.width - padd, bar.y + (bar.height / 2) - (child.height / 2))
		my += child.height + 4
	}
}
