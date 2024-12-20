module iui

import gg

pub fn on_event(e &gg.Event, mut app Window) {
	/*
	if e.typ == .mouse_leave {
		app.has_event = false
	} else {
		app.has_event = true
	}*/

	$if event_debug ? {
		dump(e.typ)
		if e.typ == .resized || e.typ == .quit_requested {
			dump(e)
		}
	}

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
		app.invoke_key_event(e.key_code, e, 'key_up')
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
	if mut a is Titlebox || mut a is SplitView || mut a is InternalFrame {
		for mut comm in a.children {
			if app.check_box(key, e, mut comm) {
				return true
			}
		}
	}
	if mut a is ScrollView || mut a is Panel || mut a is DesktopPane || mut a is Container {
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
		if mut a is Modal {
			for mut child in a.children {
				app.check_box(key, e, mut child)
			}
			return
		}
		if mut a is Page {
			for mut child in a.children {
				app.check_box(key, e, mut child)
			}
			return
		}

		app.check_box(key, e, mut a)
	}
	app.key_down_event(mut app, key, e)
	app.invoke_key_event(key, e, 'key_down')
}

pub fn (mut com Popup) on_mouse_down_component(app &Window) bool {
	is_point_in := point_in_raw(mut com, app.click_x, app.click_y)

	$if event_debug ? {
		println('on_mouse_down_component: ${is_point_in} Popup ${com.x} ${com.y} ${com.width} ${com.height}')
	}

	if !is_point_in {
		return false
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

	return true
}

pub fn (mut com Component) on_mouse_down_component(app &Window) bool {
	is_point_in := point_in_raw(mut com, app.click_x, app.click_y)

	$if event_debug ? {
		println('on_mouse_down_component: ${is_point_in} ${com.type_name()} ${com.x} ${com.y} ${com.width} ${com.height}')
	}

	if !is_point_in {
		return false
	}

	if app.bar != unsafe { nil } && app.bar.tik < 9 {
		return true
	}

	// dump(com.handle_mouse_down(app))

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

	if mut com is InternalFrame {
		com.is_mouse_down = is_point_in
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

	if mut com is Container {
		if com.container_pass_ev {
			return false
		}
	}

	if mut com is ScrollView || mut com is SplitView || mut com is Panel || com is SettingsCard {
		return false
	}

	return true
}

pub fn (mut com Popup) on_mouse_rele_component(app &Window) bool {
	is_point_in := point_in_raw(mut com, app.mouse_x, app.mouse_y)
	com.is_mouse_rele = is_point_in
	com.is_mouse_down = false

	if is_point_in {
		invoke_mouse_up(com, app.graphics_context)
	}

	if !com.container_pass_ev {
		return false
	}

	// Check Children
	for mut child in com.children {
		if child.on_mouse_rele_component(app) {
			return is_point_in
		}
	}

	if com.container_pass_ev {
		return false
	}

	return is_point_in
}

pub fn on_mouse_rele_generic[T](mut com T, app &Window) bool {
	is_point_in := point_in(mut com, app.mouse_x, app.mouse_y)
	com.is_mouse_rele = is_point_in
	com.is_mouse_down = false

	$if event_debug ? {
		dump('${com.str()} ${com.x} ${com.y} ${com.width} ${com.height}')
	}

	$if T is ScrollView {
		if app.mouse_y < com.ry {
			return false
		}
	}

	if is_point_in {
		invoke_mouse_up(com, app.graphics_context)
	}

	$if T is Tabbox {
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

	$if T is Container {
		// If Container does not pass event,
		// then return false. (Ex: Click Animation)
		if !com.container_pass_ev {
			return false
		}
	}

	// Check Children
	for mut child in com.children {
		if child.on_mouse_rele_component(app) {
			return is_point_in
		}
	}

	$if T is Container {
		// If Container passes the event to
		// children then return false
		if com.container_pass_ev {
			return false
		}
	}

	$if T is ScrollView || T is SplitView || T is Panel {
		return false
	}

	return is_point_in
}

pub fn (mut com Component) on_mouse_rele_component(app &Window) bool {
	is_point_in := point_in_raw(mut com, app.mouse_x, app.mouse_y)
	com.is_mouse_rele = is_point_in
	com.is_mouse_down = false

	if mut com is ScrollView {
		if app.mouse_y < com.ry {
			return false
		}
	}

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

	if mut com is Container {
		// If Container does not pass event,
		// then return false. (Ex: Click Animation)
		if !com.container_pass_ev {
			return false
		}
	}

	// Check Children
	for mut child in com.children {
		if child.on_mouse_rele_component(app) {
			return is_point_in
		}
	}

	if mut com is Container {
		// If Container passes the event to
		// children then return false
		if com.container_pass_ev {
			return false
		}
	}

	if mut com is ScrollView || mut com is SplitView || mut com is Panel {
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
		$if event_debug ? {
			dump('Popup on mouse down')
		}

		// mut com := &Component(pop)
		if pop.on_mouse_down_component(app) {
			return
		}
	}

	if app.custom_controls != none {
		mut com := &Component(app.custom_controls.p)
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
		on_mouse_rele_generic[Menubar](mut app.bar, app)
	}

	res := app.bar.check_mouse(app, app.mouse_x, app.mouse_y)
	if res {
		return
	}

	for mut pop in app.popups {
		// mut com := &Component(pop)
		if pop.on_mouse_rele_component(app) {
			pop.hide(app.graphics_context)
			return
		}
	}

	if app.custom_controls != none {
		// on_mouse_rele_generic

		mut com := &Component(app.custom_controls.p)
		if com.on_mouse_rele_component(app) {
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
	com.scroll_i -= scroll_y
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
