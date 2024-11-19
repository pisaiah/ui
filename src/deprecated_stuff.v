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

@[deprecated: 'Use Menubar.new']
pub fn menu_bar(cfg MenubarConfig) &Menubar {
	return &Menubar{}
}

@[deprecated: 'Use Button.new']
pub fn button(cfg ButtonConfig) &Button {
	return Button.new(cfg)
}
