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
[heap]
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
	fps	 int
	fpss	int
	theme   Theme
    bar     Menubar
    show_menu_bar bool = true
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
    
    app.bar = menubar(app, app.theme)
	app.bar.items << menuitem('File')
	app.bar.items << menuitem('Edit')
    
    mut help := menuitem('Help')
    mut about := menuitem('About')
    
    for i := 0; i < 5; i++ {
        mut item := menuitem('Item ' + i.str())
        help.items << item
    }
    
    help.items << about
    app.bar.items << help

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
    
    mut appp := *(app)

    if app.show_menu_bar {
        mut bar := appp.get_bar()
        bar.draw()
    }

	//app.bar.draw()
	//app.draw_menu_bar()

    //app.draw_bordered_rect(50, 23, 70, 50, 2, app.theme.dropdown_background, app.theme.dropdown_border)
}

fn (mut app App) get_bar() Menubar {
    return app.bar
}

fn (app &App) draw_bordered_rect(x int, y int, width int, height int, a int, bg gx.Color, bord gx.Color) {
    app.gg.draw_rounded_rect(x, y, width, height, a, bg)
	app.gg.draw_empty_rounded_rect(x, y, width, height, a, bord)
}

[heap]
struct Menubar {
mut:
	app &App
	theme Theme
	items []MenuItem
}

[heap]
struct MenuItem {
mut:
    items[] MenuItem
    text string
    shown      bool
    show_items bool
}

pub fn menuitem(text string) MenuItem {
    return MenuItem {
        text: text
        shown: false
        show_items: false
    }
}

pub fn menubar(app &App, theme Theme) Menubar {
	return Menubar{
		app: app
		theme: theme
	}
}

fn (mut mb Menubar) draw() {
	mut wid := gg.window_size().width
	mb.app.gg.draw_rounded_rect(0, 0, wid, 25, 2, mb.theme.menubar_background)
	mb.app.gg.draw_empty_rounded_rect(0, 0, wid, 25, 2, mb.theme.menubar_border)
	
	mut mult := 0
	for mut item in mb.items {
		mb.app.draw_menu_button(50*mult,0, 50, 25, mut item)
		mult++
	}
}

fn (app &App) draw_button(x int, y int, width int, height int, text string) {
    mut y1 := y
    if !app.show_menu_bar {
        y1 = y1 - 25
    }

	size := app.gg.text_width(text) / 2
	sizh := app.gg.text_height(text) / 2

	mut bg := app.theme.button_bg_normal
	mut border := app.theme.button_border_normal

	mut mid := (x + (width / 2))
	mut midy := (y1 + (height / 2))

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
	app.gg.draw_rounded_rect(x, y1, width, height, 2, bg)
	app.gg.draw_empty_rounded_rect(x, y1, width, height, 2, border)

	// Draw Button Text
	app.gg.draw_text((x + (width / 2)) - size, y1 + (height / 2) - sizh, text, gx.TextCfg{
		size: 14
		color: app.theme.text_color
	})
}

fn (app &App) draw_menu_button(x int, y int, width int, height int, mut item MenuItem) {
	size := app.gg.text_width(item.text) / 2
	sizh := app.gg.text_height(item.text) / 2

	mut bg := app.theme.menubar_background
	mut border := app.theme.menubar_border

	mut midx := (x + (width / 2))
	mut midy := (y + (height / 2))

	// Detect Hover
	if (math.abs(midx - app.mouse_x) < (width / 2)) && (math.abs(midy - app.mouse_y) < (height / 2)) {
		bg = app.theme.button_bg_hover
		border = app.theme.button_border_hover
	}

	// Detect Click
    mut clicked := ((math.abs(midx - app.click_x) < (width / 2)) && (math.abs(midy - app.click_y) < (height / 2)) ) 
	if clicked && !item.show_items {
        println( item.text )
		bg = app.theme.button_bg_click
		border = app.theme.button_border_click
        item.show_items = true
	}
    
    if item.show_items && item.items.len > 0 {
        bg = app.theme.button_bg_click
		border = app.theme.button_border_click
        wid :=  100
        app.draw_bordered_rect(x, y + height, wid, (item.items.len * 26) + 2, 2, app.theme.dropdown_background, app.theme.dropdown_border)

        mut mult := 0
        for mut sub in item.items {
            app.draw_menu_button(x + 1, y + height + mult + 1, wid - 2, 25, mut sub)
            mult += 26
        }
    } 

    if item.show_items && app.click_x != -1 && app.click_y != -1 && !clicked {
        item.show_items = false
    }

	// Draw Button Background & Border
	app.gg.draw_rounded_rect(x, y, width, height, 2, bg)
	app.gg.draw_empty_rounded_rect(x, y, width, height, 2, border)

	// Draw Button Text
	app.gg.draw_text((x + (width / 2)) - size, y + (height / 2) - sizh, item.text, gx.TextCfg{
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
        .left_alt {
            app.show_menu_bar = !app.show_menu_bar
        }
		else {}
	}
}
