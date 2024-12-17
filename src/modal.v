module iui

import gg
import gx

// Modal - implements Component interface
pub struct Modal {
	Component_A
pub mut:
	text       string
	needs_init bool
	close      &Button
	shown      bool

	in_width          int
	in_height         int
	left_off          int
	top_off           int = 50
	xs                int
	pack              bool
	container_pass_ev bool = true
}

@[params]
pub struct ModalConfig {
pub:
	title  string
	width  int = 500
	height int = 300
	left   int
	top    int = 50
}

pub fn Modal.new(c ModalConfig) &Modal {
	return &Modal{
		text:       c.title
		z_index:    500
		needs_init: true
		in_width:   c.width
		in_height:  c.height
		close:      unsafe { nil }
		left_off:   c.left
		top_off:    c.top
	}
}

pub fn (mut this Modal) pack() {
	this.pack = true
}

pub fn (mut this Modal) calc_resize(ctx &GraphicsContext, ws gg.Size) {
	this.width = ws.width
	this.height = ws.height

	this.xs = (ws.width / 2) - (this.in_width / 2) - this.left_off
}

pub fn (mut m Modal) draw(ctx &GraphicsContext) {
	ws := gg.window_size()

	if m.width != ws.width || m.height != ws.height {
		m.calc_resize(ctx, ws)
	}

	if m.z_index <= 501 {
		// Only draw background for one modal.
		ctx.gg.draw_rect_filled(0, 0, ws.width, ws.height, gx.rgba(0, 0, 0, 170))
	}

	wid := m.in_width
	hei := m.in_height
	bord_wid := 5
	wid_2 := wid - (bord_wid * 2)
	bg := ctx.theme.textbox_border

	top := 28
	ctx.gg.draw_rounded_rect_filled(m.xs, m.top_off, wid, hei + bord_wid + top, 9, bg)

	ttop := m.top_off + (ctx.line_height / 2) - 1

	ctx.gg.draw_text(m.xs + 6, ttop, m.text, gx.TextCfg{
		size:  ctx.font_size
		color: ctx.theme.text_color
	})

	ctx.gg.draw_rect_filled(m.xs + bord_wid, m.top_off + top, wid_2, hei, ctx.theme.background)
	ctx.gg.draw_rect_empty(m.xs + bord_wid, m.top_off + top, wid_2, hei, ctx.theme.button_bg_click)

	mut app := ctx.win

	// Do component draw event again to fix z-index
	if !isnil(m.draw_event_fn) {
		// m.draw_event_fn(mut app, &Component(m))
	}

	if m.needs_init {
		m.make_close_btn(true)
		m.needs_init = false
	}

	y_off := m.y + m.top_off + top
	for mut kid in m.children {
		kid.draw_event_fn(mut app, kid)
		kid.draw_with_offset(ctx, m.xs, y_off + 2)

		if m.pack {
			if kid.width > m.in_width {
				m.in_width = kid.width + (kid.x * 2)
				m.close.x = m.in_width - 115
				m.calc_resize(ctx, ws)
			}
		}
	}
}

pub fn (mut this Modal) make_close_btn(ce bool) &Button {
	mut close := Button.new(
		text:   'OK'
		bounds: Bounds{200, this.in_height - 40, 100, 30}
	)

	if 300 > this.in_width {
		close.x = this.in_width - 115
	}

	if ce {
		close.subscribe_event('mouse_up', default_modal_close_fn)
	}
	if ce && this.needs_init {
		close.is_action = true
	}

	this.children << close
	this.close = close
	return close
}

pub fn default_modal_close_fn(mut e MouseEvent) {
	e.ctx.win.components = e.ctx.win.components.filter(mut it !is Modal)
}
