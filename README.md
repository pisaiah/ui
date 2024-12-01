<img src="https://user-images.githubusercontent.com/16439221/200154661-4e83f755-da21-4c6d-8cda-87e0ee01d105.png#gh-light-mode-only" width="400" align="right"> <img src="https://user-images.githubusercontent.com/16439221/200154731-a08ce323-6d07-47ec-bc28-e171811e639a.png#gh-dark-mode-only" align="right" width="400">

# <img src="https://github.com/pisaiah/ui/assets/16439221/14ccf60b-cff4-4f49-884f-d6dc2cc796ef?s=200&v=4" align="" alt="Isaiah's UI" height="64">

![0.0.20](https://img.shields.io/badge/version-0.0.24-white?style=flat)
![GitHub](https://img.shields.io/badge/license-MIT-blue?style=flat)
![vlang](http://img.shields.io/badge/V-0.4.8-%236d8fc5?style=flat)

Cross-platform GUI library for V. Inspired by the syntax of Java's Swing.

Example: *([examples/demo/](examples/demo/demo.v))*

## Example 

```v
fn main() {
	mut window := ui.Window.new(
		title: 'My App'
		width: 640
		height: 480
	)

	// Create Button
	mut btn := ui.Button.new(text: 'My Button')
	btn.subscribe_event('mouse_up', on_click_event)

	// Add Button to Window & Run
	window.add_child(btn)
	window.gg.run()
}

fn on_click_event(mut e ui.MouseEvent) {
	println('Button clicked!')
}
```

## Install
Install via VPM:

```
v install https://github.com/pisaiah/ui
```
then 
```v
import iui as ui
```

## Components, Containers, & Layouts

| Components    | Containers  | Panel Layouts |
| ------------- | ----------- | ------------- |
| Button        | Window      | Flow Layout   |
| Label         | Panel       | Border Layout |
| Panel         | Tabbox      | Box Layout    |
| Textbox       | HBox        | Grid Layout   |
| TextField     | VBox        | Card Layout   | 
| Menubar       | Modal       |               |
| MenuItem      | Page        |               |
| Checkbox      | ButtonGroup |               |
| Selectbox     | ScrollView  |               |
| Treeview      | Splitview   |               |
| ProgressBar   | TitleGroup  |               |
| Hyperlink     | Popup       |               |
| Image         | DesktopPane |               |
| Slider        | NavPane     |               |
| Switch        |             |               |
| InternalFrame |             |               |
| NavItem       |             |               |

- Components are the elements of the UI (buttons, inputs, etc). 
- Containers are components that can hold other components (known as children).
- Layouts define how the panel positions it's children.

More details about Layout: [A Visual Guide to Layout Managers - docs.oracle.com](https://docs.oracle.com/javase/tutorial/uiswing/layout/visual.html)

## Themes
<table>
<tr><td>Light:<br>- Default, Minty, Ocean, Seven.</td><td><img src="https://github.com/pisaiah/ui/assets/16439221/5b2c9550-d936-4397-8cf4-12a951201a71" height="75"></td></tr>
<tr><td>Dark:<br>- Dark, Black (with Blue, Red, & Green accent colors), Seven Dark.</td><td><img src="https://github.com/pisaiah/ui/assets/16439221/33e1d24e-b24a-4cf4-91db-c9771a5b1fd4" height="75"></td></tr>
</table>

## Included Examples

<table>
	<tr><th>Notepad</th><th>Calculator</th><th>BorderLayout Demo</th><th>Clock</th><th>Internal Frames</th></tr>
	<tr>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/b606df32-382d-4977-a06c-7d8d8d2fb042" align="left" height="130"></td>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/1a42c4dd-351d-4c28-8edd-b85905ea9b1f" height="170"></td>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/0b058466-6775-4edc-a571-7d77870827fd" height="170"></td>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/23a2e490-2aa6-4a3b-b606-3a611eccdb52" height="170"></td>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/bc14ec6c-4318-40d7-bcdd-6e2cf6a270be" height="170"></td>
	</tr>
	<tr>
		<td>See: <a href="examples/Notepad/">Notepad</a></td>
		<td><a href="examples/Notepad/">Calculator</a></td>
		<td><a href="examples/2-BorderLayoutDemo/">Border Layout Demo</a></td>
		<td><a href="examples/Clock/">Clock</a></td>
		<td><a href="examples/Frames/">Internal Frames</a></td>
	</tr>
</table>

<table>
	<tr><th>Mines</th><th>(Tic Tac Toe)^2</th><th>Snake</th></tr>
	<tr>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/fae5d2d2-abf3-490a-ac63-ce685a64abae" height="170"></td>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/5caab783-4341-48a7-84dd-78906280f4e2" height="170"></td>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/3f25af12-67c7-4808-a96c-9ca8d4a80ba4" height="170"></td>
	</tr>
	<tr>
		<td><a href="examples/Games/1-Minesweeper">1-Minesweeper</a></td>
		<td><a href="examples/Games/2-Tic-Tac-Toe-Squared">2-Tic-Tac-Toe-Squared</a></td>
		<td><a href="examples/Games/3-Snake">3-Snake</a></td>
	</tr>
</table>

## Used in
- [Vide](https://github.com/pisaiah/vide)
- [Verminal](https://github.com/pisaiah/verminal)
- [vPaint](https://github.com/pisaiah/vpaint) - Demo: [https://vpaint.app](https://vpaint.app)

![image](https://user-images.githubusercontent.com/16439221/200155263-493d09e2-46d7-4319-b230-679dc1386326.png)

## License
This project is licensed under MIT OR Boost.

<kbd><img src="https://github.com/pisaiah/ui/assets/16439221/5ebb8b15-52e0-4e64-8941-45390a60b3ab" width="128"><br>Veasel *(v mascot)* on a Swing</kbd>
