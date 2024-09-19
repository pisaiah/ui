module main

import iui as ui

fn (mut app App) make_frame_tab() &ui.Panel {
	// Create Window
	app.make_icons()

	mut f := ui.InternalFrame.new(
		text:   'Hello there'
		bounds: ui.Bounds{0, 0, 200, 300}
	)

	mut pa := app.make_btns()

	mut pb := ui.Panel.new(layout: ui.BorderLayout.new())
	pb.add_child_with_flag(pa, ui.borderlayout_center)

	f.add_child(pb)
	app.dp.add_child(f)

	app.new_frame(4)
	app.new_frame(5)
	app.new_frame(6)

	mut p := ui.Panel.new(
		layout: ui.BorderLayout.new()
	)

	p.add_child_with_flag(app.dp, ui.borderlayout_center)

	return p
}

fn (mut app App) make_btns() &ui.Panel {
	mut pa := ui.Panel.new()

	bb := ui.Bounds{10, 10, 70, 45}

	for i in 0 .. 4 {
		mut b1 := ui.Button.new(text: '${i}', bounds: bb, icon: app.icons[i])
		b1.icon_width = 32
		b1.icon_height = 32
		b1.subscribe_event('mouse_up', app.btn_click)
		pa.add_child(b1)
	}

	pa.set_bounds(0, 0, 80, 50)
	return pa
}

fn (mut app App) btn_click(e &ui.MouseEvent) {
	app.new_frame(e.target.text.int() + 4)
}

fn (mut app App) new_frame(img_id int) {
	i := app.dp.children.len - 1
	mut frame := ui.InternalFrame.new(
		text:   'Frame #${i}'
		bounds: ui.Bounds{210 + i * 20, i * 32, 0, 150}
	)

	frame.z_index = i + 1

	mut b := ui.Image.new(id: app.icons[img_id])
	b.pack()

	mut sv := ui.ScrollView.new(view: b)
	frame.add_child(sv)

	app.dp.add_child(frame)
}

fn (mut app App) make_icons() {
	mut ctx := app.win.graphics_context

	mut arr := [
		$embed_file('images/bananas_small.png'),
		$embed_file('images/globe_small.png'),
		$embed_file('images/package_small.png'),
		$embed_file('images/soccer_ball_small.png'),
		$embed_file('images/bananas.png'),
		$embed_file('images/globe.png'),
		$embed_file('images/package.png'),
		$embed_file('images/soccer_ball.png'),
	]
	for mut f in arr {
		im1 := app.win.gg.create_image_from_memory(f.data(), f.len) or { panic(err) }
		app.icons << ctx.gg.cache_image(im1)
	}
}
