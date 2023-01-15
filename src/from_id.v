module iui

pub fn (win &Window) get_tree(id string) &Tree2 {
	return unsafe { &Tree2(win.id_map[id]) }
}

pub fn (win &Window) get_treenode(id string) &TreeNode {
	return unsafe { &TreeNode(win.id_map[id]) }
}

pub fn (win &Window) get_button(id string) &Button {
	return unsafe { &Button(win.id_map[id]) }
}

pub fn (win &Window) get_checkbox(id string) &Checkbox {
	return unsafe { &Checkbox(win.id_map[id]) }
}

pub fn (win &Window) get_hbox(id string) &HBox {
	return unsafe { &HBox(win.id_map[id]) }
}

pub fn (win &Window) get_hyperlink(id string) &Hyperlink {
	return unsafe { &Hyperlink(win.id_map[id]) }
}

pub fn (win &Window) get_image(id string) &Image {
	return unsafe { &Image(win.id_map[id]) }
}

pub fn (win &Window) get_label(id string) &Label {
	return unsafe { &Label(win.id_map[id]) }
}

pub fn (win &Window) get_menubar(id string) &Menubar {
	return unsafe { &Menubar(win.id_map[id]) }
}

pub fn (win &Window) get_menuitem(id string) &MenuItem {
	return unsafe { &MenuItem(win.id_map[id]) }
}

pub fn (win &Window) get_modal(id string) &Modal {
	return unsafe { &Modal(win.id_map[id]) }
}

pub fn (win &Window) get_page(id string) &Page {
	return unsafe { &Page(win.id_map[id]) }
}

pub fn (win &Window) get_progressbar(id string) &Progressbar {
	return unsafe { &Progressbar(win.id_map[id]) }
}

pub fn (win &Window) get_scrollview(id string) &ScrollView {
	return unsafe { &ScrollView(win.id_map[id]) }
}

pub fn (win &Window) get_selectbox(id string) &Select {
	return unsafe { &Select(win.id_map[id]) }
}

pub fn (win &Window) get_slider(id string) &Slider {
	return unsafe { &Slider(win.id_map[id]) }
}

pub fn (win &Window) get_tabbox(id string) &Tabbox {
	return unsafe { &Tabbox(win.id_map[id]) }
}

pub fn (win &Window) get_textarea(id string) &TextArea {
	return unsafe { &TextArea(win.id_map[id]) }
}

pub fn (win &Window) get_textfield(id string) &TextField {
	return unsafe { &TextField(win.id_map[id]) }
}

pub fn (win &Window) get_vbox(id string) &VBox {
	return unsafe { &VBox(win.id_map[id]) }
}
