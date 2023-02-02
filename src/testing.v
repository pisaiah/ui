/**
 * GGTextbox - Version 1.0
 *
 * Copyright (C) 2023 Isaiah. All Rights Reserved.
 *
 * A Textbox component.
 * - Type in text
*/

module iui

import gg
import gx

pub struct Textbox {
	Component_A
pub mut:
	lines                []string
	caret_x              int
	caret_y              int
	fs                   int
	blink                bool
	keys                 []string
	sel                  Selection
	reset_sel            bool
	px                   int
	last_letter          string
	click_event_fn       fn (voidptr, voidptr)
	before_txtc_event_fn fn (mut Window, Textbox) bool
	text_change_event_fn fn (voidptr, voidptr)
	line_draw_event_fn   fn (voidptr, int, int, int)
	ctrl_down            bool
}

// Text Selection
struct Selection {
mut:
	x0 int = -1
	y0 int = -1
	x1 int = -1
	y1 int = -1
}

pub fn text_box(lines []string) &Textbox {
	return &Textbox{
		lines: lines
		sel: Selection{
			x0: -1
		}
		click_event_fn: fn (a voidptr, b voidptr) {}
		before_txtc_event_fn: fn (mut a Window, b Textbox) bool {
			return false
		}
		text_change_event_fn: fn (a voidptr, b voidptr) {}
		line_draw_event_fn: fn (a voidptr, b int, c int, d int) {}
	}
}

fn (mut this Textbox) draw_line_numbers(ctx &GraphicsContext, lh int) {
	wid := ctx.text_width('12345')
	this.px = wid
	ctx.gg.draw_rect_filled(this.x, this.y, this.px - 4, this.height, ctx.theme.button_bg_normal)
	sy := this.y + 2

	cfg := gx.TextCfg{
		size: ctx.font_size
		color: ctx.theme.text_color
	}

	for i, _ in this.lines {
		y := sy + (i * lh)

		if this.parent != unsafe { nil } {
			if y < this.parent.y - lh {
				continue
			}
		}

		ctx.gg.draw_text(this.x + 2, y, '${i + 1}', cfg)

		if y > this.y + this.height {
			break
		}

		if this.parent != unsafe { nil } {
			if y > this.parent.y + this.parent.height {
				break
			}
		}
	}
}

fn (mut this Textbox) draw_bg(ctx &GraphicsContext) {
	ctx.gg.draw_rect_filled(this.x, this.y, this.width, this.height, ctx.theme.textbox_background)
	ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, ctx.theme.textbox_border)
}

fn (mut this Textbox) draw(ctx &GraphicsContext) {
	if this.keys.len == 0 {
		this.keys << iui.blue_keys
		this.keys << iui.purp_keys
		this.keys << iui.numbers
		this.keys << iui.keys
		this.keys << iui.red_keys
		this.keys << iui.colors
	}

	this.draw_bg(ctx)

	if ctx.win.second_pass == 1 {
		this.blink = !this.blink
	}

	cfg := gx.TextCfg{
		color: ctx.theme.text_color
		size: ctx.win.font_size + this.fs
	}
	ctx.gg.set_text_cfg(cfg)

	th := ctx.gg.text_height('A1!|{}j;') + 4
	this.draw_line_numbers(ctx, th)

	ctx.gg.scissor_rect(this.x, this.y, this.width, this.height)

	if this.caret_x < 0 {
		this.caret_y -= 1
		this.caret_x = this.lines[this.caret_y].len
	}

	if this.parent != unsafe { nil } {
		ctx.gg.scissor_rect(this.parent.x, this.parent.y, this.parent.width, this.parent.height)
		nh := (this.lines.len + 1) * th
		if nh != this.height {
			this.height = nh
		}
	}

	mut y := this.y
	x := this.x + this.px
	for i, line in this.lines {
		if this.parent != unsafe { nil } {
			if y < this.parent.y - th {
				y += th
				continue
			}
		}
		this.draw_text(x, y + 2, line, cfg, ctx)

		if i == this.caret_y {
			if this.caret_x > line.len {
				this.caret_y += 1
				this.caret_x = 0
			}

			wb := ctx.text_width(line[0..this.caret_x].replace('\t', tabr()))

			tc := ctx.theme.text_color
			color := if this.blink {
				gx.rgba(tc.r, tc.g, tc.b, 70)
			} else {
				tc
			}

			ctx.gg.draw_rect_empty(x + wb, y, 1, th, color)
		}
		y += th
		if y > this.y + this.height {
			break
		}

		if this.parent != unsafe { nil } {
			if y > this.parent.y + this.parent.height {
				break
			}
		}
	}

	if this.is_mouse_down && !this.is_mouse_rele {
		if this.reset_sel {
			this.sel = Selection{
				x0: -1
			}
			this.reset_sel = false
		}
		this.do_mouse_down(ctx, th)
	}

	if this.reset_sel {
		this.draw_selection(ctx, th)
	}

	if this.is_mouse_rele {
		// this.reset_sel = true
		// this.is_mouse_rele = false
	}

	// Detect Click
	if this.is_mouse_rele {
		if !this.is_selected {
			// bg = ctx.theme.button_bg_click
			// border = ctx.theme.button_border_click
		}
		this.reset_sel = true
		this.is_selected = true

		this.click_event_fn(ctx.win, this)
		this.is_mouse_rele = false
	} else {
		/*
		if this.win.click_x > -1 && !(abs(mid - this.win.mouse_x) < (this.width / 2)
			&& abs(midy - this.win.mouse_y) < (this.height / 2)) {
			this.is_selected = false
		}*/
	}

	ws := ctx.gg.window_size()

	ctx.gg.scissor_rect(0, 0, ws.width, ws.height)
}

fn (mut this Textbox) draw_text(x int, y int, line string, cfg gx.TextCfg, ctx &GraphicsContext) {
	matc := make_match(line, this.keys)

	mut xx := x
	mut color := cfg.color
	mut comment := false
	mut is_str := false

	for str in matc {
		if str == '\t' {
			xx += ctx.text_width(tabr())
			continue
		}
		color = cfg.color

		if str in iui.colors {
			color = gx.color_from_string(str)
		}

		if str in iui.numbers {
			color = gx.orange
		}
		if str in iui.blue_keys {
			color = gx.rgb(51, 153, 255)
		}
		if str in iui.red_keys {
			color = gx.red
		}

		if str in iui.purp_keys {
			color = gx.rgb(190, 40, 250)
		}

		if str == "'" {
			is_str = !is_str
			color = gx.rgb(205, 145, 120)
		}
		if is_str {
			color = gx.rgb(205, 145, 120)
		}

		if str == '/*' && !is_str {
			// this.ml_comment = true
		}

		//|| this.ml_comment
		if str == '// ' || comment {
			color = gx.rgb(0, 200, 0)
			comment = true
		}

		if str == '*/' {
			// this.ml_comment = false
		}

		if cfg.color != color {
			cfg1 := gx.TextCfg{
				color: color
				size: cfg.size
			}
			ctx.draw_text(xx, y + 2, str, ctx.font, cfg1)
		} else {
			ctx.draw_text(xx, y + 2, str, ctx.font, cfg)
		}
		xx += ctx.text_width(str)
	}
}

fn tabr() string {
	return ' '.repeat(8)
}

fn (mut this Textbox) do_mouse_down(ctx &GraphicsContext, th int) {
	my := ctx.win.mouse_y - this.y
	mx := ctx.win.mouse_x - (this.x + this.px)
	cy := my / th
	if cy < this.lines.len && cy > -1 {
		this.caret_y = cy
	}

	line := this.lines[this.caret_y]

	mut lx := -100
	mut lv := 0

	for i in 0 .. line.len {
		wb := ctx.text_width(line[0..i].replace('\t', tabr()))
		dx := mx - wb
		if dx > 0 {
			if lx == -100 || dx < lx {
				lx = dx
				lv = i
			}
		}
	}

	full := ctx.text_width(line.replace('\t', tabr()))
	if mx > full {
		lv = line.len
	}

	if this.sel.x0 == -1 {
		this.sel.x0 = lv
		this.sel.y0 = cy
	} else {
		this.sel.x1 = lv
		this.sel.y1 = cy
		this.draw_selection(ctx, th)
	}

	this.caret_x = lv
}

fn (mut this Textbox) draw_selection(ctx &GraphicsContext, th int) {
	if this.sel.x0 == -1 || this.sel.x1 == -1 || this.sel.y1 == -1 {
		return
	}

	color := gx.rgba(0, 120, 215, 100)

	if this.sel.y1 > this.sel.y0 {
		// Moving Down
		this.draw_high(ctx, th, color, this.sel.y0, this.sel.y1, this.sel.x0, this.sel.x1)
	}

	if this.sel.y1 < this.sel.y0 {
		// Moving Up
		this.draw_high(ctx, th, color, this.sel.y1, this.sel.y0, this.sel.x1, this.sel.x0)
	}

	if this.sel.y0 == this.sel.y1 {
		// Same Line
		y := this.sel.y0
		minx := if this.sel.x0 > this.sel.x1 { this.sel.x1 } else { this.sel.x0 }
		maxx := if this.sel.x0 > this.sel.x1 { this.sel.x0 } else { this.sel.x1 }

		if maxx > this.lines[y].len {
			return
		}

		wba := ctx.text_width(this.lines[y][0..minx].replace('\t', tabr()))
		wbb := ctx.text_width(this.lines[y][minx..maxx].replace('\t', tabr()))
		x := this.x + this.px
		ctx.gg.draw_rect_filled(x + wba, this.y + (th * y), wbb, th, color)
	}
}

fn (mut this Textbox) draw_high(ctx &GraphicsContext, th int, color gx.Color, ya int, yb int, x0 int, x1 int) {
	y0 := if ya < 0 { 0 } else { ya }
	ll := this.lines.len
	y1 := if yb > ll { ll } else { yb }
	x := this.x + this.px

	wba0 := ctx.text_width(this.lines[y0][0..x0].replace('\t', tabr()))
	wbb0 := ctx.text_width(this.lines[y0][x0..].replace('\t', tabr()))
	ctx.gg.draw_rect_filled(x + wba0, this.y + (th * y0), wbb0, th, color)

	for y in y0 + 1 .. y1 {
		wba := ctx.text_width(this.lines[y].replace('\t', tabr()))
		ctx.gg.draw_rect_filled(x, this.y + (th * y), wba, th, color)
	}

	if y1 >= this.lines.len {
		return
	}

	wba1 := ctx.text_width(this.lines[y1][0..x1].replace('\t', tabr()))
	ctx.gg.draw_rect_filled(x, this.y + (th * y1), wba1, th, color)
}

// Delete current line; Moving text to above line if necessary.
// Usages: Backspace on empty line or backspace when caret_x == 0
pub fn (mut this Textbox) delete_current_line() {
	this.lines.delete(this.caret_y)
	this.caret_y -= 1
	this.caret_x = this.lines[this.caret_y].len
}

// Key Down stuff:

fn (mut win Window) textbox_key_down(key gg.KeyCode, ev &gg.Event, mut com Textbox) {
	if !com.is_selected {
		return
	}
	if key == .right {
		com.caret_x += 1
	} else if key == .left {
		com.caret_x -= 1
	} else if key == .up {
		if com.caret_y > 0 {
			com.caret_y -= 1
		}
	} else if key == .down {
		if com.caret_y < com.lines.len - 1 {
			com.caret_y += 1
		}
	} else {
		mod := ev.modifiers
		if mod == 8 {
			// Windows Key
			return
		}
		if mod == 2 {
			com.ctrl_down = true
		}

		if key == .backspace {
			line := com.lines[com.caret_y]

			com.last_letter = 'backspace'
			mut bevnt := com.before_txtc_event_fn(mut win, *com)
			if bevnt {
				// 'true' indicates cancel event
				return
			}

			if com.caret_x == 0 && com.caret_y == 0 {
				return
			}

			if com.caret_x - 1 >= 0 {
				new_line := line.substr(0, com.caret_x - 1) + line.substr(com.caret_x, line.len)
				com.lines[com.caret_y] = new_line
				com.caret_x -= 1
			} else {
				// EOL
				line_text := line
				com.delete_current_line()
				com.lines[com.caret_y] = com.lines[com.caret_y] + line_text
			}
		} else {
			win.textbox_key_down_typed(key, ev, mut com)
		}
	}
}

fn (mut win Window) textbox_key_down_typed(key gg.KeyCode, ev &gg.Event, mut com Textbox) {
	mod := ev.modifiers

	mut enter := is_enter(key)

	if key == .left_shift || key == .right_shift {
		win.shift_pressed = true
		return
	}

	mut letter := ''

	if ev.typ == .char {
		resu := utf32_to_str(ev.char_code)
		letter = resu
		com.last_letter = letter
	}

	$if emscripten ? {
		if ev.typ == .char && ev.char_code == 13 {
			enter = true
		}
	}

	if key == .tab {
		// resu = '\t'
		letter = '\t'
		com.last_letter = '\t'
	}

	if enter {
		com.last_letter = 'enter'
	}

	bevnt := com.before_txtc_event_fn(mut win, *com)
	if bevnt {
		// 'true' indicates cancel event
		return
	}

	if !enter && mod != 2 {
		if com.lines.len == 0 {
			com.lines << ' '
			com.caret_y = 0
		}

		line := com.lines[com.caret_y]

		if letter.len > 1 {
			// For extended unicode
			mut myrunes := line.runes()
			myrunes.insert(com.caret_x, letter.runes()[0])
			com.lines[com.caret_y] = myrunes.string()
			unsafe {
				myrunes.free()
			}
		} else {
			new_line := line.substr_ni(0, com.caret_x) + letter +
				line.substr_ni(com.caret_x, line.len)
			com.lines[com.caret_y] = new_line
		}
	}

	com.last_letter = letter
	com.text_change_event_fn(win, com)

	if enter {
		current_line := com.lines[com.caret_y]
		if com.caret_x == current_line.len && current_line.len > 1 {
			com.lines.insert(com.caret_y, '')
			com.caret_y += 1
			if current_line.starts_with('\t') {
				com.lines[com.caret_y] = '\t'
			}
		} else {
			keep_line := current_line.substr(0, com.caret_x)
			new_line := current_line.substr_ni(com.caret_x, current_line.len)

			com.lines[com.caret_y] = keep_line

			com.caret_y += 1
			com.lines.insert(com.caret_y, '')
			com.lines[com.caret_y] = new_line
			com.caret_x = 0
		}
	} else if mod != 2 {
		if letter.len > 0 {
			com.caret_x += 1
		}
	}
}
