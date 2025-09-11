module iui

import gg

// https://docs.oracle.com/javase/8/docs/api/javax/swing/JDesktopPane.html
//[heap]
pub struct DesktopPane {
	Panel
}

pub fn DesktopPane.new() &DesktopPane {
	return &DesktopPane{
		layout: unsafe { nil }
	}
}

// https://docs.oracle.com/javase/tutorial/uiswing/components/internalframe.html
pub struct InternalFrame {
	Component_A
mut:
	mx       int = -1
	my       int = -1
	pw       int
	ph       int
	init     bool
	controls &Panel
	max      bool
	rem      bool
	active   bool
	ctrl_img u8
	ctrl_sty u8
}

@[params]
pub struct FrameConfig {
pub:
	text   string
	bounds Bounds
}

pub fn InternalFrame.new(c FrameConfig) &InternalFrame {
	return &InternalFrame{
		text:     c.text
		x:        c.bounds.x
		y:        c.bounds.y
		width:    c.bounds.width
		height:   c.bounds.height
		controls: Panel.new(layout: FlowLayout.new(hgap: 0, vgap: 2))
	}
}

fn (mut this DesktopPane) draw(ctx &GraphicsContext) {
	this.children.sort(a.z_index > b.z_index)

	// Draw backwards
	for i in -this.children.len .. 0 {
		mut kid := this.children[(-i) + -1]

		if kid.x < 0 {
			kid.x = 0
		}
		if kid.y < 0 {
			kid.y = 0
		}

		if kid.parent == unsafe { nil } {
			kid.set_parent(this)
		}

		kid.draw_with_offset(ctx, this.x, this.y)
	}
}

pub fn (mut this DesktopPane) add_child(frame &InternalFrame) {
	this.children << frame
}

fn (mut this InternalFrame) draw(ctx &GraphicsContext) {
	if !this.init {
		this.init_controls(ctx)
	}

	if this.width == 0 {
		this.width = ctx.text_width(this.text) + 120
	}

	if this.height == 0 {
		this.height = 120
	}

	this.do_move(ctx)

	bg := if this.active { ctx.theme.button_bg_click } else { ctx.theme.textbox_border }
	wid := this.width
	hei := this.height
	top := 28
	bord_wid := 5
	wid_2 := wid - (bord_wid * 2)
	ttop := this.y + (ctx.line_height / 2)

	if this.active {
		ctx.draw_rounded_rect(this.x, this.y, wid, hei, 8, ctx.theme.accent_fill, bg)
	} else {
		ctx.gg.draw_rounded_rect_filled(this.x, this.y, wid, hei, 8, bg)
	}

	ctx.gg.draw_text(this.x + 6, ttop, this.text, gg.TextCfg{
		size:  ctx.font_size
		color: ctx.theme.text_color
	})

	ctx.gg.draw_rect_filled(this.x + bord_wid, this.y + top, wid_2, hei - top - bord_wid,
		ctx.theme.background)

	this.controls.set_bounds(this.width - 82, -28, 82, 28)

	if ctx.theme.name == 'Ocean' {
		if this.ctrl_img == 0 {
			this.change_controls_style(ctx, true)
			this.ctrl_img = 1
		}
	} else if this.ctrl_img == 1 && this.ctrl_sty != 1 {
		this.change_controls_style(ctx, false)
		this.ctrl_img = 0
	}

	if this.ctrl_sty != 0 && this.ctrl_img != this.ctrl_sty {
		this.change_controls_style(ctx, this.ctrl_sty == 2)
	}

	this.children.sort(a.z_index < b.z_index)

	if this.children.len == 2 {
		if this.children[0] is Panel || this.children[0] is ScrollView {
			this.children[0].width = this.width - (bord_wid * 2)
			this.children[0].height = this.height - top - bord_wid
		}
	}

	for mut kid in this.children {
		if kid.parent == unsafe { nil } {
			kid.set_parent(this)
		}
		kid.draw_with_offset(ctx, this.x + bord_wid, this.y + top)
	}
}

enum FrameControlStyle as u8 {
	auto = 0
	text = 1
	icon = 2
}

fn (mut this InternalFrame) set_controls_style(filled bool, s FrameControlStyle) {
	this.ctrl_sty = u8(s)
}

fn (mut this InternalFrame) change_controls_style(g &GraphicsContext, filled bool) {
	txts := ['\uE937', '\uE938', '\uE8BB']
	for i, mut com in this.controls.children {
		if mut com is Button {
			if filled {
				com.text = ' '
				com.icon = -2
				com.icon_width = i
				com.icon_height = 1
			} else {
				com.text = txts[i]
				com.font = 1
				com.icon = -1
				com.set_area_filled_state(false, .normal)
			}
		}
	}
}

fn (mut this InternalFrame) init_controls(g &GraphicsContext) {
	this.init = true

	mut min := Button.new(icon: -2, text: ' ', font_size: 9)
	mut max := Button.new(icon: -2, text: ' ', font_size: 9)
	mut xxx := Button.new(icon: -2, text: ' ', font_size: 9)

	if g.icon_ttf_exists() && true {
		min.text = '\uE937'
		max.text = '\uE938'
		xxx.text = '\uE8BB'
		mut btns := [min, max, xxx]

		for mut btn in btns {
			btn.font = 1
			btn.icon = -1
			btn.set_area_filled_state(false, .normal)
		}
	} else {
		min.icon_width = 0
		min.icon_height = 1
		max.icon_width = 1
		max.icon_height = 1
		xxx.icon_width = 2
		xxx.icon_height = 1
	}

	min.border_radius = -1
	max.border_radius = -1
	xxx.border_radius = -1

	min.set_bounds(0, 0, 24, 24)
	max.set_bounds(0, 0, 26, 24)
	xxx.set_bounds(0, 0, 25, 24)

	max.subscribe_event('mouse_up', btn_max_click)

	xxx.subscribe_event('mouse_up', btn_close_click)

	this.controls.add_child(min)
	this.controls.add_child(max)
	this.controls.add_child(xxx)
	this.add_child(this.controls)
}

fn btn_max_click(mut e MouseEvent) {
	// Button -> Panel -> Frame -> DesktopPane
	mut frame := &InternalFrame(e.target.parent.parent)
	mut desk := frame.parent

	// TODO: improve this
	if frame.max {
		frame.width = frame.pw
		frame.height = frame.ph
		frame.max = false
	} else {
		frame.x = 0
		frame.y = 0
		frame.pw = frame.width
		frame.ph = frame.height
		frame.width = desk.width
		frame.height = desk.height
		frame.max = true
	}
}

fn btn_close_click(mut e MouseEvent) {
	mut frame := &InternalFrame(e.target.parent.parent)
	mut desk := frame.parent

	frame.rem = true

	for i, mut kid in desk.children {
		if mut kid is InternalFrame {
			if kid.rem {
				desk.children.delete(i)
				unsafe { free(kid) }
			}
		}
	}
}

fn (mut this InternalFrame) do_move(ctx &GraphicsContext) {
	if this.is_mouse_down && !this.active {
		this.active = false

		mut desk := unsafe { &DesktopPane(this.parent) }
		for mut kid in desk.children {
			if mut kid is InternalFrame {
				if kid.active {
					kid.mx = -1
					kid.my = 0
					kid.active = false
				}
			}
		}
		this.active = true

		this.z_index = this.parent.children[0].z_index + 1
	}

	if !this.active {
		return
	}

	if this.is_mouse_down {
		mx := ctx.win.mouse_x
		my := ctx.win.mouse_y

		if this.mx == -1 {
			this.mx = mx - this.x
			this.my = my - this.y

			if mx >= this.x + this.width - 12 && my >= this.y + this.height - 12 {
				ctx.gg.draw_rect_filled(this.x + this.mx, this.y + this.my, 12, 12, gg.blue)
				this.my = -2
			}
		} else {
			if this.my == -2 {
				ctx.gg.draw_rect_filled(mx, my, 12, 12, gg.blue)

				nw := mx - this.x
				nh := my - this.y
				min := 50

				this.width = if nw > min { nw } else { min }
				this.height = if nh > min { nh } else { min }
				return
			}

			if this.my > 28 {
				return
			}

			this.x = mx - this.mx
			this.y = my - this.my
		}
	} else {
		if this.mx != -1 {
			this.mx = -1
			this.my = -1
		}
	}
}
