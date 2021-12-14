# Isaiah's UI Toolkit `0.0.1`

My UI Toolkit for V that uses GG to draw.

## Example 

Example Window with Menubar & Button:
```v
fn main() {
	mut window := ui.window(ui.theme_default())
	window.init()

	// Create MenuBar and items
	window.bar = ui.menubar(window, window.theme)
	mut help := ui.menuitem('Help')
	mut about := ui.menuitem('About')

	help.items << about // Add About item to Help menu
	window.bar.items << help // Add Help menu to Menubar

	// Create Button
	mut btn := ui.button(window, 'A Button')
	btn.set_click(on_click)

	// Add Button to Window & Run
	window.components << btn
	window.gg.run() 
}

fn on_click(mut win ui.Window, com ui.Button) {
	println('Button clicked!')
}
```

## Components

| Name | Picture |
|----------|----|
| Button   | ![image](https://user-images.githubusercontent.com/16439221/145850158-0e5b030a-0354-47bb-8657-b94adb4fb9d6.png) |
| Label    | ![image](https://user-images.githubusercontent.com/16439221/145852596-5a5703a3-0b74-449b-aeeb-5666686337b4.png) |
| Textbox  | ![image](https://user-images.githubusercontent.com/16439221/145852324-9fad9743-ca1d-4699-a39c-e33716c7c211.png) |
| Menubar<br>with MenuItem(s)  | ![image](https://user-images.githubusercontent.com/16439221/145851112-d46da49e-15d9-46d8-870d-818e5a52dd31.png) |
| MenuItem(s)<br>inside MenuItem | ![image](https://user-images.githubusercontent.com/16439221/145851571-4831068a-bf5e-4213-9c8e-7fde12148eb3.png) |
| Checkbox | ![image](https://user-images.githubusercontent.com/16439221/145850433-8c21cd91-a249-465b-bab8-ecfd36cace72.png) ![image](https://user-images.githubusercontent.com/16439221/145850800-da4f23ae-1782-44f9-8f10-445f15dc4826.png) |
| Selectbox    | ![image](https://user-images.githubusercontent.com/16439221/146039777-86ddc8a3-c5db-4448-9adc-259d8c763a90.png) ![image](https://user-images.githubusercontent.com/16439221/146040197-4db80b07-d02d-4500-bfbe-c35c581b8a50.png) |
| Radio Button | TODO |
| Treeview     | TODO |
| Hbox         | TODO |
| Vbox         | TODO |
| ProgressBar  | TODO |

* Components marked with `TODO` are coming soon.

## Themes
<img src="https://user-images.githubusercontent.com/16439221/146041512-80865a5f-9659-4e5c-a8f3-69edb98ddf12.png" align="right" style="diasplay:inline" width="500">

- Default
- Dark
- Dark (High Contrast)
- Black Red
- Mint
