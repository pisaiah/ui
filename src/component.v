module iui

// Component Interface

[heap; minify]
pub interface Component {
mut:
	text string
	x int
	y int
	rx int
	ry int
	width int
	height int
	is_selected bool
	z_index int
	scroll_i int
	scroll_change_event fn (&Component, int, int)
	is_mouse_down bool
	is_mouse_rele bool
	parent &Component_A
	draw_event_fn fn (mut Window, &Component)
	after_draw_event_fn fn (mut Window, &Component)
	children []Component
	id string
	font int
	events EventManager
	draw(&GraphicsContext)
	invoke_draw_event(&GraphicsContext)
	invoke_after_draw_event(&GraphicsContext)
}

[heap]
pub struct Component_A {
pub mut:
	text                string
	x                   int
	y                   int
	rx                  int
	ry                  int
	width               int
	height              int
	is_selected         bool
	z_index             int
	scroll_i            int
	is_mouse_down       bool
	is_mouse_rele       bool
	draw_event_fn       fn (mut Window, &Component) = blank_draw_event_fn
	after_draw_event_fn fn (mut Window, &Component) = blank_draw_event_fn
	scroll_change_event fn (&Component, int, int)   = fn (_ &Component, delta int, dir int) {}
	parent              &Component_A = unsafe { nil }
	children            []Component
	id                  string
	font                int
	events              EventManager = EventManager{}
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

pub fn (mut this Component_A) add_child(com &Component) {
	this.children << com
}

pub fn (mut com Component_A) set_parent(mut par Component_A) {
	com.parent = par
}

pub fn (mut com Component_A) get_com() Component_A {
	return com
}

fn blank_draw_event_fn(mut win Window, tree &Component) {
	// Stub
}

pub fn (mut com Component_A) draw(ctx &GraphicsContext) {
	// Stub
}

pub fn (mut com Component_A) set_id(mut win Window, id string) {
	com.id = id
	win.id_map[id] = com
}

pub fn (win &Window) draw_with_offset(mut com Component, offx int, offy int) {
	com.rx = com.x + offx
	com.ry = com.y + offy

	com.x = com.x + offx
	com.y = com.y + offy
	com.invoke_draw_event(win.graphics_context)
	com.draw(win.graphics_context)
	com.invoke_after_draw_event(win.graphics_context)
	com.x = com.x - offx
	com.y = com.y - offy
}

pub fn (mut com Component) draw_with_offset(ctx &GraphicsContext, off_x int, off_y int) {
	com.rx = com.x + off_x
	com.ry = com.y + off_y

	com.x = com.x + off_x
	com.y = com.y + off_y
	com.invoke_draw_event(ctx)
	com.draw(ctx)
	com.invoke_after_draw_event(ctx)
	com.x = com.x - off_x
	com.y = com.y - off_y
}

pub fn (mut com Component_A) draw_with_offset(ctx &GraphicsContext, off_x int, off_y int) {
	com.rx = com.x + off_x
	com.ry = com.y + off_y

	com.x = com.x + off_x
	com.y = com.y + off_y
	com.invoke_draw_event(ctx)
	com.draw(ctx)
	com.invoke_after_draw_event(ctx)
	com.x = com.x - off_x
	com.y = com.y - off_y
}

pub fn (com &Component_A) invoke_draw_event(ctx &GraphicsContext) {
	ev := DrawEvent{
		com: com
		ctx: ctx
	}
	for f in com.events.event_map['draw'] {
		f(ev)
	}
}

pub fn (com &Component_A) invoke_after_draw_event(ctx &GraphicsContext) {
	ev := DrawEvent{
		com: com
		ctx: ctx
	}
	for f in com.events.event_map['after_draw'] {
		f(ev)
	}
}
