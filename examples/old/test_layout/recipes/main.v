import gg
import iui as ui
import gx

@[heap]
struct App {
mut:
	win &ui.Window
}

@[console]
fn main() {
	// Create Window
	mut window := ui.Window.new(
		title: 'My Recipes'
		width: 800
		height: 550
	)
	window.set_theme(ui.theme_seven())

	mut app := &App{
		win: window
	}

	// Create an HBox
	mut hbox := ui.hbox(window)

	for mut recipe in app.make_recipes() {
		mut icon_box := recipe.make_icon()
		hbox.add_child(icon_box)
	}

	hbox.pack()
	hbox.set_width_as_percent(true, 100)

	mut sv := ui.scroll_view(
		view: hbox
		bounds: ui.Bounds{0, 0, 600, 390}
	)

	// mut tb := ui.title_box('Browse', [sv])
	// tb.set_pos(12, 24)

	// Show Window
	window.add_child(sv)
	window.gg.run()
}

fn (mut app App) make_recipes() []Recipe {
	mut recipes := []Recipe{}

	cbm := Recipe{
		app: app
		title: 'Chocolate-Banana Milkshake'
		image: ui.image_from_file('cbm.jpg')
	}
	recipes << cbm

	por := Recipe{
		app: app
		title: 'Puffy Omelet'
		image: ui.image_from_file('po.jpg')
	}
	recipes << por

	img := ui.image_from_file('blank.jpg')
	for i in 0 .. 109 {
		recipes << Recipe{
			app: app
			title: 'Test ${i}'
			image: ui.image_from_file('blank.png')
		}
	}

	return recipes
}

struct Recipe {
mut:
	app         &App
	title       string
	image       &ui.Image
	yield       string   = ' '
	ingredients []string = [' ']
	directions  []string = [' ']
}

fn (mut recipe Recipe) make_icon() &ui.VBox {
	w := 120
	h := 110

	mut box := ui.vbox(recipe.app.win)
	box.set_pos(2, 2)
	recipe.image.set_bounds(1, 1, w, h)

	box.add_child(recipe.image)

	mut lbl := ui.label(recipe.app.win, recipe.title + ' ')
	lbl.set_pos(1, 12)
	lbl.pack()
	box.add_child(lbl)

	mut btn := ui.button(
		text: 'View'
		bounds: ui.Bounds{10, 8, w - 20, 30}
		user_data: &recipe
	)
	btn.subscribe_event('mouse_up', fn [mut recipe] (mut e ui.MouseEvent) {
		// mut recipe := unsafe { &Recipe(&ui.Button(e.target).user_data) }
		mut page := recipe.make_view()
		e.ctx.win.add_child(page)
	})
	box.add_child(btn)

	box.subscribe_event('after_draw', fn (mut e ui.DrawEvent) {
		e.ctx.gg.draw_rect_empty(e.target.rx, e.target.ry, e.target.width, e.target.height,
			e.ctx.theme.textbox_border)

		mut lbl := e.target.children[1]
		lbl.x = (e.target.width / 2) - (lbl.width / 2)
	})

	return box
}

fn (mut recipe Recipe) make_view() &ui.Page {
	mut page := ui.page(recipe.app.win, recipe.title)
	w := 180
	h := 150

	mut box := ui.vbox(recipe.app.win)
	box.set_pos(16, 2)
	recipe.image.set_bounds(1, 1, w, h)

	box.add_child(recipe.image)

	mut lbl := ui.label(recipe.app.win, 'Yield: ' + recipe.yield)
	lbl.set_pos(1, 12)
	lbl.pack()
	box.add_child(lbl)

	mut ilbl := ui.label(recipe.app.win, 'Ingredients: ' + recipe.ingredients.join('\n'))
	ilbl.set_pos(1, 12)
	ilbl.pack()
	box.add_child(ilbl)

	page.add_child(box)

	return page
}
