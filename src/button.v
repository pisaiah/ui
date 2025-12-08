module iui

import gg

pub const blank_bg = gg.rgba(0, 0, 1, 0)

//
// Button - implements Component interface
pub struct Button {
	Component_A
pub mut:
	icon              int
	need_pack         bool
	extra             string
	user_data         voidptr
	override_bg_color gg.Color = blank_bg
	icon_width        int
	icon_height       int
	border_radius     int = 4
	is_action         bool
	icon_info         ?ButtonIconInfo
	font_size         ?int
	area_filled       ?AreafilledConfig
}

pub struct AreafilledConfig {
mut:
	normal bool = true
	hover  bool = true
	down   bool = true
}

pub fn (this AreafilledConfig) is_filled(hover bool, down bool) bool {
	if hover {
		return this.hover
	}
	if down {
		return this.down
	}
	return this.normal
}

pub fn (this &Button) is_area_filled(hover bool) bool {
	if this.area_filled != none {
		return this.area_filled.is_filled(hover, this.is_mouse_down)
	}
	return true
}

pub struct ButtonIconInfo {
pub:
	id         string
	atlas_size int
	skip_text  bool
	x          int
	y          int
	align      ButtonIconAlign
}

pub enum ButtonIconAlign {
	left
	center
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
	accent      bool
	icon        int = -1
	font_size   ?int
	width       int
	height      int
	on_click    ?fn (voidptr)
}

fn (c ButtonConfig) width() int {
	if c.bounds.height != 0 {
		return c.bounds.width
	}
	return c.width
}

fn (c ButtonConfig) height() int {
	if c.bounds.height != 0 {
		return c.bounds.height
	}
	return c.height
}

pub fn Button.new(c ButtonConfig) &Button {
	mut btn := &Button{
		text:        c.text
		icon:        c.icon
		x:           c.bounds.x
		y:           c.bounds.y
		width:       c.width()
		height:      c.height()
		user_data:   c.user_data
		need_pack:   c.should_pack || c.pack
		area_filled: AreafilledConfig{
			normal: c.area_filled
			hover:  c.area_filled
			down:   c.area_filled
		}
		font_size:   c.font_size
		is_action:   c.accent
	}
	btn.border = ButtonBorder{
		component: btn
	}

	if c.on_click != none {
		btn.subscribe_event('mouse_up', c.on_click)
	}

	return btn
}

// Set to apply the action_fill as Button style
pub fn (mut this Button) set_accent_filled(val bool) {
	this.is_action = val
}

// https://docs.oracle.com/javase/7/docs/api/javax/swing/AbstractButton.html#setContentAreaFilled(boolean)
pub fn (mut this Button) set_area_filled(val bool) {
	if this.area_filled != none {
		this.area_filled.normal = val
		this.area_filled.hover = val
		this.area_filled.down = val
	}
}

pub enum AreaFilledState {
	normal
	hover
	down
}

pub fn (mut this Button) set_area_filled_state(val bool, state AreaFilledState) {
	if this.area_filled == none {
		this.area_filled = AreafilledConfig{}
	}

	if this.area_filled != none {
		match state {
			.normal {
				this.area_filled.normal = val
			}
			.hover {
				this.area_filled.hover = val
			}
			.down {
				this.area_filled.down = val
			}
		}
	}
}

pub fn (mut this Button) set_background(color gg.Color) {
	this.override_bg_color = color
}

pub fn (mut btn Button) draw(ctx &GraphicsContext) {
	if btn.need_pack {
		btn.pack_do(ctx)
	}

	text := btn.text

	// Handle click
	if btn.is_mouse_rele {
		btn.is_mouse_rele = false
	}
	
	if btn.state == .click {
		btn.state = .normal
	}

	// Draw Button Background & Border	
	btn.draw_background(ctx)

	if btn.width == 0 && btn.height == 0 {
		btn.pack_do(ctx)
		btn.need_pack = true
	}

	if btn.icon != -1 && btn.icon >= 0 {
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

	if btn.icon_info != none {
		info := btn.icon_info // or { return }
		wid := if btn.icon_width > 0 { btn.icon_width } else { btn.width }
		hei := if btn.icon_height > 0 { btn.icon_height } else { btn.height }

		ctx.gg.draw_image_with_config(gg.DrawImageConfig{
			img_id:    ctx.icon_cache[info.id]
			img_rect:  gg.Rect{
				x:      btn.x + (btn.width / 2) - (wid / 2)
				y:      btn.y + (btn.height / 2) - (hei / 2)
				width:  wid
				height: hei
			}
			part_rect: gg.Rect{info.atlas_size * info.x, info.atlas_size * info.y, info.atlas_size, info.atlas_size}
		})

		if info.skip_text {
			return
		}
	}

	// TODO: Better font detection
	font := if btn.font == 0 { ctx.font } else { ctx.win.extra_map['icon_ttf'] }
	font_size := if btn.font_size != none { btn.font_size } else { ctx.win.font_size }

	// sizh := ctx.line_height / 2 // ctx.text_height(text) / 2
	cfgg := gg.TextCfg{
		size:   font_size
		color:  if btn.is_action { ctx.theme.accent_text } else { ctx.theme.text_color }
		family: font
	}
	ctx.gg.set_text_cfg(cfgg)

	sizh := if btn.font_size != none {
		ctx.gg.text_height(text) / 2
	} else {
		ctx.line_height / 2
	}

	if btn.children.len != 0 {
		btn.draw_children_and_text(sizh, text, font, cfgg, ctx)
		return
	}

	size := ctx.text_width(text) / 2
	ctx.draw_text((btn.x + (btn.width / 2)) - size, btn.y + (btn.height / 2) - sizh, text,
		font, cfgg)
	ctx.reset_text_font()
}

fn (mut btn Button) draw_children_and_text(sizh int, text string, font string, cfg gg.TextCfg, ctx &GraphicsContext) {
	pad := 4
	mut xo := 0
	for mut item in btn.children {
		item.set_parent(btn)
		item.draw_with_offset(ctx, btn.x + pad, btn.y + pad)

		if btn.width < item.width {
			btn.width = item.width + pad * 2
		}
		if btn.height < item.height {
			btn.height = item.height + pad * 2
		}
		xo = (item.width / 2) + 2
	}
	size := ctx.text_width(text) / 2
	ctx.draw_text((btn.x + (btn.width / 2)) - size + xo, btn.y + (btn.height / 2) - sizh,
		text, font, cfg)
	ctx.reset_text_font()
}

pub fn (mut btn Button) pack() {
	btn.need_pack = true
}

pub fn (mut btn Button) pack_do(ctx &GraphicsContext) {
	width := ctx.text_width(btn.text) + 6
	btn.width = width

	if btn.children.len != 0 {
		btn.width = width + btn.children[0].width + 12
		return
	}

	btn.height = min_h(ctx)
	btn.need_pack = false
}

fn (mut this Button) draw_background(ctx &GraphicsContext) {
	// mid_x := this.x + (this.width / 2)
	// mid_y := this.y + (this.height / 2)

	// mouse_x := ctx.win.mouse_x
	// mouse_y := ctx.win.mouse_y

	// mouse_in_x := abs(mid_x - mouse_x) < this.width / 2
	// mouse_in_y := abs(mid_y - mouse_y) < this.height / 2

	// mouse_in := mouse_in_x && mouse_in_y
	mouse_in := this.state == .hover

	bg := this.get_bg(ctx, mouse_in)
	border := this.get_border(ctx, mouse_in)

	// has_border := this.border_radius != -1
	area_filled := this.is_area_filled(mouse_in)

	radius := if ctx.theme.name == 'Ocean' {
		0
	} else {
		this.border_radius
	}

	if this.border != none {
		mut bord := this.border
		if mut bord is ButtonBorder {
			bord.bg_alpha = bg.a
			bord.area_filled = area_filled
			bord.color = border
			bord.radius = radius
		}
		this.border.draw(ctx)
	}

	if area_filled {
		border_radius := if radius != -1 { radius } else { 1 }
		ctx.theme.button_fill_fn(this.x + 1, this.y + 1, this.width - 2, this.height - 2,
			border_radius, bg, ctx)
	}

	if this.extra.len != 0 && mouse_in {
		mut win := ctx.win
		win.tooltip = this.extra
	}
}

fn (b &Button) get_border(g &GraphicsContext, is_hover bool) gg.Color {
	if b.is_mouse_down {
		// return g.theme.button_border_click
		return g.theme.accent_fill_second
	}
	if is_hover {
		return g.theme.accent_fill

		// return g.theme.button_border_hover
	}

	if b.is_action {
		return g.theme.accent_fill
	}

	return g.theme.button_border_normal
}

fn (b &Button) get_bg(g &GraphicsContext, is_hover bool) gg.Color {
	if b.override_bg_color != blank_bg {
		return b.override_bg_color
	}

	if b.is_action {
		if b.state == .press {
			return g.theme.accent_fill_third
		}
		if is_hover {
			return g.theme.accent_fill_second
		}
		return g.theme.accent_fill
	}

	if b.state == .press {
		return g.theme.button_bg_click
	}
	if is_hover {
		return g.theme.button_bg_hover
	}
	return g.theme.button_bg_normal
}

pub struct ButtonBorder implements Border {
	AbstractBorder
mut:
	area_filled bool
	bg_alpha    u8
	color       gg.Color
}

fn (border &ButtonBorder) draw(ctx &GraphicsContext) {
	mut this := border.get_component[Button]()
	// color := gg.red // ctx.theme.button_border_normal

	if border.radius == -1 {
		return
	}

	if border.area_filled && border.bg_alpha > 200 {
		ctx.gg.draw_rounded_rect_filled(this.x, this.y, this.width, this.height, border.radius,
			border.color)
	}

	if !border.area_filled || border.bg_alpha < 200 {
		ctx.gg.draw_rounded_rect_empty(this.x, this.y, this.width, this.height, border.radius,
			border.color)
	}
}
