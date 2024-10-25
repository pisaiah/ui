## 0.1
*Not released yet*
- TODO

Planned TODO Features:
- System L&F themes
- Use in `java2v` to support translating swing
- port JavaFx's charts
- List (https://docs.oracle.com/javase/8/docs/api/javax/swing/JList.html)
- Spinner (https://docs.oracle.com/javase/8/docs/api/javax/swing/JSpinner.html)

## 0.0.23
- add 'value_change' event to Slider
- Add 'padding' field to Menubar
- Add slide out animation to MenuItem
- Add SettingsCard (reference: https://learn.microsoft.com/en-us/dotnet/communitytoolkit/windows/settingscontrols/settingscard)
- Requires V 0.4.8 or higher

## 0.0.22
- Add video player example (requires user download mpv.dll)
- Add Panel.set_background
- Add Component.set_hidden

## 0.0.21
- Update dialogs
- improve fluent design of text field

## 0.0.20
- Remove some deprecated functions
- Improve SwapBuffers CPU usage on Windows
- Tab overflow
- draw focus border for Textfield

## 0.0.19
*Sept, 8th*
- (WIP) Now uses the new static methods introduced in V 0.3.5 (ex. `ui.Button.new`)
- ProgressBar: new `bind_to` function (inspired by https://docs.oracle.com/javafx/2/binding/jfxpub-binding.htm)
- ScrollView: new `set_border_painted` function
- Popup: New Popups (https://docs.oracle.com/javase/8/docs/api/javax/swing/JPopupMenu.html)
- Selectbox: Use new Popups for displaying choice items.
- Selector: Deprecate, has been replaced by Selectbox.

## 0.0.18
*April, 23rd*
- Completly redone Textbox
- New Textbox now has text selection.
- New Panel component
	- BoxLayout -  inspired by https://docs.oracle.com/javase/tutorial/uiswing/layout/box.html
	- FlowLayout - inspired by https://docs.oracle.com/javase/tutorial/uiswing/layout/flow.html
	- GridLayout - inspired by https://docs.oracle.com/javase/tutorial/uiswing/layout/grid.html
	- BorderLayout - inspired by https://docs.oracle.com/javase/tutorial/uiswing/layout/border.html

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
- Add TitleBox ( inspired by https://docs.oracle.com/javase/8/docs/api/javax/swing/border/TitledBorder.html )

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
- Add HBox (similar to https://docs.oracle.com/javase/8/javafx/api/javafx/scene/layout/HBox.html )
- Add VBox

## 0.0.4
- Improve Slider
- Fix click events in Modal.
- Add TextEdit, replacement for Textbox.

## 0.0.3
- Add `set_id`
- Add `get_by_id`

## 0.0.2
- Add Tabbox (similar to https://docs.oracle.com/javase/8/docs/api/javax/swing/JTabbedPane.html ) 
- Add TreeView

## 0.0.1
*Dec 9, 2021*
- First version