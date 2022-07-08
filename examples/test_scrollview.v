import gg
import iui as ui

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.get_system_theme(), 'My Window', 520, 500)

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)
	window.bar.add_child(ui.menuitem(' '))

	mut tree := make_tree(window)
	tree.set_bounds(0, 0, 250, 300)
	tree.needs_pack = true

	mut vbox := ui.vbox(window)

	mut sv := ui.ScrollView{
		children: [tree]
	}
	sv.set_bounds(0, 0, 250, 210)

	vbox.add_child(sv)

	vbox.set_pos(32, 40)
	window.add_child(vbox)

	window.gg.run()
}

fn new_btn(win &ui.Window, text string) &ui.Button {
	mut btn := ui.button(win, text)
	btn.set_bounds(4, 4, 250, 30)
	btn.set_pos(4, 4)
	// btn.pack()
	return &btn
}

fn make_tree(window &ui.Window) &ui.Tree2 {
	mut tree := ui.tree2('My Tree')
	tree.set_bounds(330, 220, 180, 210)

	tree.add_child(&ui.TreeNode{
		text: 'Veggies'
		nodes: [
			&ui.TreeNode{
				text: 'Carrot'
			},
			&ui.TreeNode{
				text: 'Tomato'
			},
			&ui.TreeNode{
				text: 'Green Bean'
			},
			&ui.TreeNode{
				text: 'Onion'
			},
			&ui.TreeNode{
				text: 'Corn'
			},
			&ui.TreeNode{
				text: 'Mixed'
			},
		]
	})
	tree.add_child(&ui.TreeNode{
		text: 'Fruits'
		nodes: [
			&ui.TreeNode{
				text: 'Apple'
			},
			&ui.TreeNode{
				text: 'Pear'
			},
			&ui.TreeNode{
				text: 'Strawberry'
			},
		]
	})
	return tree
}
