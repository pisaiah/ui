# Isaiah's UI Toolkit `0.0.5`

My UI Widget Toolkit for V. Example: *([examples/test.v](examples/test.v))*

![image](https://user-images.githubusercontent.com/16439221/158931211-94c5dc3d-887e-4906-8ea1-d4620a82257d.png)

## Example 

```v
fn main() {
	mut window := ui.window(ui.theme_default(), 'My App')

	// Create Button
	mut btn := ui.button(window, 'A Button')
	btn.set_click_fn(on_click)

	// Add Button to Window & Run
	window.add_child(btn)
	window.gg.run() 
}

fn on_click_event(win voidptr, btn voidptr, data voidptr) {
	println('Button clicked!')
}
```

## Components
| Name | Picture (Default Theme) | | Name | Picture (Default Theme) |
|----------|----|--|-|-|
| Button   | ![image](https://user-images.githubusercontent.com/16439221/145850158-0e5b030a-0354-47bb-8657-b94adb4fb9d6.png) | | Label | ![image](https://user-images.githubusercontent.com/16439221/145852596-5a5703a3-0b74-449b-aeeb-5666686337b4.png) | 
| Textbox  | ![image](https://user-images.githubusercontent.com/16439221/145852324-9fad9743-ca1d-4699-a39c-e33716c7c211.png) | | Menubar<br>with MenuItem(s)  | ![image](https://user-images.githubusercontent.com/16439221/145851112-d46da49e-15d9-46d8-870d-818e5a52dd31.png) |
| MenuItem(s)<br>inside MenuItem | ![image](https://user-images.githubusercontent.com/16439221/145851571-4831068a-bf5e-4213-9c8e-7fde12148eb3.png) | | Checkbox | ![image](https://user-images.githubusercontent.com/16439221/145850433-8c21cd91-a249-465b-bab8-ecfd36cace72.png) ![image](https://user-images.githubusercontent.com/16439221/145850800-da4f23ae-1782-44f9-8f10-445f15dc4826.png) | |
| Selectbox    | ![image](https://user-images.githubusercontent.com/16439221/146039777-86ddc8a3-c5db-4448-9adc-259d8c763a90.png) ![image](https://user-images.githubusercontent.com/16439221/146040197-4db80b07-d02d-4500-bfbe-c35c581b8a50.png) | | Radio Button | TODO | |
| Treeview     | ![image](https://user-images.githubusercontent.com/16439221/146417738-4af4b85d-5191-430b-8874-01cb64591a31.png) | | ProgressBar  | ![image](https://user-images.githubusercontent.com/16439221/146232553-1916c9cb-181a-4c22-a4a0-c84496f641b4.png) | |
| Tabbox | ![image](https://user-images.githubusercontent.com/16439221/147746902-0adab304-3c6a-454c-be98-bd5329a01949.png) | | HBox         | (need preview) | |
| VBox         | (need preview) | |

* Components marked with `TODO` are coming soon.

## Themes
![image](https://user-images.githubusercontent.com/16439221/147748093-21c792e5-a746-491f-8d03-a3eae0491f8e.png)

Included Themes:
- Light: Default, Mint
- Dark:  Dark, Dark (High Contrast), Black Red

## Used in
- [Vide](https://github.com/isaiahpatton/vide)
- [Verminal](https://github.com/isaiahpatton/verminal)
- [GUI Builder](https://github.com/isaiahpatton/gui-builder)
- [vPaint](https://github.com/isaiahpatton/vpaint)

![image](https://user-images.githubusercontent.com/16439221/158929709-bc7628d6-2581-4de1-8eb6-0c50c5385b16.png)

