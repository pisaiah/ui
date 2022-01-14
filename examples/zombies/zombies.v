import gg
import iui as ui { debug }
import time
import os
import math
import gx

[console]
fn main() {
	// Create Window
	mut window := ui.window(my_theme(), 'Vlants vs Vombies', 800, 600)

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)

	mut help := ui.menuitem('Help')
	mut theme_menu := ui.menuitem('Themes')
	mut about := ui.menuitem('About iUI')

	for i := 0; i < 3; i++ {
		mut item := ui.menuitem('Item ' + i.str())
		help.add_child(item)
	}

	mut themes := [ui.theme_default(), ui.theme_dark(), ui.theme_dark_hc(),
		ui.theme_black_red(), ui.theme_minty()]
	for theme2 in themes {
		mut item := ui.menuitem(theme2.name)
		item.set_click(theme_click)
		theme_menu.add_child(item)
	}

	help.add_child(about)
	window.bar.add_child(help)
	window.bar.add_child(theme_menu)

    mut v_img := window.gg.create_image(os.resource_abs_path('mainBG.png'))
	mut img := ui.image(window, v_img)
	img.set_bounds(0,20, 800, 580)
	img.z_index = -2
	window.add_child(img)

	create_card(mut window, 'card_sunflower.png',  0)
	create_card(mut window, 'card_wallnut.png',    1)
	create_card(mut window, 'card_peashooter.png', 2)
	create_card(mut window, 'card_repeater.png',   3)

    //println(overlap(img, btn))

	window.gg.run()
}

fn create_card(mut window ui.Window, name string, x int) {
    mut btn := ui.button(window, ' ')
	btn.set_click(btn_click)
	btn.set_bounds(90 + (65 * x), 25, 57, 80)
	btn.set_click(fn (mut win ui.Window, com ui.Button) {
        println('on_click ' + com.x.str())
    })

	window.add_child(btn)
    
    mut s_img := window.gg.create_image(os.resource_abs_path('cards/' + name))
	mut card_sun := ui.image(window, s_img)
    card_sun.set_bounds(90 + (65 * x),25, 57, 80)

    window.add_child(card_sun)
}

// card_sunflower.png
fn new_image(mut win ui.Window, path string) ui.Image {
    return ui.image(win, win.gg.create_image(os.resource_abs_path(path)) )
}

fn overlap(a ui.Component, b ui.Component) bool {
    mut x_a := a.x + (a.width/2)
    mut b_x := b.x + (b.width/2)
    
    mut y_a := a.y + (a.height/2)
    mut y_b := b.y + (b.height/2)
    
    if math.abs(x_a - b_x) < a.width {
        return true
    }
    
    if math.abs(y_a - y_b) < a.height {
        return true
    }
    return false
}

fn on_click(mut win ui.Window, com ui.Button) {
	debug('on_click')
}

fn theme_click(mut win ui.Window, com ui.MenuItem) {
	text := com.text
	debug(text)
	theme := ui.theme_by_name(text)
	win.set_theme(theme)
}

fn btn_click(mut win ui.Window, com ui.Button) {
	debug('btn click')
}


//
//	Custom Theme
//
pub fn my_theme() ui.Theme {
	return ui.Theme{
		name: 'Custom'
		text_color: gx.rgb(240, 240, 240)
		background: gx.rgb(50, 50, 50)
		button_bg_normal: gx.rgba(10, 10, 10,0)
		button_bg_hover: gx.rgba(70, 70, 70,0)
		button_bg_click: gx.rgba(50, 50, 50, 1)
		button_border_normal: gx.rgba(130, 130, 130,0)
		button_border_hover: gx.rgba(0, 120, 215,0)
		button_border_click: gx.rgb(0, 84, 153)
		menubar_background: gx.rgb(60, 60, 60)
		menubar_border: gx.rgb(10, 10, 10)
		dropdown_background: gx.rgb(10, 10, 10)
		dropdown_border: gx.rgb(0, 0, 0)
		textbox_background: gx.rgb(10, 10, 10)
		textbox_border: gx.rgb(130, 130, 130)
		checkbox_selected: gx.rgb(130, 130, 130)
		checkbox_bg: gx.rgb(5, 5, 5)
		progressbar_fill: gx.rgb(130, 130, 130)
		scroll_track_color: gx.rgb(0, 0, 0)
		scroll_bar_color: gx.rgb(180, 180, 180)
	}
}