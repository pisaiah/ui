module main

import iui as ui
import iui.x.svg
import gx

fn (mut app App) make_svg_tab() &ui.Panel {
	// Create Window
	// app.make_icons()

	mut p := ui.Panel.new(layout: ui.BorderLayout.new())

	mut lbl := ui.Label.new(
		text: '(New!) Experimental SVG <Path> support.\nSee Module: "iui.x.svg" (will become "iui.svg" when non-experimental)'
		pack: true
	)

	mut info := ui.InfoBar.new(
		title: 'SVG'
		text:  '(New!) Experimental SVG <Path> support. See Module: "iui.x.svg"'
	)

	mut svg_panel := make_svg_panel()
	mut btm := ui.Panel.new()

	mut btn1 := ui.Button.new(text: 'Size += ${move_by}')
	mut btn2 := ui.Button.new(text: 'Size -= ${move_by}')
	mut btn3 := ui.Button.new(text: 'Reset size to 32x32')
	btn1.subscribe_event('mouse_up', svg_size_inc_evnt)
	btn2.subscribe_event('mouse_up', svg_size_dec_evnt)
	btn3.subscribe_event('mouse_up', svg_size_reset_evnt)
	btm.add_child(btn1)
	btm.add_child(btn2)
	btm.add_child(btn3)

	p.add_child(info, value: ui.borderlayout_north)
	p.add_child(svg_panel, value: ui.borderlayout_center)
	p.add_child(btm, value: ui.borderlayout_south)

	mut cp := ui.Panel.new(layout: ui.BorderLayout.new())
	cp.add_child_with_flag(p, ui.borderlayout_center)
	// cp.add_child_with_flag(make_code_box('svg_tab.v'), ui.borderlayout_east)

	return cp
}

const move_by = 8

fn svg_size_inc_evnt(mut e ui.MouseEvent) {
	mut par := e.target.parent.parent.children[1]
	for mut kid in par.children {
		is_svg := mut kid is svg.Svg
		if is_svg {
			kid.width += move_by
			kid.height += move_by
		}
	}
}

fn svg_size_dec_evnt(mut e ui.MouseEvent) {
	mut par := e.target.parent.parent.children[1]
	for mut kid in par.children {
		is_svg := mut kid is svg.Svg
		if is_svg {
			kid.width -= move_by
			kid.height -= move_by
		}
	}
}

fn svg_size_reset_evnt(mut e ui.MouseEvent) {
	mut par := e.target.parent.parent.children[1]
	for mut kid in par.children {
		if mut kid is svg.Svg {
			kid.width = 32
			kid.height = 32
		}
	}
}

fn make_svg_panel() &ui.Panel {
	mut p := ui.Panel.new()

	w, h := 64, 64

	// Triangle
	mut svg_a := svg.Svg.new(
		path:    'M 150 5 L 75 200 L 225 200 Z'
		viewbox: '0 0 300 205'
		width:   w
		height:  h
	)

	// X
	mut svg_b := svg.Svg.new(
		path:    'M 2.14645 2.14645C2.34171 1.95118 2.65829 1.95118 2.85355 2.14645L11.5 10.7929L20.1464 2.14645C20.3417 1.95118 20.6583 1.95118 20.8536 2.14645C21.0488 2.34171 21.0488 2.65829 20.8536 2.85355L12.2071 11.5L20.8536 20.1464C21.0488 20.3417 21.0488 20.6583 20.8536 20.8536C20.6583 21.0488 20.3417 21.0488 20.1464 20.8536L11.5 12.2071L2.85355 20.8536C2.65829 21.0488 2.34171 21.0488 2.14645 20.8536C1.95118 20.6583 1.95118 20.3417 2.14645 20.1464L10.7929 11.5L2.14645 2.85355C1.95118 2.65829 1.95118 2.34171 2.14645 2.14645 Z'
		viewbox: '0 0 24 24'
		width:   w
		height:  h
	)

	// Search Icon
	mut svg_c := svg.Svg.new(
		paths:        [
			'M6.5 4V9M4 6.5H9',
			'M6.5 1C9.53757 1 12 3.46243 12 6.5C12 7.83879 11.5217 9.06586 10.7266 10.0196L14.8536 14.1464C15.0488 14.3417 15.0488 14.6583 14.8536 14.8536C14.68 15.0271 14.4106 15.0464 14.2157 14.9114L14.1464 14.8536L10.0196 10.7266C9.06586 11.5217 7.83879 12 6.5 12C3.46243 12 1 9.53757 1 6.5C1 3.46243 3.46243 1 6.5 1ZM6.5 2C4.01472 2 2 4.01472 2 6.5C2 8.98528 4.01472 11 6.5 11C8.98528 11 11 8.98528 11 6.5C11 4.01472 8.98528 2 6.5 2Z',
		]
		accent_first: 1
		viewbox:      '0 0 16 16'
		width:        w
		height:       h
	)

	// Left Arrow
	mut svg_d := svg.Svg.new(
		path:    'M15.5 5.57895L15.5 12.0789L9.36111 12.0789L9.36111 15.5L2.5 9L9.36111 2.5L9.36111 5.57895L15.5 5.57895Z'
		viewbox: '0 0 18 18'
		width:   w
		height:  h
	)

	// Right Arrow
	mut svg_e := svg.Svg.new(
		path:    'M2.5 12.4211V5.92105H8.63889V2.5L15.5 9L8.63889 15.5V12.4211H2.5Z'
		viewbox: '0 0 18 18'
		width:   w
		height:  h
	)

	// Shapes.svg
	mut svg_f := svg.Svg.new(
		paths:        [
			'M2.83333 9.08334C2.83333 5.63156 5.63156 2.83333 9.08334 2.83333C12.3951 2.83333 15.1053 5.40916 15.3197 8.66667H16.1546C15.939 4.94859 12.8555 2 9.08334 2C5.17132 2 2 5.17132 2 9.08334C2 12.8555 4.94859 15.939 8.66667 16.1546V15.3197C5.40916 15.1053 2.83333 12.3951 2.83333 9.08334Z',
			'M9.5 11.5833C9.5 10.4327 10.4327 9.5 11.5833 9.5H19.9166C21.0672 9.5 21.9999 10.4327 21.9999 11.5833V19.9167C21.9999 21.0673 21.0672 22 19.9166 22L11.5833 22C10.4327 22 9.5 21.0673 9.5 19.9167V11.5833ZM11.5833 10.3333C10.893 10.3333 10.3333 10.893 10.3333 11.5833V19.9167C10.3333 20.607 10.893 21.1667 11.5833 21.1667L19.9166 21.1667C20.6069 21.1667 21.1666 20.607 21.1666 19.9167V11.5833C21.1666 10.893 20.6069 10.3333 19.9166 10.3333H11.5833Z',
		]
		viewbox:      '0 0 24 24'
		width:        w
		height:       h
		accent_first: 1
	)

	// Tools.svg
	mut svg_g := svg.Svg.new(
		paths:        [
			'M7.13076 2.59221C5.80441 1.26586 3.6539 1.26579 2.32753 2.59215C1.00237 3.91731 1.00118 6.06508 2.32394 7.39172L3.70702 8.84885C3.09908 9.70318 3.17819 10.8962 3.94436 11.6624L4.57896 12.297C5.43336 13.1514 6.8186 13.1514 7.673 12.297L12.0066 7.96343C12.861 7.10904 12.861 5.7238 12.0066 4.8694L11.372 4.2348C10.5996 3.46245 9.39347 3.38829 8.53781 4.0123L7.13198 2.59343L7.13076 2.59221M7.98887 4.52386L4.21653 8.29621L2.85791 6.86486C1.82449 5.83139 1.82441 4.15593 2.85786 3.12248C3.89113 2.08922 5.56632 2.08906 6.59984 3.12195L7.98887 4.52386M4.47469 9.0987L8.80826 4.76513C9.36976 4.20363 10.2801 4.20363 10.8416 4.76513L11.4762 5.39973C12.0377 5.96123 12.0377 6.8716 11.4762 7.43311L7.14267 11.7667C6.58117 12.3282 5.67079 12.3282 5.10929 11.7667L4.47469 11.1321C3.91319 10.5706 3.91319 9.66021 4.47469 9.0987',
			'M21.4878 2.76199C20.365 1.63923 18.5447 1.63923 17.4219 2.76199L11.9046 8.2803L11.6246 8.0003L11.159 8.5954L19.3935 16.8299C19.9111 17.3474 20.313 17.9689 20.5725 18.6533C20.8855 19.4783 21.2745 20.2724 21.7345 21.0254L21.7787 21.0977C22.1552 21.7139 21.4492 22.42 20.8329 22.0435L20.7606 21.9993C20.0077 21.5393 19.2136 21.1502 18.3885 20.8373C17.7042 20.5777 17.0827 20.1759 16.5651 19.6583L8.3189 11.4121L7.74756 11.9014L8.01552 12.1694L2.01389 18.171L1.45396 22.0897C1.39502 22.5022 1.74859 22.8558 2.16108 22.7968L6.07975 22.2369L12.0814 16.2353L16.0348 20.1886C16.6274 20.7812 17.339 21.2413 18.1226 21.5386C18.9041 21.835 19.6563 22.2035 20.3696 22.6393L20.4419 22.6835C21.7299 23.4705 23.2057 21.9947 22.4187 20.7066L22.3745 20.6344C21.9387 19.9211 21.5702 19.1689 21.2738 18.3873C20.9766 17.6037 20.5165 16.8921 19.9239 16.2995L15.9705 12.3462L21.4878 6.82785C22.6105 5.7051 22.6105 3.88475 21.4878 2.76199M16.2734 4.97221L19.2786 7.97741L15.4401 11.8158L12.4349 8.81063L16.2734 4.97221M19.8087 7.44621L20.9574 6.29752C21.7873 5.46766 21.7873 4.12218 20.9574 3.29232C20.1276 2.46246 18.7821 2.46246 17.9522 3.29232L16.8035 4.44101L19.8087 7.44621M8.54585 12.6997L11.5511 15.7049L5.72619 21.5298L2.22 22.0308L2.72098 18.5246L8.54585 12.6997',
		]
		viewbox:      '0 0 24 24'
		width:        w
		height:       h
		accent_first: 1
	)

	// Dropper.svg
	mut svg_h := svg.Svg.new(
		paths:        [
			'M9.22882 2.91885C8.64304 2.33306 7.69329 2.33307 7.1075 2.91885L6.58241 3.44395C5.99662 4.02973 5.99662 4.97948 6.58241 5.56527L10.1682 9.15105C10.754 9.73684 11.7037 9.73684 12.2895 9.15105L12.8146 8.62596C13.4004 8.04017 13.4004 7.09042 12.8146 6.50464L9.22882 2.91885Z',
			'M9.95044 2.22651L11.4443 0.732255C12.4206 -0.244055 14.0036 -0.2441 14.9799 0.732211C15.9562 1.70851 15.9562 3.29139 14.9799 4.2677L13.486 5.76204L9.95044 2.22651Z',
			'M6.52353 5.50293C6.54244 5.5241 6.56206 5.54485 6.58238 5.56518L10.1682 9.15096C10.1886 9.17136 10.2094 9.19105 10.2306 9.21002L5.73785 13.7028C5.20086 14.2398 4.42335 14.3589 3.8792 14.4324C3.11768 14.5352 2.22619 15.0382 1.31661 15.6089C0.951209 15.8382 0.514858 15.7852 0.238831 15.5043C-0.0356477 15.225 -0.0829352 14.7902 0.145859 14.4282C0.716761 13.525 1.20934 12.6242 1.30537 11.859C1.37432 11.3095 1.4931 10.5334 2.03074 9.99571L6.52353 5.50293ZM2.73785 10.7028L7.22877 6.2119L9.52167 8.50479L5.03074 12.9957C4.76424 13.2622 4.32738 13.3628 3.74543 13.4414C2.9302 13.5514 2.07581 13.9843 1.31343 14.4378C1.76923 13.6683 2.19438 12.8059 2.29759 11.9835C2.37011 11.4055 2.472 10.9687 2.73785 10.7028',
		]
		viewbox:      '0 0 16 16'
		width:        w
		height:       h
		accent_first: 2
	)

	// Eraser.svg
	mut svg_i := svg.Svg.new(
		paths:   [
			'M8.76264 0.512563C9.44606 -0.170855 10.5541 -0.170853 11.2375 0.512564L15.4697 4.7448C16.1532 5.42821 16.1532 6.53625 15.4697 7.21967L8.50008 14.1893L7.79297 13.4822L2.50008 8.18934L1.79297 7.48223L8.76264 0.512563Z',
			'M12.5 15.5H6',
			'M2.5 7.5L8.5 13.5M0.883884 10.8839L5.11612 15.1161C5.60427 15.6043 6.39573 15.6043 6.88388 15.1161L15.1161 6.88388C15.6043 6.39573 15.6043 5.60427 15.1161 5.11612L10.8839 0.883884C10.3957 0.395728 9.60427 0.395727 9.11612 0.883883L0.883883 9.11612C0.395728 9.60427 0.395728 10.3957 0.883884 10.8839Z',
		]
		viewbox: '0 0 16 16'
		width:   w
		height:  h
		color:   gx.rgb(246, 174, 172)
	)

	p.add_child(svg_a)
	p.add_child(svg_b)
	p.add_child(svg_c)
	p.add_child(svg_d)
	p.add_child(svg_e)
	p.add_child(svg_f)
	p.add_child(svg_g)
	p.add_child(svg_h)
	p.add_child(svg_i)

	mut svg_letter := svg.Svg.new(
		paths:   [
			// 'M 123 668 L 684 671 L 602 545 L 384 284 L 192 56.7 L 173 34.6 L 274 9.45 L 384 6.3 L 709 25.2'
			//'M 110 671 L 372 31.5 L 450 211 L 598 551 L 639 510 L 709 400 L 819 176 L 895 34.6 L 945 176 L 989 369 L 1039.5 662'
			'M 561 592 L 356 583 L 246 558 L 151 510 L 110 460 L 107 413 L 135 365 L 205 346 L 384 346 L 510 359 L 583 340 L 598 299 L 583 252 L 504 205 L 419 161 L 296 139 L 154 132 M 318 816 L 387 -53.5',
		]
		viewbox: '0 0 900 900'
		width:   w
		height:  h
	)

	p.add_child(svg_letter)

	mut btn := make_svg_button()

	p.add_child(btn)

	p.set_bounds(0, 0, 200, 200)

	return p
}

// A Button with a SVG icon
fn make_svg_button() &ui.Button {
	// Image Resize
	mut svg_j := svg.Svg.new(
		paths:        [
			'M1 12C1 10.3431 2.34315 9 4 9H12C13.6569 9 15 10.3431 15 12V20C15 21.6569 13.6569 23 12 23H4C2.34315 23 1 21.6569 1 20V12ZM4 10C2.89543 10 2 10.8954 2 12V20C2 20.3709 2.10096 20.7182 2.27691 21.016L6.05545 17.2374C7.1294 16.1635 8.8706 16.1635 9.94454 17.2374L13.7231 21.016C13.899 20.7182 14 20.3709 14 20V12C14 10.8954 13.1046 10 12 10H4ZM4 22C3.6291 22 3.28177 21.899 2.98402 21.7231L6.76256 17.9445C7.44598 17.2611 8.55402 17.2611 9.23744 17.9445L13.016 21.7231C12.7182 21.899 12.3709 22 12 22H4',
			'M17.5 1C17.2239 1 17 1.22386 17 1.5C17 1.77614 17.2239 2 17.5 2H21.2929L16.1464 7.14645C15.9512 7.34171 15.9512 7.65829 16.1464 7.85355C16.3417 8.04882 16.6583 8.04882 16.8536 7.85355L22 2.70711V6.5C22 6.77614 22.2239 7 22.5 7C22.7761 7 23 6.77614 23 6.5V2C23 1.44772 22.5523 1 22 1H17.5Z',
			'M2 4C2 2.89543 2.89543 2 4 2H6.5C6.77614 2 7 1.77614 7 1.5C7 1.22386 6.77614 1 6.5 1H4C2.34315 1 1 2.34315 1 4V6.5C1 6.77614 1.22386 7 1.5 7C1.77614 7 2 6.77614 2 6.5V4Z',
			'M23 17.5C23 17.2239 22.7761 17 22.5 17C22.2239 17 22 17.2239 22 17.5V20C22 21.1046 21.1046 22 20 22H17.5C17.2239 22 17 22.2239 17 22.5C17 22.7761 17.2239 23 17.5 23H20C21.6569 23 23 21.6569 23 20V17.5Z',
			'M22.5 9C22.7761 9 23 9.22386 23 9.5V14.5C23 14.7761 22.7761 15 22.5 15C22.2239 15 22 14.7761 22 14.5V9.5C22 9.22386 22.2239 9 22.5 9Z',
			'M9.5 1C9.22386 1 9 1.22386 9 1.5C9 1.77614 9.22386 2 9.5 2H14.5C14.7761 2 15 1.77614 15 1.5C15 1.22386 14.7761 1 14.5 1H9.5Z',
			'M11 14C11.5523 14 12 13.5523 12 13C12 12.4477 11.5523 12 11 12C10.4477 12 10 12.4477 10 13C10 13.5523 10.4477 14 11 14Z',
		]
		viewbox:      '0 0 24 24'
		width:        32
		height:       32
		accent_first: 2
	)

	mut btn := ui.Button.new(
		text:     'Button with SVG'
		on_click: fn (e &ui.MouseEvent) {
			// Button click!
			// dump('on click')
		}
	)
	btn.add_child(svg_j)
	return btn
}

/*
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
*/
