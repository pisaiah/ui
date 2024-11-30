module iui

import gx

// Select - implements Component interface
pub struct Selectbox {
	Component_A
pub mut:
	text       string
	items      []string
	kids       []voidptr
	center     bool
	sub_height int = 28
	popup      &Popup
}

fn (box &Selectbox) is_open() bool {
	return box.popup.shown
}

@[params]
pub struct SelectboxConfig {
pub:
	bounds Bounds
	items  []string
	text   string
}

pub fn Selectbox.new(cfg SelectboxConfig) &Selectbox {
	return &Selectbox{
		text:   cfg.text
		x:      cfg.bounds.x
		y:      cfg.bounds.y
		width:  cfg.bounds.width
		height: cfg.bounds.height
		items:  cfg.items
		popup:  &Popup{}
	}
}

// Items -> Children
pub fn (mut this Selectbox) setup_popup(ctx &GraphicsContext, n bool) {
	// Set a dropdown animation
	this.popup.set_animate(true)

	if !n {
		this.popup.children.clear()
	}

	for item in this.items {
		mut subb := this.new_item(text: item)
		this.popup.add_child(subb)
	}

	for mut kid in this.children {
		if mut kid is SelectItem {
			kid.set_bounds(0, 1, this.width - 1, this.sub_height)

			kid.x = 0
			kid.y = 1
			kid.width = this.width - 1
			kid.height = this.sub_height

			this.popup.add_child(kid)
		}
	}

	items_len := this.items.len + this.children.len
	ph := (items_len * this.sub_height) + items_len
	this.popup.set_bounds(this.x, this.y + this.height, this.width, ph)

	// this.popup = pop
}

pub fn (mut this Selectbox) new_item(c MenuItemConfig) &SelectItem {
	mut subb := SelectItem.new(c)
	subb.box = this
	subb.subscribe_event('mouse_up', this.default_item_mouse_event)
	subb.set_bounds(0, 1, this.width - 1, this.sub_height)
	return subb
}

pub fn (mut this Selectbox) default_item_mouse_event(mut e MouseEvent) {
	// mut popup := &Popup(e.target.parent)
	old_val := this.text
	this.text = e.target.text
	this.invoke_change_event(e.ctx, old_val, e.target.text)
	this.popup.hide(e.ctx)
}

pub fn (mut this Selectbox) invoke_change_event(ctx &GraphicsContext, ov string, nv string) {
	ev := ItemChangeEvent{
		target:  this
		ctx:     ctx
		old_val: ov
		new_val: nv
	}
	for f in this.events.event_map['item_change'] {
		f(ev)
	}
}

pub fn (mut box Selectbox) draw_children(ctx &GraphicsContext) {
	if isnil(box.popup) {
		box.setup_popup(ctx, true)
	} else {
		len := box.items.len + box.children.len
		if len != box.popup.children.len {
			box.setup_popup(ctx, false)
		}
	}
}

pub fn (mut sb Selectbox) do_pack(ctx &GraphicsContext) {
	if sb.height == 0 {
		sb.height = min_h(ctx)
	}
	if sb.width == 0 {
		sb.width = ctx.text_width(sb.text) + 40
	}
}

pub fn (box &Selectbox) get_bg_bord(g &GraphicsContext) (gx.Color, gx.Color) {
	if box.is_mouse_down {
		return g.theme.button_bg_click, g.theme.button_border_normal
	}

	if is_in(box, g.win.mouse_x, g.win.mouse_y) {
		return g.theme.button_bg_hover, g.theme.button_border_hover
	}
	return g.theme.button_bg_normal, g.theme.button_border_normal
}

pub fn (mut box Selectbox) draw(ctx &GraphicsContext) {
	box.do_pack(ctx)
	box.draw_children(ctx)

	if box.is_mouse_down {
		if !box.popup.shown {
			box.popup.show(box, 0, box.height, ctx)
		} else {
			box.popup.hide(ctx)
		}
		box.is_mouse_down = false
	}

	cx := ctx.win.click_x
	cy := ctx.win.click_y

	if cx != -1 && cy != -1 {
		if !is_in(box.popup, cx, cy) && !is_in(box, cx, cy) && !box.is_mouse_down {
			box.popup.hide(ctx)
		}
	}

	if box.popup.x != box.x && box.popup.is_shown(ctx) {
		box.popup.hide(ctx)
		box.popup.show(box, 0, box.height, ctx)
	}

	mut win := ctx.win
	for mut pop in win.popups {
		if pop.x == box.x && pop.y == box.popup.y {
			pop.note_keep_alive()
		}
	}

	box.draw_box(ctx, box.x, box.y)
}

// Draw Box UI; bg, text, arrow
pub fn (box &Selectbox) draw_box(ctx &GraphicsContext, x int, y int) {
	bg, border := box.get_bg_bord(ctx)
	sizh := ctx.gg.text_height(box.text) / 2

	ctx.gg.draw_rect_filled(x, y, box.width, box.height, bg)

	ctx.draw_text(x + 5, y + (box.height / 2) - sizh, box.text, ctx.font, gx.TextCfg{
		size:  ctx.font_size
		color: ctx.theme.text_color
	})

	ctx.theme.button_fill_fn(x + box.width - 26, y, 25, box.height - 1, 1, bg, ctx)
	ctx.gg.draw_rect_empty(x, y, box.width, box.height, border)

	box.draw_arrow(ctx, x, y, box.width, box.height)
}

// Draw down arrow
fn (box &Selectbox) draw_arrow(ctx &GraphicsContext, x int, y int, w int, h int) {
	a := x + w - 17
	b := y + (h / 2) - 3
	ctx.gg.draw_triangle_filled(a, b, a + 5, b + 5, a + 10, b, ctx.theme.text_color)
}

// SelectItem
pub struct SelectItem {
	Component_A
pub mut:
	icon  &Image
	uicon ?string
	box   ?&Selectbox
}

pub fn SelectItem.new(c MenuItemConfig) &SelectItem {
	item := &SelectItem{
		text:  c.text
		icon:  c.icon
		uicon: c.uicon
	}
	return item
}

fn (mut si SelectItem) draw(ctx &GraphicsContext) {
	if is_in(si, ctx.win.mouse_x, ctx.win.mouse_y) {
		ctx.gg.draw_rect_filled(si.x + 1, si.y + 1, si.width - 2, si.height - 2, ctx.theme.button_bg_hover)
	}

	if si.is_mouse_down || si.is_mouse_rele {
		bg := ctx.theme.button_bg_click
		ctx.gg.draw_rect_filled(si.x, si.y, si.width, si.height, bg)
	}

	if si.is_mouse_rele {
		si.is_mouse_rele = false
	}

	if si.box != none {
		// dump('${si.text} ${si.box?.text}')
		if si.box?.text == si.text {
			ctx.gg.draw_rect_filled(si.x + 1, si.y + 1, si.width - 2, si.height - 2, ctx.theme.button_bg_hover)
			ctx.gg.draw_rect_filled(si.x + 3, si.y + (si.height / 4), 3, (si.height / 2),
				ctx.theme.accent_fill)
		}
	}

	// Draw Button Text
	if !isnil(si.icon) {
		image_y := si.y + ((si.height / 2) - (si.icon.height / 2))
		si.icon.set_pos(si.x + (si.width / 2) - (si.icon.width / 2), image_y)
		si.icon.draw(ctx)
	} else {
		y := si.y + ((si.height / 2) - (ctx.line_height / 2))
		si.draw_text(ctx, y)
	}
}

fn (mut si SelectItem) draw_text(ctx &GraphicsContext, y int) {
	if si.uicon != none && ctx.icon_ttf_exists() {
		txt := si.uicon or { '' }
		ctx.draw_text(si.x + 10, y, txt, ctx.win.extra_map['icon_ttf'], gx.TextCfg{
			size:  ctx.win.font_size
			color: ctx.theme.text_color
		})
		wid := ctx.text_width(txt) + 17
		ctx.draw_text(si.x + wid, y, si.text, ctx.font, gx.TextCfg{
			size:  ctx.win.font_size
			color: ctx.theme.text_color
		})
		return
	}

	ctx.draw_text(si.x + 10, y, si.text, ctx.font, gx.TextCfg{
		size:  ctx.win.font_size
		color: ctx.theme.text_color
	})
}
