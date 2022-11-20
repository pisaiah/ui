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
	}

	if e.typ == .touches_moved {
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
	if e.typ == .key_up {
		letter := e.key_code.str()
		if letter == 'left_shift' || letter == 'right_shift' {
			app.shift_pressed = false
		}
	}

	if e.typ == .mouse_scroll {
		on_scroll_event(e, mut app)
	}
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

		bar_x := com.x + com.width - com.xbar_width
		if app.click_x >= bar_x {
			return true
		}

		bar_y := com.y + com.height - com.ybar_height
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

	if mut com is VBox || mut com is HBox || mut com is ScrollView {
		return false
	}

	return true
}

pub fn (mut com Component) on_mouse_rele_component(app &Window) bool {
	is_point_in := point_in_raw(mut com, app.mouse_x, app.mouse_y)
	com.is_mouse_rele = is_point_in
	com.is_mouse_down = false

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
				return true
			}
		}
	}

	if mut com is VBox || mut com is HBox || mut com is ScrollView {
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

				// return
			}
		}
		return
	}

	if is_point_in {
		com.scroll_y_by(e)
	}

	for mut child in com.children {
		if point_in_raw(mut child, app.mouse_x, app.mouse_y) {
			child.on_scroll_component(app, e)
		}
	}
}

pub fn (mut comm Component) scroll_y_by(e &gg.Event) {
	scroll_y := int(e.scroll_y)
	if abs(e.scroll_y) != e.scroll_y {
		comm.scroll_i += -scroll_y
	} else if comm.scroll_i > 0 {
		comm.scroll_i -= scroll_y
	}

	comm.scroll_change_event(comm, -scroll_y, 0)

	if comm.scroll_i < 0 {
		comm.scroll_i = 0
	}
}

pub fn on_scroll_event(e &gg.Event, mut app Window) {
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
