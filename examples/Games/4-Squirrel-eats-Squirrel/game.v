module main

import iui as ui
import gx
import rand
import gg
import time
import math

const grass_color = gx.rgb(24, 255, 0)
const white = gx.white
const red = gx.red

const cameraslack = 90
const moverate = 9 / 2
const bouncerate = 6 / 2
const bounceheight = 30
const startsize = 25
const winsize = 300
const invulntime = 2
const gameovertime = 4
const maxhealth = 3

const numgrass = 80
const numsquirrels = 30
const squirrelminspeed = 3 / 2
const squirrelmaxspeed = 7 / 2
const dirchangefreq = 2

const left = 'left'
const right = 'right'

struct Rect {
pub:
	x      int
	y      int
	width  int
	height int
}

struct Grass {
mut:
	grass_image int
	width       int
	height      int
	x           int
	y           int
	rect        Rect
}

// [deprecated]
pub fn (mut app App) img(mut w ui.Window, b []u8, width int, h int) int {
	gg_im := w.gg.create_image_from_byte_array(b) or { panic(err) }

	return w.gg.cache_image(gg_im)

	// img.img = &gg_im
	// return img
}

pub fn draw_image(ctx &ui.GraphicsContext, id int, x int, y int, w int, h int) {
	ctx.gg.draw_image_with_config(gg.DrawImageConfig{
		img_id:   id
		img_rect: gg.Rect{
			x:      x
			y:      y
			width:  w
			height: h
		}
	})
}

@[heap]
struct App {
mut:
	imgs                    []int
	p                       &ui.Panel
	grass_objs              []Grass
	squirrel_objs           []Squirrel
	player_obj              Player
	move_left               bool
	move_right              bool
	move_up                 bool
	move_down               bool
	camerax                 int
	cameray                 int
	invulnerable_mode       bool
	invulnerable_start_time f64 = 0.0
	game_over_mode          bool
	game_over_start_time    f64 = 0.0
	win_mode                bool
	do_tick                 bool
}

// Our Player
struct Player {
mut:
	surface string
	facing  string
	size    int
	x       int
	y       int
	bounce  int
	health  int
	rect    Rect
	rbounce bool
}

// Our Squirrels
struct Squirrel {
mut:
	width        int
	height       int
	x            int
	y            int
	movex        int
	movey        int
	surface      string
	bounce       int
	bouncerate   int
	bounceheight int
	rect         Rect
}

fn (mut plr Player) cheat_size() {
	general_size := rand.int_in_range(5, 25) or { 0 }
	multiplier := rand.int_in_range(1, 3) or { 1 }
	width := (general_size + rand.int_in_range(0, 10) or { 0 }) * multiplier
	height := (general_size + rand.int_in_range(0, 10) or { 0 }) * multiplier

	plr.size += int(math.sqrt(math.pow(f64(width * height), 0.2))) + 1
}

fn Squirrel.new(camerax int, cameray int) Squirrel {
	general_size := rand.int_in_range(5, 25) or { 0 }
	multiplier := rand.int_in_range(1, 3) or { 1 }
	width := (general_size + rand.int_in_range(0, 10) or { 0 }) * multiplier
	height := (general_size + rand.int_in_range(0, 10) or { 0 }) * multiplier

	x, y := get_random_off_camera_pos(camerax, cameray, width, height)

	movex := get_random_velocity()
	movey := get_random_velocity()
	surface := if movex < 0 {
		'L_SQUIR_IMG' // Replace with actual image handling code
	} else {
		'R_SQUIR_IMG' // Replace with actual image handling code
	}
	bounce := 0

	return Squirrel{
		width:        width
		height:       height
		x:            x
		y:            y
		movex:        movex
		movey:        movey
		surface:      surface
		bounce:       bounce
		bouncerate:   rand.int_in_range(10, 18) or { 0 }
		bounceheight: rand.int_in_range(10, 50) or { 0 }
	}
}

// Placeholder functions for get_random_off_camera_pos and get_random_velocity

fn get_random_off_camera_pos(camerax int, cameray int, obj_width int, obj_height int) (int, int) {
	// create a Rect of the camera view
	camera_rect := Rect{
		x:      camerax
		y:      cameray
		width:  winwidth
		height: winheight
	}
	for {
		x := rand.int_in_range(camerax - winwidth, camerax + (2 * winwidth)) or { 0 }
		y := rand.int_in_range(cameray - winheight, cameray + (2 * winheight)) or { 0 }
		// create a Rect object with the random coordinates and use colliderect()
		// to make sure the right edge isn't in the camera view.
		obj_rect := Rect{
			x:      x
			y:      y
			width:  obj_width
			height: obj_height
		}
		if !colliderect(camera_rect, obj_rect) {
			return x, y
		}
	}
	dump('ZERO')
	return 0, 0
}

fn get_random_velocity() int {
	speed := rand.int_in_range(squirrelminspeed, squirrelmaxspeed) or { 0 }
	if rand.int_in_range(0, 2) or { 0 } == 0 {
		return speed
	} else {
		return -speed
	}
}

// TODO
const grassimages = []int{len: 4}

fn make_new_grass(camerax int, cameray int) Grass {
	grass_image := rand.int_in_range(0, grassimages.len - 1) or { 0 }
	width := 80
	height := 80
	x, y := get_random_off_camera_pos(camerax, cameray, width, height)
	rect := Rect{
		x:      x
		y:      y
		width:  80
		height: 80
	}

	return Grass{
		grass_image: grass_image
		width:       rect.width
		height:      rect.height
		x:           rect.x
		y:           rect.y
		rect:        rect
	}
}

fn is_outside_active_area_a(camerax int, cameray int, obj Squirrel) bool {
	// Return false if camerax and cameray are more than
	// a half-window length beyond the edge of the window.
	bounds_left_edge := camerax - winwidth
	bounds_top_edge := cameray - winheight
	bounds_rect := Rect{
		x:      bounds_left_edge
		y:      bounds_top_edge
		width:  winwidth * 3
		height: winheight * 3
	}
	obj_rect := Rect{
		x:      obj.x
		y:      obj.y
		width:  obj.width
		height: obj.height
	}

	val := !colliderect(bounds_rect, obj_rect)

	if val {
		dump('${bounds_rect} ${obj_rect}')
		dump(val)
	}

	return val
}

fn is_outside_active_area(camerax int, cameray int, obj Rect) bool {
	// Return false if camerax and cameray are more than
	// a half-window length beyond the edge of the window.
	bounds_left_edge := camerax - winwidth
	bounds_top_edge := cameray - winheight
	bounds_rect := Rect{
		x:      bounds_left_edge
		y:      bounds_top_edge
		width:  winwidth * 3
		height: winheight * 3
	}
	obj_rect := Rect{
		x:      obj.x
		y:      obj.y
		width:  obj.width
		height: obj.height
	}

	val := !colliderect(bounds_rect, obj_rect)

	if val {
		dump('${bounds_rect} ${obj_rect}')
		dump(val)
	}

	return val
}

fn colliderect(rect1 Rect, rect2 Rect) bool {
	return rect1.x < rect2.x + rect2.width && rect1.x + rect1.width > rect2.x
		&& rect1.y < rect2.y + rect2.height && rect1.y + rect1.height > rect2.y
}

// Constants for window dimensions
const winwidth = 800 // Example width

const winheight = 600 // Example height

const half_winwidth = winwidth / 2
const half_winheight = winheight / 2

pub fn (mut app App) iicon(mut win ui.Window, b []u8, w int, h int) &ui.Image {
	return ui.image_from_bytes(mut win, b, w, h)
}

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title:  'Squirrel eat Squirrel'
		width:  winwidth
		height: winheight
		theme:  ui.theme_dark()
		// custom_titlebar: true
	)

	// ui.set_window_fps(30)

	mut app := &App{
		p:             ui.Panel.new()
		grass_objs:    []Grass{}
		squirrel_objs: []Squirrel{}
	}

	img_0 := $embed_file('assets/squirrel.png')
	img_1 := $embed_file('assets/grass1.png')
	img_2 := $embed_file('assets/grass2.png')
	img_3 := $embed_file('assets/grass3.png')
	img_4 := $embed_file('assets/grass4.png')

	app.imgs << app.img(mut window, img_0.to_bytes(), 18, 18)
	app.imgs << app.img(mut window, img_1.to_bytes(), 80, 80)
	app.imgs << app.img(mut window, img_2.to_bytes(), 80, 80)
	app.imgs << app.img(mut window, img_3.to_bytes(), 80, 80)
	app.imgs << app.img(mut window, img_4.to_bytes(), 80, 80)

	mut bar := ui.Menubar.new()
	mut item := ui.MenuItem.new(
		text: ' '
	)
	bar.add_child(item)
	window.bar = bar

	window.add_child(app.p)

	// Start GG / Show Window

	app.run_game()

	window.subscribe_event('draw', app.win_draw_evnt)
	window.subscribe_event('key_down', app.key_down_event)
	window.subscribe_event('key_up', app.key_up_event)

	window.run()
}

fn (mut app App) key_down_event(mut e ui.WindowKeyEvent) {
	dump(e.key)

	if e.key == .p {
		// for _ in 0 .. 10 {
		app.player_obj.size = 340
		// app.player_obj.cheat_size()
		//}
	}

	if e.key in [.up, .w] {
		app.move_down = false
		app.move_up = true
	}

	if e.key in [.down, .s] {
		app.move_up = false
		app.move_down = true
	}

	if e.key in [.left, .a] {
		app.move_right = false
		app.move_left = true
	}

	if e.key in [.right, .d] {
		app.move_left = false
		app.move_right = true
	}

	// app.move_player()
}

fn (mut app App) key_up_event(mut e ui.WindowKeyEvent) {
	dump(e.key)

	if e.key in [.left, .a] {
		app.move_left = false
	}

	if e.key in [.right, .d] {
		app.move_right = false
	}

	if e.key in [.up, .w] {
		app.move_up = false
	}

	if e.key in [.down, .s] {
		app.move_down = false
	}
}

fn (mut app App) win_draw_evnt(e &ui.DrawEvent) {
	app.game_tick(e.ctx)
}

fn (mut app App) run_game() {
	// Placeholder for game text surfaces
	game_over_surf := 'Game Over'

	// Create player
	mut player_obj := Player{
		surface: 'L_SQUIR_IMG'
		facing:  'left'
		size:    startsize
		x:       half_winwidth
		y:       half_winheight
		bounce:  0
		health:  maxhealth
		rect:    Rect{}
	}

	for _ in 0 .. 10 {
		mut grass_obj := make_new_grass(app.camerax, app.cameray)
		grass_obj.x = rand.int_in_range(0, winwidth) or { 0 }
		grass_obj.y = rand.int_in_range(0, winheight) or { 0 }
		app.grass_objs << grass_obj
	}

	app.player_obj = player_obj

	// for true {
	//	app.game_tick(g)
	//}
}

fn get_bounce_amount(current_bounce int, bounce_rate int, bounce_height int) int {
	// Returns the number of pixels to offset based on the bounce.
	// Larger bounceRate means a slower bounce.
	// Larger bounceHeight means a higher bounce.
	// currentBounce will always be less than bounceRate
	return int(math.sin((math.pi / f64(bounce_rate)) * current_bounce) * bounce_height)
}

fn (mut app App) move_player() {
	if app.move_left {
		app.player_obj.x -= moverate
	}
	if app.move_right {
		app.player_obj.x += moverate
	}
	if app.move_up {
		app.player_obj.y -= moverate
	}

	if app.move_down {
		app.player_obj.y += moverate
	}

	if (app.move_left || app.move_right || app.move_up || app.move_down)
		|| app.player_obj.bounce != 0 {
		if app.player_obj.rbounce {
		} else {
			app.player_obj.bounce += 1
		}
	}

	// Smoother
	if app.player_obj.rbounce {
		app.player_obj.bounce -= 1
		if app.player_obj.bounce <= 0 {
			app.player_obj.rbounce = false
		}
	}

	if app.player_obj.bounce > bouncerate * 3 {
		app.player_obj.rbounce = true

		app.player_obj.bounce -= 1
	}
}

fn flash_is_on() bool {
	return int(math.round(time.now().unix_milli() / f64(1000.0)) * 10) % 2 == 1
}

const health_bar_y = 35

fn draw_health_meter(g &ui.GraphicsContext, current_health int) {
	for i in 0 .. current_health {
		// draw red health bars
		g.gg.draw_rect_filled(15, health_bar_y + (10 * maxhealth) - i * 10, 20, 10, gx.red)
	}
	for i in 0 .. maxhealth {
		// draw the white outlines
		g.gg.draw_rect_empty(15, health_bar_y + (10 * maxhealth) - i * 10, 20, 10, gx.white)
	}
}

fn (mut app App) game_tick(g &ui.GraphicsContext) {
	if app.invulnerable_mode && time.now().unix() - app.invulnerable_start_time > invulntime {
		app.invulnerable_mode = false
	}

	for mut s_obj in app.squirrel_objs {
		s_obj.x += s_obj.movex
		s_obj.y += s_obj.movey
		s_obj.bounce += 1
		if s_obj.bounce > s_obj.bouncerate {
			s_obj.bounce = 0
		}

		if rand.int_in_range(0, 99) or { 0 } < dirchangefreq {
			s_obj.movex = get_random_velocity()
			s_obj.movey = get_random_velocity()
			s_obj.surface = if s_obj.movex > 0 {
				'R_SQUIR_IMG'
			} else {
				'L_SQUIR_IMG'
			}
		}
	}

	for i := app.grass_objs.len - 1; i >= 0; i-- {
		if is_outside_active_area(app.camerax, app.cameray, app.grass_objs[i].rect) {
			app.grass_objs.delete(i)
		}
	}
	for i := app.squirrel_objs.len - 1; i >= 0; i-- {
		if is_outside_active_area_a(app.camerax, app.cameray, app.squirrel_objs[i]) {
			app.squirrel_objs.delete(i)
		}
	}

	for app.grass_objs.len < numgrass {
		app.grass_objs << make_new_grass(app.camerax, app.cameray)
	}
	for app.squirrel_objs.len < numsquirrels {
		app.squirrel_objs << Squirrel.new(app.camerax, app.cameray)
	}

	player_centerx := app.player_obj.x + app.player_obj.size / 2
	player_centery := app.player_obj.y + app.player_obj.size / 2
	if (app.camerax + half_winwidth) - player_centerx > cameraslack {
		app.camerax = player_centerx + cameraslack - half_winwidth
	} else if player_centerx - (app.camerax + half_winwidth) > cameraslack {
		app.camerax = player_centerx - cameraslack - half_winwidth
	}
	if (app.cameray + half_winheight) - player_centery > cameraslack {
		app.cameray = player_centery + cameraslack - half_winheight
	} else if player_centery - (app.cameray + half_winheight) > cameraslack {
		app.cameray = player_centery - cameraslack - half_winheight
	}

	ws := g.gg.window_size()
	g.gg.draw_rect_filled(0, 0, ws.width, ws.height, grass_color)

	for graz in app.grass_objs {
		draw_image(g, app.imgs[graz.grass_image + 1], graz.x - app.camerax, graz.y - app.cameray,
			graz.width, graz.height)
	}

	for mut sq in app.squirrel_objs {
		sq.rect = Rect{sq.x - app.camerax, sq.y - app.cameray - get_bounce_amount(sq.bounce,
			sq.bouncerate, sq.bounceheight), sq.width, sq.height}

		draw_image(g, app.imgs[0], sq.rect.x, sq.rect.y, sq.rect.width, sq.rect.height)
	}

	// Draw player

	// app.player_obj

	flash_on := flash_is_on() // math.round(time.time(), 1) * 10 % 2 == 1

	if !app.game_over_mode && !(app.invulnerable_mode && flash_on) {
		app.player_obj.rect = Rect{app.player_obj.x - app.camerax, app.player_obj.y - app.cameray - get_bounce_amount(app.player_obj.bounce,
			bouncerate * 16, bounceheight), app.player_obj.size, app.player_obj.size}

		draw_image(g, app.imgs[0], app.player_obj.rect.x, app.player_obj.rect.y, app.player_obj.rect.width,
			app.player_obj.rect.height)
	}

	draw_health_meter(g, app.player_obj.health)

	if !app.game_over_mode {
		app.move_player()

		// check if the player has collided with any squirrels
		for i := app.squirrel_objs.len - 1; i >= 0; i-- {
			sq_obj := app.squirrel_objs[i]

			if sq_obj.rect != Rect{} && colliderect(app.player_obj.rect, sq_obj.rect) {
				// a player/squirrel collision has occurred
				if sq_obj.width * sq_obj.height <= app.player_obj.size * app.player_obj.size {
					// player is larger and eats the squirrel
					// player_obj.size += int(f64(sq_obj.width * sq_obj.height).sqrt()) + 1

					app.player_obj.size +=
						int(math.sqrt(math.pow(f64(sq_obj.width * sq_obj.height), 0.2))) + 1

					app.squirrel_objs.delete(i)

					if app.player_obj.facing == left {
						app.player_obj.surface = 'L_SQUIR_IMG' // Replace with actual image handling code
					}
					if app.player_obj.facing == right {
						app.player_obj.surface = 'R_SQUIR_IMG' // Replace with actual image handling code
					}

					if app.player_obj.size > winsize {
						app.win_mode = true // turn on "win mode"
					}
				} else if !app.invulnerable_mode {
					app.invulnerable_mode = true
					app.invulnerable_start_time = time.now().unix()
					app.player_obj.health -= 1
					if app.player_obj.health == 0 {
						app.game_over_mode = true // turn on "game over mode"
						app.game_over_start_time = time.now().unix()
					}
				}
			}
		}
	} else {
		// game is over, show "game over" text
		// Placeholder for drawing game over text
		// draw_text(game_over_surf, game_over_rect)
		if time.now().unix() - app.game_over_start_time > gameovertime {
			return
		}
	}

	// check if the player has won.
	if app.win_mode {
		dump(app.player_obj.size)

		// dump(g.theme)

		cfg := gx.TextCfg{
			color:          gx.red // g.theme.text_color
			size:           g.font_size
			vertical_align: .middle
			family:         g.font
		}

		win_surf := 'You have achieved OMEGA SQUIRREL!'
		win_surf2 := '(Press "r" to restart.)'
		// Placeholder for drawing win text
		g.draw_text_ofset(0, 0, winwidth, winheight, 'You have achieved OMEGA SQUIRREL!',
			cfg)
		// draw_text(win_surf, win_rect)
		// draw_text(win_surf2, win_rect2)
	}
}
