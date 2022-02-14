import gg
import iui as ui { debug }
import time
import os
import math
import gx

fn main() {
	// Create Window
	mut window := ui.window(ui.theme_dark(), 'Vlants vs Vombies', 800, 600)

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)

	mut help := ui.menuitem('Help')
	mut theme_menu := ui.menuitem('Theme')
	mut about := ui.menuitem('About iUI')

	mut themes := [ui.theme_default(), ui.theme_dark(), ui.theme_minty()]
	for theme2 in themes {
		mut item := ui.menuitem(theme2.name)
		item.set_click(theme_click)
		theme_menu.add_child(item)
	}

	help.add_child(about)
    window.bar.add_child(theme_menu)
	window.bar.add_child(help)

	mut v_img := window.gg.create_image(os.resource_abs_path('mainBG.png'))
	mut img := ui.image(window, v_img)
	img.set_bounds(0, 20, 800, 580)
	img.z_index = -2
	window.add_child(img)

	create_card(mut window, 'card_sunflower.png', 0)
	create_card(mut window, 'card_wallnut.png', 1)
	create_card(mut window, 'card_peashooter.png', 2)
	create_card(mut window, 'card_repeater.png', 3)

	window.gg.run()
}

fn create_card(mut window ui.Window, name string, x int) {
	mut s_img := window.gg.create_image(os.resource_abs_path('cards/' + name))
	mut card_sun := ui.image(window, s_img)
    card_sun.draw_event_fn = card_draw
	card_sun.set_bounds(90 + (65 * x), 25, 57, 80)

	window.add_child(card_sun)
}

fn card_draw(mut win ui.Window, com &ui.Component) {
    mut this := *com
    if this.is_mouse_rele {
        println('HELLO')
        this.is_mouse_rele = false
    }
}

// card_sunflower.png
fn new_image(mut win ui.Window, path string) &ui.Image {
	return ui.image(win, win.gg.create_image(os.resource_abs_path(path)))
}

fn overlap(a ui.Component, b ui.Component) bool {
	mut x_a := a.x + (a.width / 2)
	mut b_x := b.x + (b.width / 2)

	mut y_a := a.y + (a.height / 2)
	mut y_b := b.y + (b.height / 2)

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