module extra

import iui as ui

// Box
pub struct Box {
pub mut:
	vbox &ui.VBox
}

@[deprecated]
pub fn box(win &ui.Window) &Box {
	return &Box{
		vbox: ui.VBox.new()
	}
}

pub fn (mut this Box) add_child(com &ui.Component) {
	if this.vbox.children.len == 0 {
		this.add_break(1)
	}

	mut cbox := this.vbox.children.last()
	if mut cbox is ui.HBox {
		cbox.add_child(com)
	}
}

pub fn (mut this Box) center_current_hbox() {
	mut cbox := this.vbox.children.last()

	if mut cbox is ui.HBox {
		cbox.center_screen = true
	}
}

pub fn (mut this Box) set_current_height(val int) {
	mut cbox := this.vbox.children.last()

	if mut cbox is ui.HBox {
		cbox.height = val
	}
}

pub fn (mut this Box) add_break(min_height int) {
	if this.vbox.children.len > 0 {
		mut cbox := this.vbox.children.last()
		if mut cbox is ui.HBox {
			if cbox.children.len <= 0 {
				return
			}
		}
	}

	mut hbox := ui.HBox.new()
	hbox.set_min_height(min_height)
	hbox.pack()
	this.vbox.add_child(hbox)
}

pub fn (mut this Box) get_vbox() &ui.VBox {
	return this.vbox
}
