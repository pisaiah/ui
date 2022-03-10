import gg
import iui as ui { debug }
import os
import math
import gx
import time
import sokol.audio

struct App {
	version int
mut:
	selected_plant Card
	balance        int = 50
	cache          map[string]int
}

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.theme_dark(), 'Vlants vs Vombies', 800, 600)

	// App
	mut app := &App{
		version: 1
	}
	window.id_map['app'] = app

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
	img.set_bounds(0, 25, 800, 580)
	img.z_index = -2
	window.add_child(img)

	create_card(mut window, 'card_sunflower.png', 0, .sunflower, 50)
	create_card(mut window, 'card_wallnut.png', 1, .walnut, 50)
	create_card(mut window, 'card_peashooter.png', 2, .peashooter, 100)
	create_card(mut window, 'card_repeater.png', 3, .repeater, 200)

	create_grid(mut window)

	mut bal := ui.label(window, app.balance.str())
	bal.draw_event_fn = fn (mut win ui.Window, com &ui.Component) {
		mut this := *com
		mut app := &App(win.get_from_id('app'))
		this.text = app.balance.str()

		this.x = 25
		this.y = 87
		if mut this is ui.Label {
			this.need_pack = true
		}
	}
	window.add_child(bal)
	window.gg.run()
}

struct GridBox {
	ui.Component_A
mut:
	win   &ui.Window
	color gx.Color

	selected_image  int = -1
	selected_images []int
	tik             i64
}

fn (mut this GridBox) draw() {
	// this.win.draw_filled_rect(this.x, this.y, this.width, this.height, 1, this.color, this.color)
	// this.win.gg.draw_rounded_rect_empty(this.x, this.y, this.width, this.height, 1, this.color)
	if this.is_mouse_rele {
		println('click')
		mut app := &App(this.win.id_map['app'])
		mut sel := app.selected_plant

		if app.balance < sel.cost {
			this.is_mouse_rele = false
			return
		}

		app.balance -= sel.cost

		folder := os.resource_abs_path('plants/' + sel.ptype.str())

		for file in os.ls(folder) or { [-1] } {
			mut path := folder + '/' + file
			if path.ends_with('.jar') {
				continue
			}

			if path in app.cache {
				this.selected_images << app.cache[path]
			} else {
				s_img := this.win.gg.create_image(path)
				img_id := this.win.gg.cache_image(s_img)
				this.selected_images << img_id
				app.cache[path] = img_id
			}
			this.tik = time.ticks()
		}
		this.selected_image = 0

		this.is_mouse_rele = false
	}
	if this.selected_image != -1 {
		this.win.gg.draw_image_by_id(this.x + 10, this.y + 20, this.width - 15, this.height - 25,
			this.selected_images[this.selected_image])

		now := time.ticks()

		if now - this.tik > 50 {
			this.selected_image += 1
			if this.selected_image >= this.selected_images.len {
				this.selected_image = 0
			}
			this.tik = now
		}
	}
}

fn create_grid(mut win ui.Window) {
	mut dark := false

	for y in 0 .. 5 {
		for x in 0 .. 9 {
			mut box := GridBox{
				win: win
				x: 34 + (81 * x)
				y: 112 + (96 * y)
				width: 80
				height: 95
			}
			if dark {
				box.color = gx.rgb(5, 135, 25)
			} else {
				box.color = gx.rgb(5, 175, 25)
			}
			dark = !dark
			win.add_child(box)
		}
	}
}

struct Card {
	ptype PlantType
	cost  int
}

enum PlantType {
	_unknown
	peashooter
	walnut
	sunflower
	repeater
}

fn create_card(mut window ui.Window, name string, x int, ptype PlantType, cost int) {
	mut s_img := window.gg.create_image(os.resource_abs_path('cards/' + name))
	mut card_sun := ui.image(window, s_img)
	card_sun.text = ptype.str()
	card_sun.draw_event_fn = card_draw
	card_sun.set_bounds(90 + (65 * x), 25, 64, 90)

	card_data := &Card{
		ptype: ptype
		cost: cost
	}
	window.id_map[ptype.str() + '-data'] = card_data

	window.add_child(card_sun)
}

fn card_draw(mut win ui.Window, com &ui.Component) {
	mut this := *com
	if this.is_mouse_rele {
		card_data := &Card(win.id_map[com.text + '-data'])
		mut app := &App(win.id_map['app'])
		app.selected_plant = card_data

		println('HELLO: ' + com.text)
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
