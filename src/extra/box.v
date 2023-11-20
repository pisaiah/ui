module extra

// Box
pub struct Box {
pub mut:
	vbox &VBox
}

@[deprecated]
pub fn box(win &Window) &Box {
	return &Box{
		vbox: VBox.new()
	}
}

pub fn (mut this Box) add_child(com &Component) {
	if this.vbox.children.len == 0 {
		this.add_break(1)
	}

	mut cbox := this.vbox.children.last()
	if mut cbox is HBox {
		cbox.add_child(com)
	}
}

pub fn (mut this Box) center_current_hbox() {
	mut cbox := this.vbox.children.last()

	if mut cbox is HBox {
		cbox.center_screen = true
	}
}

pub fn (mut this Box) set_current_height(val int) {
	mut cbox := this.vbox.children.last()

	if mut cbox is HBox {
		cbox.height = val
	}
}

pub fn (mut this Box) add_break(min_height int) {
	if this.vbox.children.len > 0 {
		mut cbox := this.vbox.children.last()
		if mut cbox is HBox {
			if cbox.children.len <= 0 {
				return
			}
		}
	}

	mut hbox := HBox.new()
	hbox.set_min_height(min_height)
	hbox.pack()
	this.vbox.add_child(hbox)
}

pub fn (mut this Box) get_vbox() &VBox {
	return this.vbox
}
