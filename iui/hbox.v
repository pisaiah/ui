module iui

// HBox - implements Component interface
struct HBox {
	Component_A
pub mut:
	win            &Window
	click_event_fn fn (voidptr, voidptr)
}

pub fn hbox(win &Window) &HBox {
	return &HBox{
		win: win
		click_event_fn: fn (a voidptr, b voidptr) {}
	}
}

pub fn (mut this HBox) draw() {
	// TODO
}
