module iui

import gg
import gx

pub const blank_bg = gx.rgba(0, 0, 1, 0)

//
// Button - implements Component interface
pub struct Button {
	Component_A
pub mut:
	icon              int
	need_pack         bool
	extra             string
	user_data         voidptr
	override_bg_color gx.Color = blank_bg
	icon_width        int
	icon_height       int
	border_radius     int  = 4
	area_filled       bool = true
	is_action         bool
}

@[params]
pub struct ButtonConfig {
pub:
	text        string
	bounds      Bounds
	pack        bool
	should_pack bool
	user_data   voidptr
	area_filled bool = true
	icon        int  = -1
}

pub fn Button.new(c ButtonConfig) &Button {
	return &Button{
		text:        c.text
		icon:        c.icon
		x:           c.bounds.x
		y:           c.bounds.y
		width:       c.bounds.width
		height:      c.bounds.height
		user_data:   c.user_data
		need_pack:   c.should_pack || c.pack
		area_filled: c.area_filled
	}
}

// Set to apply the action_fill as Button style
pub fn (mut this Button) set_accent_filled(val bool) {
	this.is_action = val
}

// https://docs.oracle.com/javase/7/docs/api/javax/swing/AbstractButton.html#setContentAreaFilled(boolean)
pub fn (mut this Button) set_area_filled(val bool) {
	this.area_filled = val
}

pub fn (mut this Button) set_background(color gx.Color) {
	this.override_bg_color = color
}

pub fn (mut btn Button) draw(ctx &GraphicsContext) {
	if btn.need_pack {
		btn.pack_do(ctx)
	}

	text := btn.text
	sizh := ctx.line_height / 2 // ctx.text_height(text) / 2

	// Handle click
	if btn.is_mouse_rele {
		btn.handle_legacy_click(ctx)
		btn.is_mouse_rele = false
	}

	// Draw Button Background & Border
	btn.draw_background(ctx)

	if btn.width == 0 && btn.height == 0 {
		btn.pack_do(ctx)
		btn.need_pack = true
	}

	if btn.icon != -1 && btn.icon != -2 {
		wid := if btn.icon_width > 0 { btn.icon_width } else { btn.width }
		hei := if btn.icon_height > 0 { btn.icon_height } else { btn.height }
		ctx.gg.draw_image_with_config(gg.DrawImageConfig{
			img_id:   btn.icon
			img_rect: gg.Rect{
				x:      btn.x + (btn.width / 2) - (wid / 2)
				y:      btn.y + (btn.height / 2) - (hei / 2)
				width:  wid
				height: hei
			}
		})
		return
	}

	if btn.icon == -2 {
		ctx.gg.draw_image_with_config(gg.DrawImageConfig{
			img_id:    ctx.get_icon_sheet_id()
			img_rect:  gg.Rect{
				x:      btn.x + (btn.width / 2) - (btn.width / 2)
				y:      btn.y + (btn.height / 2) - (btn.height / 2)
				width:  btn.width
				height: btn.height
			}
			part_rect: gg.Rect{32 * btn.icon_width, 32 * btn.icon_height, 32, 32}
		})
	}

	// TODO: Better font detection
	font := if btn.font == 0 { ctx.font } else { ctx.win.extra_map['icon_ttf'] }

	cfgg := gx.TextCfg{
		size:   ctx.win.font_size
		color:  if btn.is_action { ctx.theme.accent_text } else { ctx.theme.text_color }
		family: font
	}
	ctx.gg.set_text_cfg(cfgg)
	size := ctx.text_width(text) / 2
	ctx.draw_text((btn.x + (btn.width / 2)) - size, btn.y + (btn.height / 2) - sizh, text,
		font, cfgg)
}

pub fn (mut btn Button) pack() {
	btn.need_pack = true
}

pub fn (mut btn Button) pack_do(ctx &GraphicsContext) {
	width := ctx.text_width(btn.text) + 6
	btn.width = width
	btn.height = min_h(ctx)
	btn.need_pack = false
}

fn (this &Button) draw_background(ctx &GraphicsContext) {
	mid_x := this.x + (this.width / 2)
	mid_y := this.y + (this.height / 2)

	mouse_x := ctx.win.mouse_x
	mouse_y := ctx.win.mouse_y

	mouse_in_x := abs(mid_x - mouse_x) < this.width / 2
	mouse_in_y := abs(mid_y - mouse_y) < this.height / 2

	mouse_in := mouse_in_x && mouse_in_y

	bg := this.get_bg(ctx, mouse_in)
	border := this.get_border(ctx, mouse_in)

	if this.area_filled {
		ctx.theme.button_fill_fn(this.x, this.y, this.width, this.height, this.border_radius,
			bg, ctx)
	}
	if this.border_radius != -1 {
		ctx.gg.draw_rounded_rect_empty(this.x, this.y, this.width, this.height, this.border_radius,
			border)
	}
	if this.extra.len != 0 && mouse_in {
		mut win := ctx.win
		win.tooltip = this.extra
	}
}

fn (b &Button) get_border(g &GraphicsContext, is_hover bool) gx.Color {
	if b.is_mouse_down {
		return g.theme.button_border_click
	}
	if is_hover {
		return g.theme.button_border_hover
	}
	return g.theme.button_border_normal
}

fn (b &Button) get_bg(g &GraphicsContext, is_hover bool) gx.Color {
	if b.override_bg_color != blank_bg {
		return b.override_bg_color
	}

	if b.is_action {
		if b.is_mouse_down {
			return g.theme.accent_fill_third
		}
		if is_hover {
			return g.theme.accent_fill_second
		}
		return g.theme.accent_fill
	}

	should := true // b.app.bar == unsafe { nil } || b.app.bar.tik > 90
	if b.is_mouse_down && should {
		return g.theme.button_bg_click
	}
	if is_hover && should {
		return g.theme.button_bg_hover
	}
	return g.theme.button_bg_normal
}

// Deprecated functions:
@[deprecated: 'use subscribe_event']
pub fn (mut b Button) set_click_fn(old fn (voidptr, voidptr, voidptr), extra_data voidptr) {
	b.user_data = extra_data
}

fn (mut btn Button) handle_legacy_click(g &GraphicsContext) {
}
