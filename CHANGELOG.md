## 0.1
*Not released yet*
- TODO

## 0.0.18
*April, 23rd*
- Completly redone Textbox
- New Textbox now has text selection.
- New Panel component
	- BoxLayout - https://docs.oracle.com/javase/tutorial/uiswing/layout/box.html
	- FlowLayout - https://docs.oracle.com/javase/tutorial/uiswing/layout/flow.html
	- GridLayout - https://docs.oracle.com/javase/tutorial/uiswing/layout/grid.html
	- BorderLayout is coming soon.

## 0.0.17
*Mar 30th, 2023*
- Improved MenuBar / MenuItem
- now supports sub-menuitems

## 0.0.16
*Jan 26, 2023*
- New event system.
- ex: `component.subscribe_event('draw', my_fn)`
- Current new events: `draw`, `after_draw`, `mouse_down`, `mouse_up`

## 0.0.15
*Jan 23, 2023*
- New Theme: "Ocean"
- Change ui.button constructor to use ButtonConfig, remove unused Window argument.
- Fix the `ENTER` key not being recognized in wasm.
- Add SplitView ( https://docs.oracle.com/javase/8/docs/api/javax/swing/JSplitPane.html )

## 0.0.14
- Add arrows to scrollview
- Add Button `set_area_filled` (ex https://docs.oracle.com/javase/7/docs/api/javax/swing/AbstractButton.html#setContentAreaFilled(boolean) )
- Make more functions public
- Cleanup key down event
- Draw Check for Checkbox

(Note: Changelog below 0.0.14 may be incomplete)

## 0.0.13
- Custom border radius for Button 
- Add Numeric-only support to TextField
- Process mobile touch as mouse click
- Add TitleBox

## 0.0.12
- Custom Icon size for Button
- Improvements to Tabbox

## 0.0.11
- HBox fix overflow height
- Add Icon support to Button

## 0.0.10
- Add Horizonal scroll to ScrollView

## 0.0.9
- Add ScrollView
- Fix TinyFileDialogs on Linux

## 0.0.8
- Redo TreeView
- Ability to change thumb color of Slider
- Add SliderConfig
- Add MenubarConfig

## 0.0.7
- Add Font change support.
- improve sizing of VBox/HBox

## 0.0.6
- Examples: Add Browser
- Improved click detect.
- Add GraphicsContext

## 0.0.5
- Add HBox
- Add VBox

## 0.0.4
- Improve Slider
- Fix click events in Modal.
- Add TextEdit, replacement for Textbox.

## 0.0.3
- Add `set_id`
- Add `get_by_id`

## 0.0.2
- Add Tabbox
- Add TreeView

## 0.0.1
*Dec 9, 2021*
- First version
