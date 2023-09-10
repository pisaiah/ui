module iui

import gg

pub fn on_event(e &gg.Event, mut app Window) {
	/*
	if e.typ == .mouse_leave {
		app.has_event = false
	} else {
		app.has_event = true
	}*/

	app.has_event = true

	if e.typ == .mouse_move {
		app.mouse_x = app.gg.mouse_pos_x
		app.mouse_y = app.gg.mouse_pos_y
		return
	}

	if e.typ == .touches_moved || e.typ == .touches_began {
		app.mouse_x = int(e.touches[0].pos_x / app.gg.scale)
		app.mouse_y = int(e.touches[0].pos_y / app.gg.scale)
	}

	// debug: app.id_map['cggevent'] = e
	if e.typ == .mouse_down || e.typ == .touches_began {
		on_mouse_down_event(e, mut app)
	}

	if e.typ == .mouse_up || e.typ == .touches_ended {
		on_mouse_up_event(e, mut app)
	}
	if e.typ == .key_down {
		app.key_down(e.key_code, e)
	}

	if e.typ == .char {
		app.key_down(e.key_code, e)
	}

	if e.typ == .key_up {
		letter := e.key_code.str()
		if letter == 'left_shift' || letter == 'right_shift' {
			app.shift_pressed = false
		}
	}

	if e.typ == .mouse_scroll {
		on_scroll_event(e, mut app)
	}

	app.has_event = false
}

fn (mut app Window) check_box(key gg.KeyCode, e &gg.Event, mut a Component) bool {
	if mut a is TextField {
		app.runebox_key(key, e, mut a)
		return a.is_selected
	}
	if mut a is Textbox {
		app.textbox_key_down(key, e, mut a)
		return true
	}
	if mut a is Tabbox {
		mut kids := a.kids[a.active_tab]
		for mut comm in kids {
			app.check_box(key, e, mut comm)
		}
	}
	if mut a is VBox || mut a is HBox || mut a is Titlebox || mut a is SplitView {
		for mut comm in a.children {
			if app.check_box(key, e, mut comm) {
				return true
			}
		}
	}
	if mut a is ScrollView || mut a is Panel {
		for mut comm in a.children {
			if app.check_box(key, e, mut comm) {
				return true
			}
		}
	}
	return false
}

fn (mut app Window) key_down(key gg.KeyCode, e &gg.Event) {
	// global keys
	match key {
		.left_alt {
			app.debug_draw = !app.debug_draw
			return
		}
		.left_control {
			// TODO: Copy & Paste, Undo & Redo
			return
		}
		else {}
	}
	for mut a in app.components {
		app.check_box(key, e, mut a)

		if mut a is Modal {
			for mut child in a.children {
				app.check_box(key, e, mut child)
			}
		}
		if mut a is Page {
			for mut child in a.children {
				app.check_box(key, e, mut child)
			}
			return
		}
	}
	app.key_down_event(mut app, key, e)
}

pub fn (mut com Component) on_mouse_down_component(app &Window) bool {
	is_point_in := point_in_raw(mut com, app.click_x, app.click_y)
	if !is_point_in {
		return false
	}

	if app.bar != unsafe { nil } && app.bar.tik < 9 {
		return true
	}

	if mut com is ScrollView {
		com.is_mouse_down = true

		bar_x := com.rx + com.width - com.xbar_width
		if app.click_x >= bar_x {
			return true
		}

		bar_y := com.ry + com.height - com.ybar_height

		if app.click_y >= bar_y {
			return true
		}
	}

	for mut child in com.children {
		if child.on_mouse_down_component(app) {
			return true
		}
	}

	com.is_mouse_down = is_point_in
	if is_point_in {
		invoke_mouse_down(com, app.graphics_context)
	}

	if mut com is Tabbox {
		mut val := com.kids[com.active_tab]
		for mut comm in val {
			if point_in_raw(mut comm, app.click_x, app.click_y) {
				comm.is_mouse_down = is_point_in
				if comm.on_mouse_down_component(app) {
					return true
				}
			}
		}
	}

	if mut com is VBox || mut com is HBox || mut com is ScrollView || mut com is SplitView
		|| mut com is Panel {
		return false
	}

	return true
}

pub fn (mut com Component) on_mouse_rele_component(app &Window) bool {
	is_point_in := point_in_raw(mut com, app.mouse_x, app.mouse_y)
	com.is_mouse_rele = is_point_in
	com.is_mouse_down = false

	if is_point_in {
		invoke_mouse_up(com, app.graphics_context)
	}

	if mut com is Tabbox {
		mut val := com.kids[com.active_tab]
		val.sort(a.z_index > b.z_index)
		for mut comm in val {
			comm.is_mouse_down = false
			if point_in_raw(mut comm, app.mouse_x, app.mouse_y) {
				comm.is_mouse_rele = is_point_in
				if comm.on_mouse_rele_component(app) {
					val.sort(a.z_index < b.z_index)
					return true
				}
			}
		}
		val.sort(a.z_index < b.z_index)
	}

	if mut com is VBox {
		if com.children.len < 0 || com.scroll_i < 0 {
			return false
		}
		for i in com.scroll_i .. com.children.len {
			mut child := com.children[i]
			if child.on_mouse_rele_component(app) {
				return true
			}
		}
	} else {
		for mut child in com.children {
			if child.on_mouse_rele_component(app) {
				if child.parent != unsafe { nil } {
					return false
				}
				return true
			}
		}
	}

	if mut com is VBox || mut com is HBox || mut com is ScrollView || mut com is SplitView
		|| mut com is Panel {
		return false
	}

	return is_point_in
}

pub fn on_mouse_down_event(e &gg.Event, mut app Window) {
	if e.typ == .mouse_down {
		// Desktop
		app.click_x = app.gg.mouse_pos_x
		app.click_y = app.gg.mouse_pos_y
	} else {
		// Mobile
		app.click_x = int(e.touches[0].pos_x / app.gg.scale)
		app.click_y = int(e.touches[0].pos_y / app.gg.scale)
	}

	res := app.bar.check_mouse(app, app.click_x, app.click_y)
	if res {
		return
	}

	for mut pop in app.popups {
		mut com := &Component(pop)
		if com.on_mouse_down_component(app) {
			return
		}
	}

	// Sort by Z-index
	app.components.sort(a.z_index > b.z_index)

	for mut com in app.components {
		if com.on_mouse_down_component(app) {
			return
		}
		if mut com is Modal || mut com is Page {
			return
		}
	}
}

pub fn on_mouse_up_event(e &gg.Event, mut app Window) {
	app.click_x = -1
	app.click_y = -1

	if !isnil(app.bar) {
		mut bar := &Component(app.bar)
		bar.on_mouse_rele_component(app)
	}

	res := app.bar.check_mouse(app, app.mouse_x, app.mouse_y)
	if res {
		return
	}

	for mut pop in app.popups {
		mut com := &Component(pop)
		if com.on_mouse_rele_component(app) {
			pop.hide(app.graphics_context)
			return
		}
	}

	app.components.sort(a.z_index > b.z_index)
	for mut com in app.components {
		if com.on_mouse_rele_component(app) {
			return
		}
		if mut com is Modal || mut com is Page {
			return
		}
	}
}

pub fn (mut com Component) on_scroll_component(app &Window, e &gg.Event) {
	is_point_in := point_in_raw(mut com, app.mouse_x, app.mouse_y)

	if mut com is Tabbox {
		mut val := com.kids[com.active_tab]
		for mut comm in val {
			if point_in_raw(mut comm, app.mouse_x, app.mouse_y) {
				comm.on_scroll_component(app, e)
			}
		}
		return
	}

	if is_point_in {
		com.scroll_y_by(e, app.graphics_context)
	}

	for mut child in com.children {
		if point_in_raw(mut child, app.mouse_x, app.mouse_y) {
			child.on_scroll_component(app, e)
		}
	}
}

pub fn (mut com Component) scroll_y_by(e &gg.Event, ctx &GraphicsContext) {
	scroll_y := int(e.scroll_y)
	if abs(e.scroll_y) != e.scroll_y {
		com.scroll_i += -scroll_y
	} else if com.scroll_i > 0 {
		com.scroll_i -= scroll_y
	}

	invoke_scroll_event(com, ctx, -scroll_y)

	if com.scroll_i < 0 {
		com.scroll_i = 0
	}
}

pub fn on_scroll_event(e &gg.Event, mut app Window) {
	for mut pop in app.popups {
		mut com := &Component(pop)
		com.on_scroll_component(app, e)

		is_point_in := point_in_raw(mut com, app.mouse_x, app.mouse_y)
		if is_point_in {
			return
		}
	}

	app.components.sort(a.z_index > b.z_index)
	for mut a in app.components {
		a.on_scroll_component(app, e)
		if mut a is Modal {
			break
		}
		if mut a is Page {
			break
		}
	}
}
