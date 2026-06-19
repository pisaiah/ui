module iui

// See https://docs.oracle.com/javase/7/docs/api/javax/swing/ButtonGroup.html
@[heap]
pub struct ButtonGroup[T] {
mut:
	buttons  []&T
	selected &T
	events   &EventManager = &EventManager{}
}

pub fn (mut com ButtonGroup[T]) subscribe_event(val string, f fn (voidptr)) {
	com.events.event_map[val] << f
}

@[params]
pub struct ButtonGroupConfig {
pub:
	buttons []voidptr
}

pub fn ButtonGroup.new[T](cfg ButtonGroupConfig) &ButtonGroup[T] {
	return &ButtonGroup[T]{
		buttons:  cfg.buttons
		selected: unsafe { nil }
	}
}

pub fn buttongroup[T](cfg ButtonGroupConfig) &ButtonGroup[T] {
	return &ButtonGroup[T]{
		buttons:  cfg.buttons
		selected: unsafe { nil }
	}
}

pub fn (mut this ButtonGroup[T]) add(a &T) {
	this.buttons << a
}

pub fn (mut this ButtonGroup[T]) setup() {
	for mut btn in this.buttons {
		btn.subscribe_event('mouse_up', fn [mut this] [T](mut e MouseEvent) {
			for mut btn in this.buttons {
				btn.is_selected = false
			}

			mut tar := e.target
			if mut tar is Button {
				tar.is_selected = true
			}

			if mut tar is T {
				this.selected = tar
			}

			this.invoke_mouse_up(e.target, e.ctx)
		})
	}
}

pub fn (mut this ButtonGroup[T]) get_selected() &T {
	return this.selected
}

pub fn (mut this ButtonGroup[T]) invoke_mouse_up(com &Component, ctx &GraphicsContext) {
	ev := &MouseEvent{
		target: unsafe { com }
		ctx:    ctx
	}
	for f in this.events.event_map['mouse_up'] {
		f(ev)
	}
}
