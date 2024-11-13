# iUi Documentation: Demos


## Window Demo
![demo1 img](https://docs.oracle.com/javase/tutorial/figures/uiswing/components/FrameDemoMetal.png)

```v
mut window := ui.Window.new(
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
mut win := ui.Window.new(
	title: 'Button Demo'
	width: 520
	height: 400
)

mut p := ui.Panel.new()

mut left_button := ui.Button.new(text: '1st Button')

mut mid_button := ui.Button.new(text: '2nt Button')

mut right_button := ui.Button.new(text: '3rd Button')

p.add_child(left_button)
p.add_child(mid_button)
p.add_child(right_button)

window.add_child(p)

win.run()
```

### Menubar/MenuItem Demo

### Checkbox Demo
![checkbox demo img](https://docs.oracle.com/javase/tutorial/figures/uiswing/components/CheckBoxDemoMetal.png)

### Radiobutton Demo
![radio demo img](https://docs.oracle.com/javase/tutorial/figures/uiswing/components/RadioButtonDemoMetal.png)

```v
mut win := ui.Window.new(
	title: 'Radiobutton Demo'
	width: 520
	height: 400
)

mut vbox := ui.Panel.new(
	layout: ui.BoxLayout.new()
)
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

#  
iUI - Copyright &copy; 2021-2023.
