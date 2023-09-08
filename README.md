<img src="https://user-images.githubusercontent.com/16439221/200154661-4e83f755-da21-4c6d-8cda-87e0ee01d105.png#gh-light-mode-only" width="400" align="right"> <img src="https://user-images.githubusercontent.com/16439221/200154731-a08ce323-6d07-47ec-bc28-e171811e639a.png#gh-dark-mode-only" align="right" width="400">

# <img src="https://github.com/isaiahpatton/ui/assets/16439221/14ccf60b-cff4-4f49-884f-d6dc2cc796ef?s=200&v=4" align="" alt="Isaiah's UI" height="64">

![0.0.20](https://img.shields.io/badge/version-0.0.20-white?style=flat)
![GitHub](https://img.shields.io/badge/license-MIT-blue?style=flat)
![vlang](http://img.shields.io/badge/V-0.4.0-%236d8fc5?style=flat)

Isaiah's cross-platform GUI library for V. Inspired by the syntax of Java's Swing.

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
v install https://github.com/isaiahpatton/ui
```
then 
```v
import iui as ui
```

## Components, Containers, & Layouts

| Components  | Containers  | Panel Layouts |
| ----------- | ----------  | ------------- |
| Button      | Window      | Flow Layout   |
| Label       | Panel       | Border Layout |
| Panel       | Tabbox      | Box Layout    |
| Textbox     | HBox        | Grid Layout   |
| TextField   | VBox        |               | 
| Menubar     | Modal       |               |
| MenuItem    | Page        |               |
| Checkbox    | ButtonGroup |               |
| Selectbox   | ScrollView  |               |
| Treeview    | Splitview   |               |
| ProgressBar | TitleGroup  |               |
| Hyperlink   | Popup       |               |
| Image       |             |               |
| Slider      |             |               |

- Components are the elements of the UI (buttons, inputs, etc). 
- Containers are components that can hold other components (known as children).
- Layouts define how the panel positions it's children.

More details about Layout: [A Visual Guide to Layout Managers - docs.oracle.com](https://docs.oracle.com/javase/tutorial/uiswing/layout/visual.html)

<!--
| Name | Picture (Default Theme) | | Name | Picture (Default Theme) | | Name | Picture (Default Theme) |
|----------|----|--|-|-|---|---|---|
| Button   | ![image](https://user-images.githubusercontent.com/16439221/145850158-0e5b030a-0354-47bb-8657-b94adb4fb9d6.png) | | Label | ![image](https://user-images.githubusercontent.com/16439221/145852596-5a5703a3-0b74-449b-aeeb-5666686337b4.png) | | TextArea/TextField  | ![image](https://github.com/isaiahpatton/ui/assets/16439221/4d98acc3-52c9-4cf6-9841-fb6935cb5d08) |
| Menubar  | ![image](https://github.com/isaiahpatton/ui/assets/16439221/0d03daba-af09-45fa-9530-096dedb32f8a) | | MenuItem | ![image](https://user-images.githubusercontent.com/16439221/214737789-2221a11a-675f-425b-8b4c-132fe186e779.png) | | Checkbox | ![image](https://github.com/isaiahpatton/ui/assets/16439221/9ca92e50-c906-4ade-8974-ffdd4d329256) | |
| Selectbox    | ![image](https://github.com/isaiahpatton/ui/assets/16439221/42a12385-a9d0-4194-9e1e-cacf4d163ad3) | | Treeview     | ![image](https://github.com/isaiahpatton/ui/assets/16439221/0aa931e2-88f1-44b4-bcc9-2f53a8341e68) | | ProgressBar  | ![image](https://user-images.githubusercontent.com/16439221/146232553-1916c9cb-181a-4c22-a4a0-c84496f641b4.png) | |
| Tabbox | ![image](https://user-images.githubusercontent.com/16439221/214737316-8f18fcf3-cb4b-49d4-a59d-ce8f020b492f.png) | | HBox         | (need preview) | | VBox         | (need preview) | |

* Components marked with `TODO` are coming soon.
-->

## Themes
<table>
<tr><td>Light:<br>- Default, Minty, Ocean, Seven.</td><td><img src="https://github.com/isaiahpatton/ui/assets/16439221/5b2c9550-d936-4397-8cf4-12a951201a71" height="75"></td></tr>
<tr><td>Dark:<br>- Dark, Black (with White, Red, & Green accent colors), Seven Dark.</td><td><img src="https://github.com/isaiahpatton/ui/assets/16439221/33e1d24e-b24a-4cf4-91db-c9771a5b1fd4" height="75"></td></tr>
</table>

## Included Examples

<table>
	<tr><th>Notepad</th><th>Calculator</th><th>BorderLayout Demo</th></tr>
	<tr>
		<td><img src="https://github.com/isaiahpatton/ui/assets/16439221/b606df32-382d-4977-a06c-7d8d8d2fb042" align="left" height="130"></td>
		<td><img src="https://github.com/isaiahpatton/ui/assets/16439221/1a42c4dd-351d-4c28-8edd-b85905ea9b1f" height="170"></td>
		<td><img src="https://github.com/isaiahpatton/ui/assets/16439221/0b058466-6775-4edc-a571-7d77870827fd" height="170"></td>
	</tr>
	<tr>
		<td>See: <a href="examples/Notepad/">examples/Notepad/</a></td>
		<td><a href="examples/Notepad/">examples/Calculator/</a></td>
		<td><a href="examples/2-BorderLayoutDemo/">examples/2-BorderLayoutDemo/</a></td>
	</tr>
</table>


## Used in
- [Vide](https://github.com/isaiahpatton/vide)
- [Verminal](https://github.com/isaiahpatton/verminal)
- [vPaint](https://github.com/isaiahpatton/vpaint) - Demo: [https://vpaint.app](https://vpaint.app)

![image](https://user-images.githubusercontent.com/16439221/200155263-493d09e2-46d7-4319-b230-679dc1386326.png)

## License
This project is licensed under MIT OR Boost.
