module iui

pub struct Table {
	Component_A
pub:
	win &Window
pub mut:
	contents [][]Component
}

pub fn table(win &Window, w int, h int) &Table {
	return &Table{
		win: win
		contents: [][]Component{len: w, init: []Component{len: h, init: Component(Component_A{})}}
	}
}

pub fn (mut this Table) set_content(x int, y int, content Component) {
	this.contents[x][y] = content
}

fn (mut this Table) draw() {
	mut x := this.x
	mut y := this.y
	for mut row in this.contents {
		for mut col in row {
			// if col != voidptr(0) {
			// mut com := &Component_A(col)
			// if mut com is Component_A {
			// println('IS A')
			draw_with_offset(mut col, x, y)

			//}
			//}
			y += 25
		}
		this.win.gg.draw_rect_empty(x, y, 25, 25, this.win.theme.text_color)
		y = 0
		x += 25
	}
}
