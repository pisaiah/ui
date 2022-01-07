module iui

import gg
import gx

// Label - implements Component interface
struct Label {
	Component_A
pub mut:
	app            &Window
	text           string
	click_event_fn fn (mut Window, Label)
	in_modal       bool
	need_pack      bool
}

pub fn label(app &Window, text string) Label {
	return Label{
		text: text
		app: app
		click_event_fn: blank_event_l
	}
}

pub fn (mut btn Label) draw() {
	btn.app.draw_label(btn.x, btn.y, btn.width, btn.height, mut btn)
}

pub fn (mut btn Label) pack() {
	btn.need_pack = true
}

pub fn (mut btn Label) pack_do() {
	width := text_width(btn.app, btn.text + 'ab')
	btn.width = width
	btn.height = text_height(btn.app, btn.text) + 4
	btn.need_pack = false
}

fn (mut app Window) draw_label(x int, y int, width int, height int, mut btn Label) {
	if btn.need_pack {
		btn.pack_do()
	}

	text := btn.text
	size := text_width(app, text) / 2
	sizh := text_height(app, text) / 2

	//mut bg := app.theme.button_bg_normal
	//mut border := app.theme.button_border_normal

	//mut mid := (x + (width / 2))
	//mut midy := (y + (height / 2))

	// Detect Hover
	//if (math.abs(mid - app.mouse_x) < (width / 2)) && (math.abs(midy - app.mouse_y) < (height / 2)) {
		//bg = app.theme.button_bg_hover
		//border = app.theme.button_border_hover
	//}

	if btn.is_mouse_rele {
		btn.is_mouse_rele = false
		btn.click_event_fn(app, *btn)
		//btn.is_selected = true
	}

	// Detect Click
	if btn.is_mouse_down {
		//bg = app.theme.button_bg_click
		//border = app.theme.button_border_click
	}

	// Draw Button Text
	app.gg.draw_text((x + (width / 2)) - size, y + (height / 2) - sizh, text, gx.TextCfg{
		size: 14
		color: app.theme.text_color
	})
}

pub fn (mut com Label) set_click(b fn (mut Window, Label)) {
	com.click_event_fn = b
}

pub fn blank_event_l(mut win Window, a Label) {
}
