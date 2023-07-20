module extra

// Box -
//     Box is a combination of VBox & HBox
//     This is similar to HTML's <br> rule
//
pub struct Box {
	Component_A
pub mut:
	win  &Window
	vbox &VBox
}

pub fn box(win &Window) &Box {
	return &Box{
		win: win
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

	mut h_box := HBox.new()
	h_box.set_bounds(this.x, this.y, this.width, this.height)
	h_box.set_min_height(min_height)
	h_box.pack()
	this.vbox.add_child(h_box)
}

pub fn (mut this Box) get_vbox() &VBox {
	return this.vbox
}

// Ignored; Box is a utility, and does not draw.
pub fn (mut this Box) draw(ctx &GraphicsContext) {
}
