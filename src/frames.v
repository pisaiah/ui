module iui

import gg
import gx

// https://docs.oracle.com/javase/8/docs/api/javax/swing/JDesktopPane.html
//[heap]
pub struct DesktopPane {
	Panel
mut:
	active &InternalFrame
}

pub fn DesktopPane.new() &DesktopPane {
	return &DesktopPane{
		layout: unsafe { nil }
		active: unsafe { nil }
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
}

pub fn InternalFrame.new() &InternalFrame {
	return &InternalFrame{
		text: 'InternalFrameDemo'
		width: 300
		height: 200
		controls: Panel.new(layout: FlowLayout.new(hgap: 0, vgap: 2))
	}
}

fn (mut this DesktopPane) draw(ctx &GraphicsContext) {
	this.children.sort(a.z_index > b.z_index)

	// dump('draw')

	// for mut kid in this.children {
	// Draw backwards
	for i in -this.children.len .. 0 {
		mut kid := this.children[(-i) + -1]

		// dump(kid.z_index)
		if kid.x < this.x {
			kid.x = 0
		}
		if kid.y < this.y {
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
		this.init_controls()
	}

	this.do_move(ctx)

	bg := if this.active { ctx.theme.button_bg_click } else { ctx.theme.textbox_border }
	wid := this.width
	hei := this.height
	top := 28
	bord_wid := 5
	wid_2 := wid - (bord_wid * 2)
	ttop := this.y + (ctx.line_height / 2)

	ctx.gg.draw_rounded_rect_filled(this.x, this.y, wid, hei, 9, bg)

	if this.active {
		ctx.gg.draw_rounded_rect_empty(this.x, this.y, wid, hei, 9, gx.blue)
	}

	ctx.gg.draw_text(this.x + 6, ttop, this.text, gx.TextCfg{
		size: ctx.font_size
		color: ctx.theme.text_color
	})

	ctx.gg.draw_rect_filled(this.x + bord_wid, this.y + top, wid_2, hei - top - bord_wid,
		ctx.theme.background)

	this.controls.set_bounds(this.width - 99, -28, 99, 28)

	this.children.sort(a.z_index < b.z_index)

	for mut kid in this.children {
		if kid.parent == unsafe { nil } {
			kid.set_parent(this)
		}
		kid.draw_with_offset(ctx, this.x + bord_wid, this.y + top)
	}

	ctx.draw_text(this.x + 20, this.y + 30, '${this.z_index}', 0)
}

fn (mut this InternalFrame) init_controls() {
	this.init = true

	mut min := Button.new(text: '-')
	mut max := Button.new(text: '□')
	mut xxx := Button.new(text: 'x')

	min.set_bounds(0, 0, 27, 25)
	max.set_bounds(2, 0, 27, 25)
	xxx.set_bounds(9, 0, 27, 25)

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
				ctx.gg.draw_rect_filled(this.x + this.mx, this.y + this.my, 12, 12, gx.blue)
				this.my = -2
			}
		} else {
			if this.my == -2 {
				ctx.gg.draw_rect_filled(mx, my, 12, 12, gx.blue)
				this.width = mx - this.x
				this.height = my - this.y
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
