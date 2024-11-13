# iui Documentation

Hello world! This is a work in progress documentation.

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
| Switch      |             |               |

### Components

Components are the elements of the UI (buttons, inputs, containers, etc). 

### Containers

Container components are designed specifically to store children.

#### Panel

Panel is a container that can store a group of components. Panel provides many layouts that provide organization of Components.
Included layouts are FlowLayout (default), BoxLayout, BorderLayout, GridLayout.

##### **FlowLayout**
The default FlowLayout will layout Components in a row, starting a new row if the Panel is not wide enough.

![img](https://docs.oracle.com/javase/tutorial/figures/uiswing/layout/FlowLayoutDemo.png)

##### **BorderLayout**

A BorderLayout places components in up to five areas: top, bottom, left, right, and center. 
The sides will use their minium set size; All extra space is given to the center area.

```v
	// Panel with border layout
	mut p := ui.Panel.new(layout: ui.BorderLayout.new())
	p.add_child_with_flag( ... , borderlayout_north)
	p.add_child_with_flag( ... , borderlayout_center)
	// west, east, south, etc.
```

![img](https://docs.oracle.com/javase/tutorial/figures/uiswing/layout/BorderLayoutDemo.png)

##### **BoxLayout**

BoxLayout The BoxLayout class puts components in a single row or column.

```v
	// Panel with box layout, ori specifies verticle (1) or horizontal 0 ()
	mut p := ui.Panel.new(layout: ui.BoxLayout.new(ori: 1))
```

![img](https://docs.oracle.com/javase/tutorial/figures/uiswing/layout/BoxLayoutDemo.png)

##### **GridLayout**
GridLayout simply makes a bunch of components equal in size and displays them in the requested number of rows and columns.