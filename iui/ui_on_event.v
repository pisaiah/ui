module iui

import gg

fn on_event(e &gg.Event, mut app Window) {
	if e.typ == .mouse_leave {
		app.has_event = false
	} else {
		app.has_event = true
	}

	if e.typ == .mouse_move {
		app.mouse_x = app.gg.mouse_pos_x
		app.mouse_y = app.gg.mouse_pos_y
	}
	// else { dump(e.typ)}

	if e.typ == .mouse_down {
		on_mouse_down_event(e, mut app)
	}

	if e.typ == .mouse_up {
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

fn (mut com Component) on_mouse_down_component(app &Window) bool {
	is_point_in := point_in_raw(mut com, app.click_x, app.click_y)
	if !is_point_in {
		return false
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
				return true
			}
		}
	}
	return true
}

fn (mut com Component) on_mouse_rele_component(app &Window) bool {
	is_point_in := point_in_raw(mut com, app.mouse_x, app.mouse_y)
	com.is_mouse_rele = is_point_in
	com.is_mouse_down = false

	if mut com is Tabbox {
		mut val := com.kids[com.active_tab]
		for mut comm in val {
        			comm.is_mouse_down = false
			if point_in_raw(mut comm, app.mouse_x, app.mouse_y) {
				comm.is_mouse_rele = is_point_in
                return true
			}
		}
	}

	for mut child in com.children {
		if child.on_mouse_rele_component(app) {
            return true
        }
	}
    return is_point_in
}

fn on_mouse_down_event(e &gg.Event, mut app Window) {
	app.click_x = app.gg.mouse_pos_x
	app.click_y = app.gg.mouse_pos_y

	// Sort by Z-index
	app.components.sort(a.z_index > b.z_index)

	for mut com in app.components {
		if com.on_mouse_down_component(app) {
            return
        }
	}
}

fn on_mouse_up_event(e &gg.Event, mut app Window) {
	app.click_x = -1
	app.click_y = -1

	app.components.sort(a.z_index > b.z_index)
	for mut com in app.components {
		if com.on_mouse_rele_component(app) {
            return
        }
	}
}

fn (mut com Component) on_scroll_component(app &Window, e &gg.Event) {
	is_point_in := point_in_raw(mut com, app.mouse_x, app.mouse_y)
	if is_point_in {
		com.scroll_y_by(e)
	}

	if mut com is Tabbox {
		mut val := com.kids[com.active_tab]
		for mut comm in val {
			if point_in_raw(mut comm, app.mouse_x, app.mouse_y) {
				comm.on_scroll_component(app, e)
			}
		}
	}

	for mut child in com.children {
		if point_in_raw(mut child, app.mouse_x, app.mouse_y) {
			child.on_scroll_component(app, e)
		}
	}
}

fn (mut comm Component) scroll_y_by(e &gg.Event) {
	scroll_y := int(e.scroll_y)
	if abs(e.scroll_y) != e.scroll_y {
		comm.scroll_i += -scroll_y
	} else if comm.scroll_i > 0 {
		comm.scroll_i -= scroll_y
	}
	if comm.scroll_i < 0 {
		comm.scroll_i = 0
	}
}

fn on_scroll_event(e &gg.Event, mut app Window) {
	app.components.sort(a.z_index > b.z_index)
	for mut a in app.components {
		a.on_scroll_component(app, e)
	}
}
