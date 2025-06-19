module main

import iui as ui
import iui.x.svg
import os
import net.html

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title:  'Testing of SVG <path> support'
		width:  520
		height: 400
		theme:  ui.theme_default()
	)

	list := os.ls(os.resource_abs_path('svgs')) or { [] }

	mut p := ui.Panel.new(
		layout: ui.FlowLayout.new(
			hgap: 32
		)
	)

	for file in list {
		content := os.read_file(os.resource_abs_path('svgs/${file}')) or { '' }
		doc := html.parse(content)
		svg_tag := doc.get_root()

		viewbox := svg_tag.attributes['viewbox']
		w := svg_tag.attributes['width'] or { '32' }
		h := svg_tag.attributes['height'] or { '32' }
		mut paths := []string{}

		for kid in svg_tag.children {
			if kid.name == 'path' {
				path_d := kid.attributes['d']
				paths << path_d
			}
		}

		// dump(paths)

		mut our_svg := svg.Svg.new(
			paths:   paths
			viewbox: viewbox
			width:   w.int()
			height:  h.int()
		)
		// p.add_child(our_svg)
		mut tb := ui.Titlebox.new(
			text:     file.replace('.svg', '')
			padding:  12
			compact:  true
			children: [
				our_svg,
			]
		)
		p.add_child(tb)
	}

	// our_svg.width = 50
	// our_svg.height = 50 // 205

	// Button A
	mut ba := ui.Button.new(text: 'W+')
	ba.subscribe_event('mouse_up', fn (mut e ui.MouseEvent) {
		e.target.parent.children[4].width += 55
	})
	p.add_child(ba)

	// Button B
	mut bb := ui.Button.new(text: 'W-')
	bb.subscribe_event('mouse_up', fn (mut e ui.MouseEvent) {
		e.target.parent.children[4].width -= 55
	})
	p.add_child(bb)

	// Button C
	mut bc := ui.Button.new(text: 'H+')
	bc.subscribe_event('mouse_up', fn (mut e ui.MouseEvent) {
		e.target.parent.children[4].height += 55
	})
	p.add_child(bc)

	// Button D
	mut bd := ui.Button.new(text: 'H-')
	bd.subscribe_event('mouse_up', fn (mut e ui.MouseEvent) {
		e.target.parent.children[4].height -= 55
	})
	p.add_child(bd)

	// p.add_child(our_svg)
	window.add_child(p)

	// Start GG / Show Window
	// window.run()
	mut win := *window
	win.run()
}
