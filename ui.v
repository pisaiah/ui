module main

import gg
import gx
// import os
import time
import math

const (
	win_width  = 500
	win_height = 512
)


// App
struct App {
mut:
	gg &gg.Context
	// width			f64 = win_width
	// height		   f64 = win_height
	btext   string = 'Hello'
	mouse_x int
	mouse_y int
	click_x int
	click_y int
	lastt   f64
	fps     int
	fpss    int
	theme   Theme
}

fn (mut app App) start() {
}

fn (mut app App) update() {
	// time.sleep(1000 * time.millisecond)
}

[console]
fn main() {
	// mut test := $embed_file("old.exe")
	// println("LEN: ")
	// println(test.to_string().len)
	// mut comp := zlib.compress(test.to_string().bytes()) or { panic(error) }
	// println(comp.len)

	theme := theme_default()

	mut app := &App{
		gg: 0
		theme: theme
	}
	mut font_path := gg.system_font_path()
	app.gg = gg.new_context(
		bg_color: theme.background
		width: win_width
		height: win_height
		create_window: true
		window_title: 'V GG Demo'
		frame_fn: frame
		event_fn: on_event
		user_data: app
		init_fn: init_images
		font_path: font_path
		font_size: 14
	)
	app.start()
	// go app.run()
	app.gg.run()
}

fn (mut app App) run() {
}

fn init_images(mut app App) {
	/*$if android {
		background := os.read_apk_asset('img/background.png') or { panic(err) }
		app.background = app.gg.create_image_from_byte_array(background)
		bird := os.read_apk_asset('img/bird.png') or { panic(err) }
		app.bird = app.gg.create_image_from_byte_array(bird)
	} $else {
		app.background = app.gg.create_image(os.resource_abs_path('assets/img/background.png'))
		app.bird = app.gg.create_image(os.resource_abs_path('assets/img/bird.png'))
	}*/
}

fn frame(mut app App) {
	app.gg.begin()
	app.draw()
	app.gg.end()
}

fn (app &App) display() {
	// app.gg.draw_image(f32(background_x), 0, app.background.width, app.background.height, app.background)

	app.draw_button(40, 40, 100, 25, app.btext)
	app.draw_button(280, 280, 100, 25, app.btext)
	app.gg.draw_text_def(1, 1, ' (FPS: ' + int(app.fps).str() + ')')

    app.draw_menu_bar()
}

fn (app &App) draw_menu_bar() {
    mut wid := gg.window_size().width
    app.gg.draw_rounded_rect(0, 0, wid, 20, 2, app.theme.menubar_background)
    app.gg.draw_empty_rounded_rect(0, 0, wid, 25, 2, app.theme.menubar_border)
}

fn (app &App) draw_button(x int, y int, width int, height int, text string) {
	size := app.gg.text_width(text) / 2
    sizh := app.gg.text_height(text) / 2

	mut bg := app.theme.button_bg_normal
	mut border := app.theme.button_border_normal

	mut mid := (x + (width / 2))
	mut midy := (y + (height / 2))

    // Detect Hover
	if (math.abs(mid - app.mouse_x) < (width / 2)) && (math.abs(midy - app.mouse_y) < (height / 2)) {
		bg = app.theme.button_bg_hover
		border = app.theme.button_border_hover
	}

    // Detect Click
	if (math.abs(mid - app.click_x) < (width / 2)) && (math.abs(midy - app.click_y) < (height / 2)) {
		bg = app.theme.button_bg_click
		border = app.theme.button_border_click
	}

	// Draw Button Background & Border
	app.gg.draw_rounded_rect(x, y, width, height, 2, bg)
	app.gg.draw_empty_rounded_rect(x, y, width, height, 2, border)

	// Draw Button Text
	app.gg.draw_text((x + (width / 2)) - size, y + (height / 2) - sizh, text, gx.TextCfg{
		size: 14
		color: app.theme.text_color
	})
}

fn (mut app App) draw() {
	time.sleep(10 * time.millisecond) // Reduce CPU Usage

	if (time.now().unix_time_milli() - app.lastt) > 1000 {
		app.fps = app.fpss
		app.fpss = 0
		app.lastt = time.now().unix_time_milli()
	}
	app.fpss++
	app.display()
}

fn on_event(e &gg.Event, mut app App) {
	if e.typ == .mouse_move {
		app.mouse_x = int(e.mouse_x)
		app.mouse_y = int(e.mouse_y)
		app.btext = app.mouse_x.str() + ' / ' + app.mouse_y.str()
	}
	if e.typ == .mouse_down {
        app.click_x = int(e.mouse_x)
        app.click_y = int(e.mouse_y)
	}
	if e.typ == .mouse_up {
        app.click_x = -1
        app.click_y = -1
	}
	if e.typ == .key_down {
		app.key_down(e.key_code)
	}
}

fn (mut app App) key_down(key gg.KeyCode) {
	// global keys
	match key {
		.escape {
			app.gg.quit()
		}
		else {}
	}
}
