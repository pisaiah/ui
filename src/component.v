module iui

import gx

// Component Interface

@[heap]
pub interface Component {
	invoke_mouse_down(g &GraphicsContext)
mut:
	text          string
	x             int
	y             int
	rx            int
	ry            int
	width         int
	height        int
	is_selected   bool
	z_index       int
	scroll_i      int
	is_mouse_down bool
	is_mouse_rele bool
	parent        &Component_A
	draw_event_fn fn (mut Window, &Component)
	children      []Component
	id            string
	font          int
	events        &EventManager
	hidden        bool
	draw(&GraphicsContext)
	set_bounds(int, int, int, int)
}

// pub fn (mut com Component) on_mouse_down_component(app &Window) bool {
pub fn (com &Component) str() string {
	return com.type_name() // typeof(com)
}

type AbstractComponent = Component_A

@[heap]
pub struct Component_A implements Component {
pub mut:
	text          string
	x             int
	y             int
	rx            int
	ry            int
	width         int
	height        int
	is_selected   bool
	z_index       int
	scroll_i      int
	is_mouse_down bool
	is_mouse_rele bool
	draw_event_fn fn (mut Window, &Component) = blank_draw_event_fn
	parent        &Component_A                = unsafe { nil }
	children      []Component
	id            string
	font          int
	events        &EventManager = &EventManager{}
	hidden        bool
}

pub struct EventManager {
mut:
	event_map map[string][]fn (voidptr)
}

pub fn (mut com Component_A) subscribe_event(val string, f fn (voidptr)) {
	com.events.event_map[val] << f
}

pub fn (this &Component_A) get_font() int {
	return this.font
}

pub fn (mut this Component_A) set_font(font int) {
	this.font = font
}

pub fn (this &Component) get_font() int {
	return this.font
}

pub fn (mut this Component) set_font(font int) {
	this.font = font
}

pub fn (mut this Component) set_visible(val bool) {
	this.hidden = !val
}

pub fn (mut this Component) set_hidden(val bool) {
	this.hidden = val
}

pub fn (mut this Component_A) set_visible(val bool) {
	this.hidden = !val
}

pub fn (mut this Component_A) set_hidden(val bool) {
	this.hidden = val
}

pub fn (mut this Component_A) add_child(com &Component) {
	this.children << com
}

pub fn (this &Component_A) get_parent[T]() T {
	return T(this.parent)
}

pub fn (mut com Component) set_parent(par voidptr) {
	unsafe {
		com.parent = par
	}
}

pub fn (mut com Component_A) get_com() Component_A {
	return com
}

fn blank_draw_event_fn(mut win Window, c &Component) {
	// Stub
}

pub fn (mut com Component_A) draw(ctx &GraphicsContext) {
	// Stub
}

pub fn (mut com Component_A) set_id(mut win Window, id string) {
	com.id = id
	win.id_map[id] = com
}

pub fn (mut com Component) draw_with_offset(ctx &GraphicsContext, off_x int, off_y int) {
	if com.hidden {
		return
	}

	com.rx = com.x + off_x
	com.ry = com.y + off_y

	com.x = com.x + off_x
	com.y = com.y + off_y

	invoke_draw_event(com, ctx)

	com.draw(ctx)
	invoke_after_draw_event(com, ctx)
	com.debug_draw(ctx)
	com.x = com.x - off_x
	com.y = com.y - off_y
}

pub fn (com &Component) debug_draw(ctx &GraphicsContext) {
	if !ctx.win.debug_draw {
		return
	}
	txt := com.str().replace('iui.', '').trim_space() // '${com.is_mouse_down} ${com.is_mouse_rele}'
	tw := ctx.text_width(txt)
	tx := com.x + (com.width / 2) - (tw / 2)
	ty := com.y + (com.height / 2) - (ctx.line_height / 2)

	x2 := com.x + com.width
	y2 := com.y + com.height

	ctx.gg.draw_line(com.x, com.y, x2, y2, gx.green)
	ctx.gg.draw_line(x2, com.y, com.x, y2, gx.green)

	ctx.gg.draw_rect_empty(com.x, com.y, com.width, com.height, gx.red)

	ctx.gg.draw_rect_filled(tx, ty, tw, ctx.line_height, gx.rgba(250, 0, 0, 150))
	ctx.draw_text(tx, ty, txt, ctx.font)
}

pub fn (mut com Component) set_x(x int) {
	if com.x == com.rx {
		if !isnil(com.parent) {
			com.x = com.parent.x + x
			return
		}
	}
	com.x = x
}

pub fn (mut com Component) set_y(y int) {
	if com.y == com.ry {
		if !isnil(com.parent) {
			com.y = com.parent.ry + y
			return
		}
	}
	com.y = y
}

pub fn (mut com Component_A) set_x(x int) {
	if com.x == com.rx {
		if !isnil(com.parent) {
			com.x = com.parent.x + x
			return
		}
	}
	com.x = x
}

pub fn (mut com Component_A) set_y(y int) {
	if com.y == com.ry {
		if !isnil(com.parent) {
			com.y = com.parent.ry + y
			return
		}
	}
	com.y = y
}

pub fn invoke_draw_event(com &Component, ctx &GraphicsContext) {
	if isnil(com.events) {
		return
	}

	if com.events.event_map['draw'].len == 0 {
		return
	}

	ev := DrawEvent{
		target: unsafe { com }
		ctx:    ctx
	}

	for f in com.events.event_map['draw'] {
		f(&ev)
	}
}

pub fn invoke_after_draw_event(com &Component, ctx &GraphicsContext) {
	if isnil(com.events) {
		return
	}

	if com.events.event_map['after_draw'].len == 0 {
		return
	}

	ev := DrawEvent{
		target: unsafe { com }
		ctx:    ctx
	}
	for f in com.events.event_map['after_draw'] {
		f(&ev)
	}
	if ctx.win.debug_draw {
		ctx.gg.draw_rect_empty(com.x, com.y, com.width, com.height, gx.red)
	}
}

pub fn (com &Button) invoke_mouse_down(ctx &GraphicsContext) {
	ev := MouseEvent{
		target: unsafe { com }
		ctx:    ctx
	}
	for f in com.events.event_map['mouse_down'] {
		f(&ev)
	}
}

pub fn (com &Component_A) invoke_mouse_down(ctx &GraphicsContext) {
	ev := MouseEvent{
		target: unsafe { com }
		ctx:    ctx
	}
	for f in com.events.event_map['mouse_down'] {
		f(&ev)
	}
}

pub fn invoke_mouse_down(com &Component, ctx &GraphicsContext) {
	com.invoke_mouse_down(ctx)

	/*
	dump(typeof(com))

	
	ev := MouseEvent{
		target: unsafe { com }
		ctx:    ctx
	}
	for f in com.events.event_map['mouse_down'] {
		f(ev)
	}
	*/
}

pub fn invoke_mouse_up(com &Component, ctx &GraphicsContext) {
	ev := MouseEvent{
		target: unsafe { com }
		ctx:    ctx
	}
	for f in com.events.event_map['mouse_up'] {
		f(&ev)
	}
}

pub fn invoke_scroll_event(com &Component, ctx &GraphicsContext, delta int) {
	ev := ScrollEvent{
		target: unsafe { com }
		ctx:    ctx
		delta:  delta
		dir:    0
	}

	if 'scroll_wheel' !in com.events.event_map {
		return
	}

	for f in com.events.event_map['scroll_wheel'] {
		f(&ev)
	}
}

pub fn invoke_text_change(com &Component, ctx &GraphicsContext, n string) bool {
	ev := TextChangeEvent{
		target: unsafe { com }
		ctx:    ctx
	}

	for f in com.events.event_map[n] {
		f(&ev)
	}
	return ev.cancel
}

pub interface Container {
	container_pass_ev bool
	children          []Component
}

pub fn invoke_slider_change(com &Slider, ctx &GraphicsContext, value f32) {
	ev := FloatValueChangeEvent{
		target: unsafe { com }
		ctx:    ctx
		value:  value
	}
	for f in com.events.event_map['value_change'] {
		f(&ev)
	}
}
