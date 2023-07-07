# Button Demo

A simple window containing a HBox with three buttons.

```v
mut win := ui.make_window(
	title: 'Button Demo'
	width: 520
	height: 400
)

mut hbox := ui.hbox(win)

mut left_button := ui.button(
	text: 'Left Button'
)

mut mid_button := ui.button(
	text: 'Middle Button'
)

mut right_button := ui.button(
	text: 'Right Button'
)

hbox.add_child(left_button)
hbox.add_child(mid_button)
hbox.add_child(right_button)

window.add_child(hbox)

win.run()
```