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

fn on_mouse_down_event(e &gg.Event, mut app Window) {
	app.click_x = app.gg.mouse_pos_x
	app.click_y = app.gg.mouse_pos_y

	// Sort by Z-index
	app.components.sort(a.z_index > b.z_index)

	mut found := false
	for mut com in app.components {
		if point_in(mut com, app.click_x, app.click_y) && !found {
			found = true
			if mut com is Tabbox {
				for _, mut val in com.kids {
					for mut comm in val {
						if point_in(mut comm, app.click_x - com.x, (app.click_y - com.y - 20))
							&& !found {
							comm.is_mouse_down = true
						}
					}
				}
			}
			if mut com is Modal {
				for mut child in com.children {
					if point_in(mut child, app.click_x - com.x, (app.click_y - com.y)) && !found {
						child.is_mouse_down = true
					}
				}
			}
			com.is_mouse_down = true
		} else {
			if mut com is Tabbox {
				for _, mut val in com.kids {
					for mut comm in val {
						if point_in(mut comm, app.click_x - com.x, (app.click_y - com.y - 20)) {
							comm.is_mouse_down = false
						}
					}
				}
			}
			com.is_mouse_down = false
		}
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
		if point_in(mut com, mx, my) && !found {
			com.is_mouse_down = false
			com.is_mouse_rele = true
			if mut com is Tabbox {
				for _, mut val in com.kids {
					for mut comm in val {
						if point_in(mut comm, mx - com.x, (my - com.y - 20)) {
							comm.is_mouse_down = false
							comm.is_mouse_rele = true
						}
					}
				}
			}

			if mut com is Modal {
				for mut kid in com.children {
					mut ws := gg.window_size()
					mut sx := (ws.width / 2) - (500 / 2)
					if point_in(mut kid, mx - com.x - sx, (my - com.y) - (com.top_off + 26)) {
						kid.is_mouse_down = false
						kid.is_mouse_rele = true
					}
				}
			}
			found = true
		} else {
			com.is_mouse_down = false
		}
	}
}

fn on_scroll_event(e &gg.Event, mut app Window) {
	for mut a in app.components {
		if mut a is Tabbox {
			for _, mut val in a.kids {
				for mut comm in val {
					if mut comm is Textbox {
						text_box_scroll(e, mut comm)
					}
				}
			}
		}

		if mut a is Modal {
			scroll_y := (int(e.scroll_y) / 2)
			if abs(e.scroll_y) != e.scroll_y {
				a.scroll_i += -scroll_y
			} else if a.scroll_i > 0 {
				a.scroll_i -= scroll_y
			}
			if a.scroll_i < 0 {
				a.scroll_i = 0
			}
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
				if a.scroll_i > a.open - (a.height / 2) {
					a.scroll_i = a.open - (a.height / 2)
				}
				return
			}
		}

		if mut a is Textbox {
			text_box_scroll(e, mut a)
		}
	}
}
