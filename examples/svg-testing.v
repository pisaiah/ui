module main

import iui as ui
import iui.x.svg

fn main() {
	// Create Window
	mut window := ui.Window.new(
		title:  'Testing of SVG <path> support'
		width:  520
		height: 400
		theme:  ui.theme_default()
	)

	mut our_svg := svg.Svg.new(
		path:    'M 2.14645 2.14645C2.34171 1.95118 2.65829 1.95118 2.85355 2.14645L11.5 10.7929L20.1464 2.14645C20.3417 1.95118 20.6583 1.95118 20.8536 2.14645C21.0488 2.34171 21.0488 2.65829 20.8536 2.85355L12.2071 11.5L20.8536 20.1464C21.0488 20.3417 21.0488 20.6583 20.8536 20.8536C20.6583 21.0488 20.3417 21.0488 20.1464 20.8536L11.5 12.2071L2.85355 20.8536C2.65829 21.0488 2.34171 21.0488 2.14645 20.8536C1.95118 20.6583 1.95118 20.3417 2.14645 20.1464L10.7929 11.5L2.14645 2.85355C1.95118 2.65829 1.95118 2.34171 2.14645 2.14645 Z'
		viewbox: '0 0 24 24'
		// path: 'M 150 5 L 75 200 L 225 200 Z'
		// viewbox: '0 0 300 205'
		// path: 'M6.5 1C9.53757 1 12 3.46243 12 6.5C12 7.83879 11.5217 9.06586 10.7266 10.0196L14.8536 14.1464C15.0488 14.3417 15.0488 14.6583 14.8536 14.8536C14.68 15.0271 14.4106 15.0464 14.2157 14.9114L14.1464 14.8536L10.0196 10.7266C9.06586 11.5217 7.83879 12 6.5 12C3.46243 12 1 9.53757 1 6.5C1 3.46243 3.46243 1 6.5 1ZM6.5 2C4.01472 2 2 4.01472 2 6.5C2 8.98528 4.01472 11 6.5 11C8.98528 11 11 8.98528 11 6.5C11 4.01472 8.98528 2 6.5 2Z'
		// viewbox: '0 0 16 16'
	)

	// our_svg.width = 50
	// our_svg.height = 50 // 205

	mut p := ui.Panel.new()

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

	p.add_child(our_svg)
	window.add_child(p)

	// Start GG / Show Window
	// window.run()
	mut win := *window
	win.run()
}
