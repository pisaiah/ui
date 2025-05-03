module main

import iui as ui
import iui.themes
import gx
import time
import math
import gg

struct App {
mut:
	fps    f32
	frames f32
	ls     f32
	lp     int
	angle  f32
}

struct CubeComponent {
	ui.Component_A
mut:
	angle f32
	rotat f32
}

fn (mut cube CubeComponent) draw(g &ui.GraphicsContext) {
	cube.angle += 0.01
	cube.rotat += 1
	// }

	//  fn (app &App) draw_cube() {
	size := 100.0
	points := [
		[-size, -size, -size],
		[size, -size, -size],
		[size, size, -size],
		[-size, size, -size],
		[-size, -size, size],
		[size, -size, size],
		[size, size, size],
		[-size, size, size],
	]

	mut transformed_points := []f32{}
	for point in points {
		x := point[0]
		y := point[1]
		z := point[2]

		// Rotate around Y axis
		new_x := x * math.cos(cube.angle) - z * math.sin(cube.angle)
		mut new_z := x * math.sin(cube.angle) + z * math.cos(cube.angle)

		// Rotate around X axis
		new_y := y * math.cos(cube.angle) - new_z * math.sin(cube.angle)
		new_z = y * math.sin(cube.angle) + new_z * math.cos(cube.angle)

		transformed_points << f32(new_x)
		transformed_points << f32(new_y)
		transformed_points << f32(new_z)
	}

	// Draw edges
	edges := [
		[0, 1],
		[1, 2],
		[2, 3],
		[3, 0],
		[4, 5],
		[5, 6],
		[6, 7],
		[7, 4],
		[0, 4],
		[1, 5],
		[2, 6],
		[3, 7],
	]

	ws := g.win.get_size()

	for edge in edges {
		p1 := edge[0] * 3
		p2 := edge[1] * 3
		g.gg.draw_line(transformed_points[p1] + ws.width / 2, transformed_points[p1 + 1] +
			ws.height / 2, transformed_points[p2] + ws.width / 2, transformed_points[p2 + 1] +
			ws.height / 2, g.theme.accent_fill)
	}

	// Draw filled faces
	/*
    faces := [
        [0, 1, 2, 3], [4, 5, 6, 7], // Front and back faces
        [0, 1, 5, 4], [2, 3, 7, 6], // Top and bottom faces
        [0, 3, 7, 4], [1, 2, 6, 5], // Left and right faces
    ]

    for face in faces {
        p1 := face[0] * 3
        p2 := face[1] * 3
        p3 := face[2] * 3
        p4 := face[3] * 3
        g.gg.draw_polygon_filled([
            transformed_points[p1] + ws.width / 2, transformed_points[p1 + 1] + ws.height / 2,
            transformed_points[p2] + ws.width / 2, transformed_points[p2 + 1] + ws.height / 2,
            transformed_points[p3] + ws.width / 2, transformed_points[p3 + 1] + ws.height / 2,
            transformed_points[p4] + ws.width / 2, transformed_points[p4 + 1] + ws.height / 2,
        ], gx.black)
    }
	*/

	g.gg.draw_polygon_filled(ws.width / 2, ws.height / 2, 32, 4, cube.rotat, gx.black)
}

fn main() {
	mut win := ui.Window.new(
		title:  'Test'
		width:  240
		height: 280
	)
	win.set_theme(themes.theme_dark_rgb())

	mut top := ui.Panel.new()

	mut switch := ui.Switch.new(
		text: 'Smooth'
	)
	switch.set_bounds(0, 0, 200, 20)
	top.set_bounds(0, 0, 200, 30)
	top.add_child(switch)

	mut p := ui.Panel.new(
		layout: ui.BorderLayout.new()
	)

	mut clock := &ClockComponent{
		x:   0
		app: &App{}
	}
	switch.bind_to(&clock.smooth)

	switch.subscribe_event('change', fn [mut clock] (mut e ui.SwitchEvent) {
		clock.smooth = e.target.is_selected
	})

	mut cube := &CubeComponent{}

	p.add_child_with_flag(cube, ui.borderlayout_center)
	p.add_child_with_flag(top, ui.borderlayout_south)

	win.add_child(p)

	win.gg.run()
}

// Our custom component
struct ClockComponent {
	ui.Component_A
mut:
	size   int  = 100
	smooth bool = true
	app    &App
}

fn (mut this ClockComponent) draw_nums(ctx &ui.GraphicsContext, i int) {
	angle := math.radians((15 - (i * 5)) * 6)
	lx := int(math.cos(angle) * 100)
	ly := int(math.sin(angle) * 100)

	x := this.x + (this.width / 2)
	y := this.y + (this.height / 2)

	txt := '${i}'
	tw := ctx.text_width(txt)

	ctx.draw_text(x + lx - (tw / 2), y - ly - (ctx.line_height / 2), txt, ctx.font, gx.TextCfg{
		color: ctx.theme.text_color
	})
}

fn (mut this ClockComponent) draw(ctx &ui.GraphicsContext) {
	x := this.x + (this.width / 2) - this.size
	y := this.y + (this.height / 2) - this.size

	ctx.gg.draw_circle_empty(x + this.size, y + this.size, this.size, gx.gray)

	now := time.now()

	hour := now.hour + (f32(now.minute) / 60)
	minute := now.minute + (f32(now.second) / 60)
	second := now.second

	if second > this.app.ls {
		this.app.fps = this.app.frames
		this.app.frames = 0
		this.app.ls = second
	}

	this.app.lp += 1

	if this.app.lp > 60 {
		this.app.lp = 0
	}

	this.app.frames += 1

	if this.smooth {
		mili := second + (f32(now.nanosecond / 1000000) / 1000)
		this.draw_line(ctx, (15 - mili) * 8, 100, gx.red)
	} else {
		this.draw_line(ctx, (15 - second) * 6, 95, gx.red)
	}
	this.draw_line(ctx, (15 - minute) * 6, 90, gx.yellow)
	this.draw_line(ctx, (15 - (hour * 5)) * 6, 60, gx.white)

	for _ in 0 .. 10 {
		this.draw_line(ctx, (15 - this.app.lp) * 6, 100, gx.red)
	}

	xt := this.x + (this.width / 2)
	yt := this.y + (this.height / 2)

	txt := '${this.app.fps} / ${this.app.frames}'
	tw := ctx.text_width(txt)

	ctx.draw_text(xt - (tw / 2), yt - (ctx.line_height / 2), txt, ctx.font, gx.TextCfg{
		color: ctx.theme.text_color
	})
}

fn (mut this ClockComponent) draw_line(ctx &ui.GraphicsContext, deg f64, mult int, c gx.Color) {
	angle := math.radians(deg)
	lx := int(math.cos(angle) * mult)
	ly := int(math.sin(angle) * mult)

	x := this.x + (this.width / 2)
	y := this.y + (this.height / 2)

	ctx.gg.draw_line(x, y, x + lx, y - ly, c)
}
