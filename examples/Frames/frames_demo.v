module main

import iui as ui

[heap]
struct App {
mut:
	win &ui.Window
	dp &ui.DesktopPane
	icon1 int
	icon2 int
	icon3 int
	icon4 int
	icons []int
}

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title: 'My Window'
		width: 600
		height: 400
		theme: ui.theme_default()
	)

	mut dp := ui.DesktopPane.new()
	
	mut app := &App{
		win: window
		dp: dp
	}
	
	app.make_icons()

	mut f := ui.InternalFrame.new(
		text: 'Hello there'
		bounds: ui.Bounds{0, 0, 200, 300}
	)
	
	mut pa := app.make_btns()
	
	mut pb := ui.Panel.new(layout: ui.BorderLayout.new())
	pb.add_child_with_flag(pa, ui.borderlayout_center)

	f.add_child(pb)
	dp.add_child(f)

	app.new_frame(4)
	app.new_frame(5)
	app.new_frame(6)

	mut p := ui.Panel.new(
		layout: ui.BorderLayout.new()
	)

	p.add_child_with_flag(dp, ui.borderlayout_center)

	window.add_child(p)

	// Start GG / Show Window
	window.run()
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

fn (mut app App) btn_click(mut e ui.MouseEvent) {
	app.new_frame(e.target.text.int() + 4)
}

fn (mut app App) new_frame(img_id int) {
	i := app.dp.children.len - 1
	mut frame := ui.InternalFrame.new(text: 'Frame #${i}')

	frame.set_x(210 + i * 20)
	frame.set_y(i * 32)
	frame.z_index = i + 1
	frame.height = 150

	mut b := ui.Image.new(id: app.icons[img_id])
	b.pack()

	mut sv := ui.ScrollView.new(view: b)

	frame.add_child(sv)

	app.dp.add_child(frame)
}

fn (mut app App) make_icons() {
	mut ctx := app.win.graphics_context

	mut arr := [
		$embed_file('images/bananas_small.png')
		$embed_file('images/globe_small.png')
		$embed_file('images/package_small.png')
		$embed_file('images/soccer_ball_small.png')
		
		$embed_file('images/bananas.png')
		$embed_file('images/globe.png')
		$embed_file('images/package.png')
		$embed_file('images/soccer_ball.png')
	]
	for mut f in arr {
		im1 := app.win.gg.create_image_from_memory(f.data(), f.len) or { panic(err) }
		app.icons << ctx.gg.cache_image(im1)
	}
}