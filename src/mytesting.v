module iui

import gg

pub fn (com &Button) invoke_mouse_down(ctx &GraphicsContext) {
	dump(typeof(com))

	ev := MouseEvent2[Button]{
		target: com
		ctx:    ctx
	}
	for f in com.events.event_map['mouse_down'] {
		f(ev)
	}
}

pub fn (com &Component_A) invoke_mouse_down(ctx &GraphicsContext) {
	dump(typeof(com))

	ev := MouseEvent{
		target: unsafe { com }
		ctx:    ctx
	}
	for f in com.events.event_map['mouse_down'] {
		f(ev)
	}
}
