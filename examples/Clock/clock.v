module main

import iui as ui
import gx
import time
import math

fn main() {
	mut win := ui.Window.new(
		title:  'Clock'
		width:  240
		height: 280
	)
	win.set_theme(ui.theme_dark())

	mut top := ui.Panel.new()

	mut switch := ui.Switch.new(
		text: 'Smooth'
	)

	mut select_box := ui.Selectbox.new(
		text:  'Arabic'
		items: [
			'Arabic',
			'Roman',
			'Binary',
		]
	)

	switch.set_bounds(0, 0, 0, 20)
	select_box.set_bounds(0, 0, 0, 20)

	top.set_bounds(0, 0, 500, 30)
	top.add_child(switch)
	top.add_child(select_box)

	mut p := ui.Panel.new(
		layout: ui.BorderLayout.new()
	)

	mut clock := &ClockComponent{
		x: 0
	}
	switch.bind_to(&clock.smooth)
	select_box.subscribe_event('item_change', clock.box_change_fn)

	switch.subscribe_event('change', fn [mut clock] (mut e ui.SwitchEvent) {
		clock.smooth = e.target.is_selected
	})

	p.add_child(clock, value: ui.borderlayout_center)
	p.add_child(top, value: ui.borderlayout_south)

	win.add_child(p)

	win.gg.run()
}

fn (mut this ClockComponent) box_change_fn(mut e ui.ItemChangeEvent) {
	num := NumberType.from_string(e.target.text.to_lower())

	if num != none {
		this.number_type = num
	}
}

enum NumberType {
	arabic
	roman
	binary
}

// Our custom component
@[heap]
struct ClockComponent {
	ui.Component_A
mut:
	size        int = 100
	number_type NumberType
	smooth      bool = true
}

const roman = ['XII', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI']
const binary = ['1100', '001', '0010', '0011', '0100', '0101', '0110', '0111', '1000', '1001',
	'1010', '1011']

fn (mut this ClockComponent) get_num(i int) string {
	match this.number_type {
		.arabic {
			if i == 0 {
				return '12'
			}
			return '${i}'
		}
		.roman {
			return roman[i]
		}
		.binary {
			return binary[i]
		}
	}
}

fn (mut this ClockComponent) draw_nums(ctx &ui.GraphicsContext, i int) {
	angle := math.radians((15 - (i * 5)) * 6)
	lx := int(math.cos(angle) * 100)
	ly := int(math.sin(angle) * 100)

	x := this.x + (this.width / 2)
	y := this.y + (this.height / 2)

	txt := this.get_num(i)
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

	if this.smooth {
		mili := second + (f32(now.nanosecond / 1000000) / 1000)
		this.draw_line(ctx, (15 - mili) * 6, 100, gx.red)
	} else {
		this.draw_line(ctx, (15 - second) * 6, 95, gx.red)
	}
	this.draw_line(ctx, (15 - minute) * 6, 90, gx.yellow)
	this.draw_line(ctx, (15 - (hour * 5)) * 6, 60, gx.white)

	for i in 0 .. 12 {
		this.draw_nums(ctx, i)
	}
}

fn (mut this ClockComponent) draw_line(ctx &ui.GraphicsContext, deg f64, mult int, c gx.Color) {
	angle := math.radians(deg)
	lx := int(math.cos(angle) * mult)
	ly := int(math.sin(angle) * mult)

	x := this.x + (this.width / 2)
	y := this.y + (this.height / 2)

	ctx.gg.draw_line(x, y, x + lx, y - ly, c)
}
