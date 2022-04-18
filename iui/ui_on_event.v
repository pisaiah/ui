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

fn (mut com Component) on_mouse_down_component(app &Window) {
	is_point_in := point_in_raw(mut com, app.click_x, app.click_y)
	com.is_mouse_down = is_point_in

	if mut com is Tabbox {
		mut val := com.kids[com.active_tab]
		for mut comm in val {
			if point_in_raw(mut comm, app.click_x, app.click_y) {
				comm.is_mouse_down = is_point_in
			}
		}
	}

	for mut child in com.children {
		child.on_mouse_down_component(app)
	}
}

fn (mut com Component) on_mouse_rele_component(app &Window) {
	is_point_in := point_in_raw(mut com, app.mouse_x, app.mouse_y)
	com.is_mouse_rele = is_point_in
    com.is_mouse_down = false

	if mut com is Tabbox {
		mut val := com.kids[com.active_tab]
		for mut comm in val {
			if point_in_raw(mut comm, app.mouse_x, app.mouse_y) {
				comm.is_mouse_rele = is_point_in
			}
            comm.is_mouse_down = false
		}
	}

	for mut child in com.children {
		child.on_mouse_rele_component(app)
	}
}

fn on_mouse_down_event(e &gg.Event, mut app Window) {
	app.click_x = app.gg.mouse_pos_x
	app.click_y = app.gg.mouse_pos_y

	// Sort by Z-index
	app.components.sort(a.z_index > b.z_index)

	mut found := false
	for mut com in app.components {
		com.on_mouse_down_component(app)
	}
}

fn on_mouse_up_event(e &gg.Event, mut app Window) {
	app.click_x = -1
	app.click_y = -1
	mx := app.gg.mouse_pos_x
	my := app.gg.mouse_pos_y
	mut found := false
	app.components.sort(a.z_index > b.z_index)
	for mut com in app.components {
		com.on_mouse_rele_component(app)
	}
}

fn on_scroll_event(e &gg.Event, mut app Window) {
	app.components.sort(a.z_index > b.z_index)
	for mut a in app.components {
		if mut a is Tabbox {
			for _, mut val in a.kids {
				for mut comm in val {
					if mut comm is TextField {
						rune_box_scroll(e, mut comm)
					}

					if mut comm is TextArea && !comm.is_selected {
						continue
					}

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
			}
			continue
		}

		if mut a is Modal || mut a is HBox {
			for mut child in a.children {
				if mut child is Tree {
					if child.is_hover {
						scroll_y := int(e.scroll_y)

						child.scroll_i += -scroll_y
						return
					}
					continue
				}
			}

			scroll_y := (int(e.scroll_y) / 2)
			if abs(e.scroll_y) != e.scroll_y {
				a.scroll_i += -scroll_y
			} else if a.scroll_i > 0 {
				a.scroll_i -= scroll_y
			}
			if a.scroll_i < 0 {
				a.scroll_i = 0
			}
			return
		}

		if mut a is Tree {
			if a.is_hover {
				scroll_y := int(e.scroll_y)
				if a.open < a.height {
					return
				}

				if abs(e.scroll_y) != e.scroll_y {
					a.scroll_i += -scroll_y
				} else if a.scroll_i > 0 {
					a.scroll_i -= scroll_y
				}
				if a.scroll_i < 0 {
					a.scroll_i = 0
				}
				if (a.scroll_i * 2) > a.open - (a.height / 2) {
					a.scroll_i = (a.open - (a.height / 2)) / 2
				}
				return
			}
			continue
		}

		if mut a is TextField {
			rune_box_scroll(e, mut a)
		}

		if a is TextArea && !a.is_selected {
			continue
		}

		scroll_y := int(e.scroll_y)
		if abs(e.scroll_y) != e.scroll_y {
			a.scroll_i += -scroll_y
		} else if a.scroll_i > 0 {
			a.scroll_i -= scroll_y
		}
		if a.scroll_i < 0 {
			a.scroll_i = 0
		}
	}
}
