module iui

import gg
import gx

// Select - implements Component interface
pub struct Select {
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
	sub_height      int = 28
}

[params]
pub struct SelectConfig {
	bounds Bounds
	items  []string
}

[deprecated: 'use select_box']
pub fn selector(app &Window, text string, cfg SelectConfig) &Select {
	return &Select{
		text: text
		app: app
		click_event_fn: fn (mut win Window, a Select) {}
		change_event_fn: fn (mut win Window, a Select, old string, neww string) {}
		z_index: 1
		x: cfg.bounds.x
		y: cfg.bounds.y
		width: cfg.bounds.width
		height: cfg.bounds.height
		items: cfg.items
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
		subb := button(text: item)
		this.add_child(subb)
	}
}

pub fn (mut item Select) draw_children(ctx &GraphicsContext) {
	mut wid := 100

	for mut sub in item.items {
		sub_size := text_width(ctx.win, sub + '...')
		if wid < sub_size {
			wid = sub_size
		}
	}
	if wid < item.width {
		wid = item.width
	}

	list_height := (item.items.len * item.sub_height) + 1
	ctx.win.draw_filled_rect(item.x, item.y + item.height, wid, list_height, 2, ctx.theme.button_bg_normal,
		ctx.theme.button_border_normal)

	if item.items.len != item.children.len {
		item.make_items(ctx.win)
	}

	mut win := ctx.win
	mut mult := 0
	for mut subb in item.children {
		if mut subb is Button {
			y_pos := item.y + item.height + mult
			win.draw_button_2(item.x + 1, y_pos, wid - 3, item.sub_height - 1, mut subb, mut
				item, ctx)
		}

		mult += item.sub_height
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

	mut bg := ctx.theme.button_bg_normal
	mut border := ctx.theme.button_border_normal

	midx := (x + (width / 2))
	midy := (y + (height / 2))

	// Detect Hover
	if abs(midx - app.mouse_x) < (width / 2) && abs(midy - app.mouse_y) < (height / 2) {
		bg = ctx.theme.button_bg_hover
		border = ctx.theme.button_border_hover
	}

	// Detect Click
	clicked := (abs(midx - app.click_x) < (width / 2) && abs(midy - app.click_y) < (height / 2))

	if clicked && !item.show_items {
		bg = ctx.theme.button_bg_click
		border = ctx.theme.button_border_click
		item.show_items = true

		item.click_event_fn(mut app, *item)
	}

	if item.show_items && item.items.len > 0 {
		bg = ctx.theme.button_bg_click
		border = ctx.theme.button_border_normal
		item.draw_children(ctx)
	}

	if item.show_items && app.click_x != -1 && app.click_y != -1 && !clicked {
		item.show_items = false
	}

	// Draw Button Background & Border
	app.gg.draw_rect_filled(x, y, width, height, bg)
	app.gg.draw_rect_empty(x, y, width, height, border)

	// Draw Button Text
	ctx.draw_text((x + (width / 2)) - size - 4, y + (height / 2) - sizh, item.text, ctx.font,
		gx.TextCfg{
		size: app.font_size
		color: app.theme.text_color
	})

	// Draw down arrow
	char_height := app.gg.text_height('-') / 2
	app.gg.draw_triangle_filled(x + width - 20, y + (height / 2) - char_height, x + width - 15,
		y + (height / 2) + 5 - char_height, x + width - 10, y + (height / 2) - char_height,
		app.theme.text_color)
}

fn (mut app Window) draw_button_2(x int, y int, width int, height int, mut btn Button, mut sel Select, ctx &GraphicsContext) {
	if app.bar != unsafe { nil } {
		app.bar.tik = 1
	}

	text := btn.text
	size := text_width(app, text) / 2
	sizh := text_height(app, text) / 2

	mid := x + (width / 2)
	midy := y + (height / 2)
	hover := abs(mid - app.mouse_x) < width / 2 && abs(midy - app.mouse_y) < height / 2
	click := abs(mid - app.click_x) < width / 2 && abs(midy - app.click_y) < height / 2

	// Detect Click
	if click {
		btn.click_event_fn(mut app, *btn)
		btn.is_selected = true

		old_text := sel.text
		sel.text = btn.text
		sel.change_event_fn(mut sel.app, *sel, old_text, sel.text)

		click_bg := app.theme.button_bg_click
		app.gg.draw_rect_filled(x, y, width, height, click_bg)
	} else {
		btn.is_selected = false
		if hover {
			bg := app.theme.button_bg_hover
			app.gg.draw_rect_filled(x, y, width, height, bg)
		}
	}

	// Draw Button Text
	ctx.draw_text(x + 8, y + (height / 2) - sizh, text, ctx.font, gx.TextCfg{
		size: app.font_size
		color: app.theme.text_color
	})
}
