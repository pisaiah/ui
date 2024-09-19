module main

import iui as ui
import gx
import time
import math

struct App {
mut:
	fps    f32
	frames f32
	ls     f32
	lp     int
}

fn main() {
	mut win := ui.Window.new(
		title:  'Test'
		width:  240
		height: 280
	)
	win.set_theme(ui.theme_seven_dark())

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

	p.add_child_with_flag(clock, ui.borderlayout_center)
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
