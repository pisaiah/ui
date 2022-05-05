module iui

import gg
import gx

// Select - implements Component interface
struct Select {
	Component_A
pub mut:
	app             &Window
	text            string
	click_event_fn  fn (mut Window, Select)
	change_event_fn fn (mut Window, Select, string, string)
	items           []string
	shown           bool
	show_items      bool
	center          bool
}

pub fn selector(app &Window, text string) &Select {
	return &Select{
		text: text
		app: app
		click_event_fn: fn (mut win Window, a Select) {}
		change_event_fn: fn (mut win Window, a Select, old string, neww string) {}
		z_index: 1
	}
}

pub fn (mut com Select) set_click(b fn (mut Window, Select)) {
	com.click_event_fn = b
}

pub fn (mut com Select) set_change(b fn (mut Window, Select, string, string)) {
	com.change_event_fn = b
}

// Items -> Children
pub fn (mut this Select) make_items(app &Window) {
	this.children.clear()
	for item in this.items {
		subb := button(app, item)
		this.add_child(subb)
	}
}

pub fn (mut item Select) draw(ctx &GraphicsContext) {
	x := item.x
	y := item.y
	mut app := item.app
	width := item.width
	height := item.height
	size := text_width(app, item.text) / 2
	sizh := text_height(app, item.text) / 2

	mut bg := app.theme.button_bg_normal
	mut border := app.theme.button_border_normal

	mut midx := (x + (width / 2))
	mut midy := (y + (height / 2))

	// Detect Hover
	if (abs(midx - app.mouse_x) < (width / 2)) && (abs(midy - app.mouse_y) < (height / 2)) {
		bg = app.theme.button_bg_hover
		border = app.theme.button_border_hover
	}

	// Detect Click
	mut clicked := ((abs(midx - app.click_x) < (width / 2))
		&& (abs(midy - app.click_y) < (height / 2)))

	if clicked && !item.show_items {
		bg = app.theme.button_bg_click
		border = app.theme.button_border_click
		item.show_items = true

		item.click_event_fn(app, *item)
	}

	if item.show_items && item.items.len > 0 {
		bg = app.theme.button_bg_click
		border = app.theme.button_border_normal
		mut wid := 100

		for mut sub in item.items {
			sub_size := text_width(app, sub + '...')
			if wid < sub_size {
				wid = sub_size
			}
		}
		if wid < item.width {
			wid = item.width
		}

		app.draw_filled_rect(x, y + height, wid, (item.items.len * 26) + 1, 2, border,
			app.theme.dropdown_border)

		if item.items.len != item.children.len {
			item.make_items(app)
		}

		mut mult := 0
		for mut subb in item.children {
			if mut subb is Button {
				app.draw_button_2(x + 1, y + height + mult, wid - 3, 25, mut subb, mut
					item)
			}

			mult += 26
		}
	}

	if item.show_items && app.click_x != -1 && app.click_y != -1 && !clicked {
		item.show_items = false
	}

	// Draw Button Background & Border
	app.gg.draw_rounded_rect_filled(x, y, width, height, 2, bg)
	app.gg.draw_rounded_rect_empty(x, y, width, height, 2, border)

	// Draw Button Text
	ctx.draw_text((x + (width / 2)) - size - 4, y + (height / 2) - sizh, item.text, ctx.font,
		gx.TextCfg{
		size: app.font_size
		color: app.theme.text_color
	})

	// Draw down arrow
	char_height := app.gg.text_height('.') / 2
	app.gg.draw_triangle_filled(x + width - 20, y + (height / 2) - char_height, x + width - 15,
		y + (height / 2) + 5 - char_height, x + width - 10, y + (height / 2) - char_height,
		app.theme.text_color)
}

fn (mut app Window) draw_button_2(x int, y int, width int, height int, mut btn Button, mut sel Select) {
	app.bar.tik = 1

	text := btn.text
	size := text_width(app, text) / 2
	sizh := text_height(app, text) / 2

	mid := x + (width / 2)
	midy := y + (height / 2)
	hover := abs(mid - app.mouse_x) < width / 2 && abs(midy - app.mouse_y) < height / 2
	click := abs(mid - app.click_x) < width / 2 && abs(midy - app.click_y) < height / 2
	bg := if hover { app.theme.button_bg_hover } else { app.theme.button_bg_normal }

	// Detect Click
	if click {
		btn.click_event_fn(app, *btn)
		btn.is_selected = true

		old_text := sel.text
		sel.text = btn.text
		sel.change_event_fn(sel.app, *sel, old_text, sel.text)

		click_bg := app.theme.button_bg_click
		app.gg.draw_rect_filled(x, y, width, height, click_bg)
	} else {
		btn.is_selected = false
		app.gg.draw_rect_filled(x, y, width, height, bg)
	}

	// Draw Button Text
	if sel.center {
		app.gg.draw_text((x + (width / 2)) - size, y + (height / 2) - sizh, text, gx.TextCfg{
			size: app.font_size
			color: app.theme.text_color
		})
	} else {
		app.gg.draw_text(x + 8, y + (height / 2) - sizh, text, gx.TextCfg{
			size: app.font_size
			color: app.theme.text_color
		})
	}
}
