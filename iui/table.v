module iui

pub struct Table {
	Component_A
pub mut:
	contents [][]Component
}

pub fn table(w int, h int) &Table {
	return &Table{
		contents: [][]Component{len: w, init: []Component{len: h, init: Component(Component_A{})}}
	}
}

pub fn (mut this Table) set_content(x int, y int, content Component) {
	this.contents[x][y] = content
}

fn (mut this Table) draw(ctx &GraphicsContext) {
	mut x := this.x
	mut y := this.y
	for mut row in this.contents {
		for mut col in row {
			col.draw_with_offset(ctx, x, y)

			y += 25
		}
		ctx.gg.draw_rect_empty(x, y, 25, 25, ctx.theme.text_color)
		y = 0
		x += 25
	}
}
