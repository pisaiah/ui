module iui

import gx

pub interface VariableHeight {
mut:
	get_height() int
}

// NavPane - A navigation pane
pub struct NavPane implements Container {
	Component_A
pub mut:
	pack              bool
	collapsed         bool
	animate           bool = true
	container_pass_ev bool = true
}

// TODO: check default WinUI3 value for collapsed.
@[params]
pub struct NavPaneConfig {
pub mut:
	pack      bool
	collapsed bool
}

pub fn (mut com NavPane) add_child(c &Component) {
	if com.children.len == 0 || c.text == 'Settings' {
		com.children << c
		return
	}

	if isnil(c.parent) {
		unsafe {
			c.set_parent(com)
		}
	}

	if com.children.len == 1 {
		// mut p := Panel.new(layout: BoxLayout.new(ori: 1, hgap: 0, vgap: 0))
		mut sv := ScrollView.new(
			view: unsafe { c }
		)
		// sv.children << c
		sv.noborder = true
		com.children << sv
		return
	}

	com.children[1].children << c
	// com.children << c
}

// Return new Progressbar
pub fn NavPane.new(c NavPaneConfig) &NavPane {
	mut np := &NavPane{
		pack:      c.pack
		collapsed: c.collapsed
	}

	np.width = np.get_target_width()

	mut collapse_btn := NavPaneItem.new(
		text:       'Collapse'
		icon:       '\ue700'
		lock_width: true
	)

	collapse_btn.subscribe_event('mouse_up', fn (e &MouseEvent) {
		mut np := unsafe { &NavPane(voidptr(e.target.parent)) }
		np.set_collapsed(!np.collapsed)
	})

	np.add_child(collapse_btn)

	return np
}

// Note: check why V isn't matching substructs with 'is'
pub interface INavPaneItem {
mut:
	offset int
	open   bool
}

// NavPaneItem
pub struct NavPaneItem implements VariableHeight, INavPaneItem {
	Component_A
pub mut:
	icon       string
	lock_width bool
	offset     int
	open       bool
}

pub fn (mut item NavPaneItem) is_selected() bool {
	np := item.get_parent[&NavPane]()
	return np.text == item.text
}

pub fn (mut item NavPaneItem) unselect() {
	mut np := item.get_parent[&NavPane]()
	np.text = ''
}

@[params]
pub struct NavPaneItemConfig {
pub mut:
	text       string
	icon       string
	lock_width bool
}

pub fn NavPaneItem.new(c NavPaneItemConfig) &NavPaneItem {
	mut item := &NavPaneItem{
		icon:       c.icon
		lock_width: c.lock_width
		text:       c.text
	}

	item.subscribe_event('mouse_up', item.set_selected_on_mouse_up)

	return item
}

pub fn (mut item NavPaneItem) pack_do(ctx &GraphicsContext) {
	item.width = if item.lock_width { 40 } else { item.parent.width - 8 }
	item.height = 36
	if !isnil(item.parent) {
		if item.lock_width {
			item.x = 48 / 2 - item.width / 2
		} else {
			item.x = item.parent.width / 2 - item.width / 2
		}
	}
}

// Draw down arrow
fn (box &NavPaneItem) draw_arrow(ctx &GraphicsContext, x int, y int, w int, h int) {
	a := x + w - 24
	b := y + (h / 2) - 3
	ctx.gg.draw_triangle_filled(a, b, a + 5, b + 5, a + 10, b, ctx.theme.text_color)
}

// Default mouse up event
pub fn (mut item NavPaneItem) set_selected_on_mouse_up(e &MouseEvent) {
	mut pp := item.get_parent[&NavPane]()

	if item.text != 'Collapse' {
		already := pp.text == item.text || item.open
		pp.text = item.text

		if !already && item.children.len > 0 {
			item.open = true
		}

		if already && item.children.len != 0 {
			pp.text = ''
			item.open = false
		}
	}
}

pub fn (mut item NavPaneItem) get_height() int {
	if item.is_selected() || item.open {
		mut h := item.height + 4
		for mut child in item.children {
			h += child.height + 4
		}
		return h
	}
	return item.height + 4
}

// Draw this component
pub fn (mut item NavPaneItem) draw(ctx &GraphicsContext) {
	mut pp := item.get_parent[&NavPane]()

	if pp.pack || (item.width != pp.width - 8 || item.height == 0) {
		if pp.pack {
			pp.pack_do(ctx)
		}
		item.pack_do(ctx)
	}

	is_hover := is_in(item, ctx.win.mouse_x, ctx.win.mouse_y)

	if is_hover {
		bg := if item.is_mouse_down { ctx.theme.button_bg_click } else { ctx.theme.button_bg_hover }
		ctx.gg.draw_rounded_rect_filled(item.x, item.y, item.width, item.height, 4, bg)
	}

	if item.is_mouse_rele {
		item.is_mouse_rele = false
	}

	if item.is_selected() {
		bg := if is_hover { ctx.theme.button_bg_click } else { ctx.theme.button_bg_hover }
		ctx.gg.draw_rounded_rect_filled(item.x, item.y, item.width, item.height, 4, bg)
		ctx.gg.draw_rect_filled(item.x + item.offset, item.y + item.height / 4, 3, item.height / 2,
			ctx.theme.accent_fill)
	}

	// Draw Icon
	font := ctx.win.extra_map['icon_ttf']
	cfgg := gx.TextCfg{
		size:   ctx.win.font_size
		color:  ctx.theme.text_color
		family: font
	}
	ctx.gg.set_text_cfg(cfgg)
	text := item.icon
	size := item.offset + (40 / 2) - ctx.text_width(text) / 2
	ctx.draw_text(item.x + size, item.y + (item.height / 2) - ctx.line_height / 2, text,
		font, cfgg)
	ctx.reset_text_font()

	if item.children.len > 0 && !pp.collapsed {
		item.draw_arrow(ctx, item.x, item.y, item.width, item.height)

		if item.is_selected() || item.open {
			mut y := item.y + item.height + 4
			offset := item.offset + size + 16
			for mut child in item.children {
				if isnil(child.parent) {
					child.set_parent(pp)
				}

				if mut child is INavPaneItem {
					child.offset = offset
				}

				child.draw_with_offset(ctx, pp.x + offset, y)
				y += child.height + 4
			}
		}
	}

	if (pp.collapsed || item.lock_width) && item.icon.len != 0 {
		return
	}
	tx := if item.icon.len != 0 { size + 32 } else { 8 }
	ctx.draw_text(item.x + tx, item.y + (item.height / 2) - ctx.line_height / 2, item.text,
		ctx.font, gx.TextCfg{
		size:  ctx.win.font_size
		color: ctx.theme.text_color
	})
}

pub fn (mut np NavPane) set_collapsed(val bool) {
	np.collapsed = val
	np.pack()
}

// Sets the pack value to true
pub fn (mut np NavPane) pack() {
	np.pack = true
}

pub fn (mut np NavPane) pack_do_height(g &GraphicsContext) {
	if !isnil(np.parent) {
		np.height = np.parent.height
	} else {
		np.height = g.win.gg.window_size().height
	}
}

pub fn (np NavPane) get_target_width() int {
	return if np.collapsed { 48 } else { 320 }
}

pub fn (mut np NavPane) is_animating() bool {
	return np.animate && np.width != np.get_target_width()
}

// Attempt to Pack
pub fn (mut np NavPane) pack_do(g &GraphicsContext) {
	np.pack_do_height(g)

	if !np.animate {
		// Just show up out of nowhere.
		np.width = np.get_target_width()
		np.pack = false
		return
	}

	speed := 24
	np.width += if np.width < np.get_target_width() { speed } else { -speed }

	if np.collapsed && np.width <= 48 {
		np.width = 48
		np.pack = false
	}

	if !np.collapsed && np.width >= 320 {
		np.width = 320
		np.pack = false
	}
}

// Draw this component
pub fn (mut np NavPane) draw(ctx &GraphicsContext) {
	if np.pack {
		np.pack_do(ctx)
	}

	np.pack_do_height(ctx)

	ctx.gg.draw_rect_filled(np.x, np.y, np.width, np.height, ctx.theme.menubar_background)

	if np.is_mouse_rele {
		np.is_mouse_rele = false
	}

	mut y := np.y + np.draw_child(ctx, 0, np.y)

	// ctx.gg.scissor_rect(np.x, y, np.width, np.height)

	for i in 1 .. np.children.len {
		y += np.draw_child(ctx, i, y)
	}

	// size := ctx.win.get_size()
	// ctx.gg.scissor_rect(0, 0, size.width, size.height)

	// testing:
	// winui3 layout design:
	// [Back Button - part of custom title bar]
	// [Collapse Button]
	// [Search box (optional)]
	// [Items]
	// [Items - Footer]
}

pub fn (mut np NavPane) draw_child(ctx &GraphicsContext, i int, y int) int {
	mut child := np.children[i]

	if mut child is ScrollView {
		w := np.get_target_width()
		mut h := np.height - (y / 2) - 4
		if np.children.last().text == 'Settings' {
			h -= np.children.last().height + 8
		}
		np.children[1].set_bounds(0, 0, w, h)
	}

	if isnil(child.parent) {
		child.set_parent(np)
	}

	if child.text == 'Settings' {
		fy := np.y + np.height - child.height - 4
		child.draw_with_offset(ctx, np.x, fy)
		return child.height + 4
	}

	child.draw_with_offset(ctx, np.x, y)

	if mut child is NavPaneItem {
		return child.get_height()
	}
	return child.height + 4
}
