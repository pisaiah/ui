<img src="https://github.com/user-attachments/assets/2de597eb-e78a-47cf-be4f-3663c67d130c#gh-light-mode-only" width="400" align="right"> <img src="https://github.com/user-attachments/assets/fde5c0fc-d60b-4804-aac8-8ccde8a1b4cf#gh-dark-mode-only" align="right" width="400">

<img src="https://github.com/pisaiah/ui/assets/16439221/14ccf60b-cff4-4f49-884f-d6dc2cc796ef?s=200&v=4" align="" alt="iUI" height="64">

<br>

![0.0.20](https://img.shields.io/badge/version-0.0.24-white?style=flat)
![GitHub](https://img.shields.io/badge/license-MIT-blue?style=flat)
![vlang](http://img.shields.io/badge/V-0.4.10-%236d8fc5?style=flat)

Cross-platform GUI library for V. Inspired by the syntax of Java's Swing & my take on WinUI-3 Style.

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

fn on_click_event(e &ui.MouseEvent) {
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
| Checkbox      | Panel       | Border Layout |
| Hyperlink     | Tabbox      | Box Layout    |
| Image         | Modal       | Grid Layout   |
| InternalFrame | Page        | Card Layout   | 
| Label         | ButtonGroup |               |
| Menubar       | ScrollView  |               |
| MenuItem      | Splitview   |               |
| NavPaneItem   | TitleGroup  |               |
| ProgressBar   | Popup       |               |
| Selectbox     | DesktopPane |               |
| Slider        | NavPane     |               |
| Switch        |             |               |
| Textbox       |             |               |
| TextField     |             |               |
| Treeview      |             |               |

- Components are the elements of the UI (buttons, inputs, etc). 
- Containers are components that are designed to contain other components (known as children).
- Layouts define how the Panel container positions it's children.

More details about Layout: [A Visual Guide to Layout Managers - docs.oracle.com](https://docs.oracle.com/javase/tutorial/uiswing/layout/visual.html)

## Themes
<table>
<tr><td>Light:<br>- Default, Minty, Ocean, Seven.</td><td><img src="https://github.com/pisaiah/ui/assets/16439221/5b2c9550-d936-4397-8cf4-12a951201a71" height="75"></td></tr>
<tr><td>Dark:<br>- Dark (with Blue/Red/Green/or RGB Accent), Seven Dark.</td><td><img src="https://github.com/pisaiah/ui/assets/16439221/33e1d24e-b24a-4cf4-91db-c9771a5b1fd4" height="75"></td></tr>
</table>

## Included Examples

<table>
	<tr><th>BorderLayout Demo</th><th>Internal Frames</th><th>Navigation Pane</th></tr>
	<tr>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/0b058466-6775-4edc-a571-7d77870827fd" height="170"></td>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/bc14ec6c-4318-40d7-bcdd-6e2cf6a270be" height="170"></td>
  		<td><img src="https://github.com/user-attachments/assets/4335c983-03d8-43e3-8ea8-3b4986e92d62" height="170"></td>	</tr>
	<tr>
		<td><a href="examples/2-BorderLayoutDemo/">Border Layout Demo</a></td>
		<td><a href="examples/Frames/">Internal Frames</a></td>
		<td><a href="examples/navpane_demo.v">Navigation Pane</a></td>
	</tr>
</table>

<table>
	<tr><th>Notepad</th><th>Calculator</th><th>Clock</th><th>Video Player</th></tr>
	<tr>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/b606df32-382d-4977-a06c-7d8d8d2fb042" align="left" height="130"></td>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/1a42c4dd-351d-4c28-8edd-b85905ea9b1f" height="170"></td>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/23a2e490-2aa6-4a3b-b606-3a611eccdb52" height="170"></td>
		<td><img src="https://github.com/user-attachments/assets/3b38578c-1dea-44a3-92cc-3b025d9dae1d" height="170"></td>
	</tr>
	<tr>
		<td>See: <a href="examples/Notepad/">Notepad</a></td>
		<td><a href="examples/Notepad/">Calculator</a></td>
		<td><a href="examples/Clock/">Clock</a></td>
		<td><a href="examples/VideoPlayer">Video Player</a> <i>(requires libmpv)</i></td>
	</tr>
</table>

<table>
	<tr><th>Mines</th><th>(Tic Tac Toe)^2</th><th>Snake</th></tr>
	<tr>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/fae5d2d2-abf3-490a-ac63-ce685a64abae" height="170"></td>
		<td><img src="https://github.com/user-attachments/assets/4f9969ed-43ec-4b0d-aa40-f92eae338d9b" height="170"></td>
		<td><img src="https://github.com/pisaiah/ui/assets/16439221/3f25af12-67c7-4808-a96c-9ca8d4a80ba4" height="170"></td>
	</tr>
	<tr>
		<td>Code: <a href="examples/Games/1-Minesweeper">1-Minesweeper</a><br>Demo: <a href="https://pisaiah.com/showcase/app/mines/index.html"><i>Play online (via WASM)</i></a></td>
		<td><a href="examples/Games/2-Tic-Tac-Toe-Squared">2-Tic-Tac-Toe-Squared</a><br><a href="https://pisaiah.com/showcase/app/tictactoe/index.html"><i>Play online (WASM)</i></a></td>
		<td><a href="examples/Games/3-Snake">3-Snake</a></td>
	</tr>
</table>

## Used in
- [Vide](https://github.com/pisaiah/vide)
- [Verminal](https://github.com/pisaiah/verminal)
- [vPaint](https://github.com/pisaiah/vpaint) - Demo: [https://vpaint.app](https://vpaint.app)

![image](https://github.com/user-attachments/assets/82a395ce-1c4b-4d4a-a2db-44009f3ed009)


## License
This project is licensed under MIT OR Boost.

<kbd><img src="https://github.com/pisaiah/ui/assets/16439221/5ebb8b15-52e0-4e64-8941-45390a60b3ab" width="128"><br>Veasel *(v mascot)* on a Swing</kbd>
