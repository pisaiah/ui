module iui

// deprecated stuff for removal
@[deprecated: 'Use Slider.new']
pub fn slider(cfg SliderConfig) &Slider {
	return Slider.new(cfg)
}

@[deprecated: 'Use Checkbox.new']
pub fn check_box(c CheckboxConfig) &Checkbox {
	return Checkbox.new(c)
}

@[deprecated: 'Use Textbox.new']
pub fn text_box(lines []string) &Textbox {
	return Textbox.new(lines: lines)
}

@[deprecated: 'Use Modal.new']
pub fn modal(app &Window, title string) &Modal {
	return Modal.new(title: title)
}

@[deprecated: 'Use Selectbox.new']
pub fn select_box(cfg SelectboxConfig) &Selectbox {
	return Selectbox.new(cfg)
}

@[deprecated: 'Use Titlebox.new']
pub fn title_box(text string, children []Component) &Titlebox {
	return &Titlebox{
		text:     text
		children: children
	}
}

@[deprecated: 'Use Menubar.new']
pub fn menu_bar(cfg MenubarConfig) &Menubar {
	return &Menubar{}
}

@[deprecated: 'Use Button.new']
pub fn button(cfg ButtonConfig) &Button {
	return Button.new(cfg)
}

/*
@[deprecated: 'Use get[T](id)']
pub fn (win &Window) get_from_id(id string) voidptr {
	return unsafe { win.id_map[id] }
}

@[deprecated: 'Use ctx.draw_bordered_rect']
pub fn (app &Window) draw_bordered_rect(x int, y int, w int, h int, a int, bg gx.Color, bord gx.Color) {
	app.gg.draw_rounded_rect_filled(x, y, w, h, a, bg)
	app.gg.draw_rounded_rect_empty(x, y, w, h, a, bord)
}

@[deprecated]
pub fn text_height(win Window, text string) int {
	return win.gg.text_height(text)
}
*/