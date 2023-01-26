# Isaiah's UI ![0.0.15](https://img.shields.io/badge/version-0.0.15-white?style=for-the-badge) ![GitHub](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)

Cross-platform GUI library for V. Inspired by the syntax of Java's Swing.

Example: *([examples/demo/](examples/demo/demo.v))*

<img src="https://user-images.githubusercontent.com/16439221/200154661-4e83f755-da21-4c6d-8cda-87e0ee01d105.png" width="400"> <img src="https://user-images.githubusercontent.com/16439221/200154731-a08ce323-6d07-47ec-bc28-e171811e639a.png" width="400">

## Example 

```v
fn main() {
	mut window := ui.make_window(
		title: 'My App'
		width: 640
		height: 480
		theme: ui.theme_default()
	)

	// Create Button
	mut btn := ui.button(
		text: 'A Button'
	)
	btn.set_click_fn(on_click, 0)

	// Add Button to Window & Run
	window.add_child(btn)
	window.gg.run() 
}

fn on_click_event(win &ui.Window, btn &ui.Button, user_data voidptr) {
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

## Components
| Name | Picture (Default Theme) | | Name | Picture (Default Theme) |
|----------|----|--|-|-|
| Button   | ![image](https://user-images.githubusercontent.com/16439221/145850158-0e5b030a-0354-47bb-8657-b94adb4fb9d6.png) | | Label | ![image](https://user-images.githubusercontent.com/16439221/145852596-5a5703a3-0b74-449b-aeeb-5666686337b4.png) | 
| TextArea/TextField  | ![image](https://user-images.githubusercontent.com/16439221/214735580-feea2c0a-e076-4edd-844d-ca41a1c8e2f1.png) | | Menubar  | ![image](https://user-images.githubusercontent.com/16439221/145851112-d46da49e-15d9-46d8-870d-818e5a52dd31.png) |
| Opened MenuItem | ![image](https://user-images.githubusercontent.com/16439221/214737789-2221a11a-675f-425b-8b4c-132fe186e779.png) | | Checkbox | ![image](https://user-images.githubusercontent.com/16439221/145850433-8c21cd91-a249-465b-bab8-ecfd36cace72.png) ![image](https://user-images.githubusercontent.com/16439221/145850800-da4f23ae-1782-44f9-8f10-445f15dc4826.png) | |
| Selectbox    | ![image](https://user-images.githubusercontent.com/16439221/146039777-86ddc8a3-c5db-4448-9adc-259d8c763a90.png) | | Radio Button | TODO | |
| Treeview     | ![image](https://user-images.githubusercontent.com/16439221/214736911-aee57444-75d3-4cc9-9c07-81bc5c205568.png) | | ProgressBar  | ![image](https://user-images.githubusercontent.com/16439221/146232553-1916c9cb-181a-4c22-a4a0-c84496f641b4.png) | |
| Tabbox | ![image](https://user-images.githubusercontent.com/16439221/214737316-8f18fcf3-cb4b-49d4-a59d-ce8f020b492f.png) | | HBox         | (need preview) | |
| VBox         | (need preview) | |

* Components marked with `TODO` are coming soon.

## Themes
![image](https://user-images.githubusercontent.com/16439221/147748093-21c792e5-a746-491f-8d03-a3eae0491f8e.png)

Included Themes:
- Light: Default, Minty, Ocean.
- Dark:  Dark, Black (with White, Red, & Green accent colors)

## Used in
- [Vide](https://github.com/isaiahpatton/vide)
- [Verminal](https://github.com/isaiahpatton/verminal)
- [vPaint](https://github.com/isaiahpatton/vpaint) - Demo: [https://vpaint.app](https://vpaint.app)

![image](https://user-images.githubusercontent.com/16439221/200155263-493d09e2-46d7-4319-b230-679dc1386326.png)

## License
This project is licensed under MIT OR Boost.
