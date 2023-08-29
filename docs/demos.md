# iUi Documentation: Demos


## Window Demo
![demo1 img](https://docs.oracle.com/javase/tutorial/figures/uiswing/components/FrameDemoMetal.png)

```v
mut window := ui.make_window(
	title: 'Window Demo'
	width: 520
	height: 400
	theme: ui.theme_default()
)
window.run()
```

## Components

### Button Demo
![buttton demo img](https://docs.oracle.com/javase/tutorial/figures/uiswing/components/ButtonDemoMetal.png)

```v
mut win := ui.make_window(
	title: 'Button Demo'
	width: 520
	height: 400
)

mut hbox := ui.hbox(win)

mut left_button := ui.button(
	text: 'Disable Middle Button'
)

mut mid_button := ui.button(
	text: 'Middle Button'
)

mut right_button := ui.button(
	text: 'Enable Middle Button'
)

hbox.add_child(left_button)
hbox.add_child(mid_button)
hbox.add_child(right_button)

window.add_child(hbox)

win.run()
```

### Menubar/MenuItem Demo

### Checkbox Demo
![checkbox demo img](https://docs.oracle.com/javase/tutorial/figures/uiswing/components/CheckBoxDemoMetal.png)

### Radiobutton Demo
![radio demo img](https://docs.oracle.com/javase/tutorial/figures/uiswing/components/RadioButtonDemoMetal.png)

```v
mut win := ui.make_window(
	title: 'Radiobutton Demo'
	width: 520
	height: 400
	theme: ui.theme_default()
)

mut vbox := ui.vbox(win)
mut group := ui.buttongroup()

choices := ['Bird', 'Cat', 'Dog', 'Rabbit', 'Pig']
for choice in choices {
	mut cb := ui.check_box(
		text: choice
	)
	vbox.add_child(cb)
	group.add(cb)
}
group.setup()
window.add_child(vbox)

win.run()
```

### Progressbar Demo
![progressbar demo img](https://docs.oracle.com/javase/tutorial/figures/uiswing/components/ProgressBarDemo.png)

### Canvas Demo
```
println('TODO')
```

## File Picker Demo
![file picker img](https://docs.oracle.com/javase/tutorial/figures/uiswing/components/FileChooserOpenMetal.png)


# References
- https://docs.oracle.com/javase/tutorial/uiswing/components/frame.html
- https://docs.oracle.com/javase/tutorial/uiswing/components/button.html
- https://docs.oracle.com/javase/tutorial/uiswing/components/buttongroup.html
- https://docs.oracle.com/javase/tutorial/uiswing/components/splitpane.html
- https://docs.oracle.com/javase/tutorial/uiswing/components/filechooser.html
- https://docs.oracle.com/javase/tutorial/uiswing/components/textarea.html
- https://docs.oracle.com/javase/tutorial/uiswing/components/tabbedpane.html
- https://docs.oracle.com/javase/tutorial/uiswing/components/table.html
- https://uxmovement.com/forms/why-radio-buttons-and-checkboxes-cant-co-exist/

#  
iUI - Copyright &copy; 2021-2023.
