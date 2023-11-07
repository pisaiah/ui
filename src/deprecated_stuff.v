module iui

// deprecated stuff for removal
[deprecated: 'Use Tabbox.new']
pub fn tabbox(win &Window) &Tabbox {
	return Tabbox.new()
}

[deprecated: 'Use Button.new(ButtonConfig)']
pub fn button_with_icon(icon int, conf ButtonConfig) &Button {
	cfg := ButtonConfig{
		...conf
		icon: icon
	}
	return button(cfg)
}

[deprecated: 'Replaced with menu_item(MenuItemConfig)']
pub fn menuitem(text string) &MenuItem {
	return &MenuItem{
		text: text
		icon: 0
		click_event_fn: fn (mut win Window, item MenuItem) {}
	}
}

[deprecated]
pub fn menubar(app &Window, theme Theme) &Menubar {
	return &Menubar{}
}

[deprecated: 'Use Page.new']
pub fn page(app &Window, title string) &Page {
	return Page.new(title: title)
}

[deprecated: 'Use Progressbar.new']
pub fn progressbar(val f32) &Progressbar {
	return &Progressbar{
		text: val.str()
		bind_val: unsafe { nil }
	}
}

[deprecated: 'Use Slider.new']
pub fn new_slider(cfg SliderConfig) &Slider {
	return Slider.new(cfg)
}

[deprecated: 'Use Window.new']
pub fn make_window(c &WindowConfig) &Window {
	return Window.new(c)
}

[deprecated: 'use ctx.text_width']
pub fn text_width(win Window, text string) int {
	return win.graphics_context.text_width(text)
}

[deprecated]
pub fn image_from_file(path string) &Image {
	return Image.new(file: path)
}

// [deprecated]
// pub fn image(w &Window, img &gg.Image) &Image {
//	return Image.new(img: img)
// }

// [deprecated]
// pub fn image_with_size(w &Window, img &gg.Image, width int, height int) &Image {
//	mut i := Image.new(img: img)
//	i.set_bounds(0, 0, width, height)
//	return i
// }

// [deprecated: 'Use HBox.new()']
// pub fn hbox(win &Window) &HBox {
// 	return &HBox{
// 	}
// }

// [deprecated: 'Use VBox.new()']
// pub fn vbox(win &Window) &VBox {
// 	return &VBox{
// 	}
// }
