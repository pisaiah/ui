module iui

import gg
import gx

// Select - implements Component interface
pub struct Selectbox {
	Component_A
pub mut:
	app  &Window
	text string
	// click_event_fn  fn (mut Window, Select)
	// change_event_fn fn (mut Window, Select, string, string)
	items      []string
	show_items bool
	center     bool
	sub_height int = 28
}

[params]
pub struct SelectboxConfig {
	bounds Bounds
	items  []string
	text   string
}

pub fn select_box(cfg SelectboxConfig) &Selectbox {
	return &Selectbox{
		text: cfg.text
		app: unsafe { nil }
		z_index: 1
		x: cfg.bounds.x
		y: cfg.bounds.y
		width: cfg.bounds.width
		height: cfg.bounds.height
		items: cfg.items
	}
}

// Items -> Children
pub fn (mut this Selectbox) make_items(ctx &GraphicsContext) {
	this.children.clear()
	for item in this.items {
		mut subb := button(text: item)
		subb.border_radius = 10
		subb.subscribe_event('mouse_down', fn (mut e MouseEvent) {
			dump('hello?')
		})
		this.add_child(subb)
	}
}

pub fn (mut item Selectbox) draw_children(ctx &GraphicsContext) {
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

	if item.items.len != item.children.len {
		item.make_items(ctx)
	}

	list_height := (item.items.len * (item.sub_height + 1)) + 1
	ctx.win.draw_filled_rect(item.x, item.y + item.height, wid, list_height, 2, ctx.theme.button_bg_normal,
		ctx.theme.button_border_normal)

	mut y := item.y + item.height
	for mut subb in item.children {
		subb.height = item.sub_height
		subb.draw_with_offset(ctx, item.x, y)

		y += item.sub_height + 1
		subb.height = item.sub_height
		subb.width = item.width
		subb.z_index = 10
	}
}

pub fn (mut item Selectbox) draw(ctx &GraphicsContext) {
	if item.app == unsafe { nil } {
		item.app = ctx.win
	}

	x := item.x
	y := item.y
	mut app := item.app
	width := item.width
	height := item.height
	size := ctx.text_width(item.text) / 2
	sizh := ctx.gg.text_height(item.text) / 2 // ctx.line_height / 2

	mut bg := ctx.theme.button_bg_normal
	mut border := ctx.theme.button_border_normal

	midx := (x + (width / 2))
	midy := (y + (height / 2))

	// Detect Hover
	if (abs(midx - app.mouse_x) < (width / 2)) && (abs(midy - app.mouse_y) < (height / 2)) {
		bg = ctx.theme.button_bg_hover
		border = ctx.theme.button_border_hover
	}

	// Detect Click
	clicked := ((abs(midx - app.click_x) < (width / 2)) && (abs(midy - app.click_y) < (height / 2)))

	if clicked && !item.show_items {
		bg = ctx.theme.button_bg_click
		border = ctx.theme.button_border_click
		item.show_items = true
		// item.click_event_fn(mut app, *item)
	}

	mut yy := item.y + item.height
	for mut subb in item.children {
		subb.height = 0
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
	ctx.gg.draw_rect_filled(x, y, width, height, bg)
	ctx.gg.draw_rect_empty(x, y, width, height, border)

	// Draw Button Text
	// ctx.draw_text((x + (width / 2)) - size - 4, y + (height / 2) - sizh, item.text, ctx.font,
	ctx.draw_text(x + 5, y + (height / 2) - sizh, item.text, ctx.font, gx.TextCfg{
		size: ctx.font_size
		color: ctx.theme.text_color
	})

	ctx.gg.draw_rect_empty(x + width - 25, y, 25, height, border)

	// Draw down arrow
	char_height := 3
	tx := 17

	ctx.gg.draw_triangle_filled(x + width - tx, y + (height / 2) - char_height, x + width - (tx - 5),
		y + (height / 2) + 5 - char_height, x + width - (tx - 10), y + (height / 2) - char_height,
		ctx.theme.text_color)
}
