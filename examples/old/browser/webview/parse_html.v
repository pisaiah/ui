// A simple web browser written in V
// Copyright (c) 2022, Isaiah.
//
// References:
// - https://www.w3schools.com/cssref/css_default_values.asp
//
module webview

import iui as ui
import net.http
import net.html
import os
import time
import v.util.version

struct DocConfig {
mut:
	stylesheets   []StyleSheet
	page_url      string
	bold          bool
	size          int
	href          string
	centered      bool
	action        string
	last_need     voidptr
	margin_top    int
	margin_bottom int
}

fn (this &DocConfig) get_css_val(element string, key string, def string) string {
	for ss in this.stylesheets {
		if element in ss.rules {
			if key in ss.rules[element] {
				return ss.rules[element][key]
			}
		}
	}
	return def
}

fn em(val f32) f32 {
	// TODO: font size
	return 16 * val
}

fn iem(val f32) int {
	return int(em(val))
}

fn box_draw_fn(mut win ui.Window, com &ui.Component) {
	size := win.gg.window_size()
	mut this := *com
	this.width = size.width

	if this.height > 40 {
		this.height = size.height
	}
}

fn width_draw_fn(mut win ui.Window, com &ui.Component) {
	size := win.gg.window_size()
	mut this := *com
	this.width = size.width
	if this.height > 40 {
		this.height = size.height - 102
	}
}

pub fn load_url(mut win ui.Window, url string) {
	println('Loading URL: ' + url)

	start := time.now().unix_time_milli()

	config := http.FetchConfig{
		user_agent: 'V/' + version.v_version + ' Vrowser/0.1'
	}

	mut resp := http.Response{}

	is_file := os.exists(url)

	if !url.starts_with('file://') && !is_file {
		fixed_url := if url.contains('://') { url } else { 'http://' + url }

		resp = http.fetch(http.FetchConfig{ ...config, url: fixed_url }) or {
			println('failed to fetch data from the server')
			return
		}
	} else {
		path := if is_file { url } else { url.split('file://')[1] }

		lines := os.read_lines(os.real_path(path)) or { [] }
		resp.text = lines.join('\n')
	}

	mut url_field := &ui.TextField(win.get_from_id('browser_url_bar'))
	url_field.text = url

	// TODO: Frogfind uses broken HTML (?)
	fixed_text := resp.text.replace('Find!</font></a></b>', 'Find!</font></b></a>').replace('<p> </small></p>',
		'<p></p>')

	os.write_file('E:/outputs/' + time.now().unix_time_milli().str() + '.html', fixed_text) or {} // Debug output
	mut tb := &ui.Tabbox(win.get_from_id('tabbar'))

	ctab := tb.active_tab

	// Remove old content; 25 is height of the navbar
	/*
	for mut child in tb.kids[ctab] {
		if child.y > 30 {
			if !(mut child is ui.Menubar) {
				dump(child.type_name())
				//child.children.free()
			}
		}
	}*/

	tb.kids[ctab] = tb.kids[ctab].filter(it.y < 25 || it is ui.Menubar || it is ui.HBox)

	// Background
	mut bg := bg_area(win)
	bg.set_bounds(0, 35, 0, 45)
	bg.draw_event_fn = width_draw_fn
	bg.set_id(mut win, 'body')
	tb.add_child(tb.active_tab, bg)

	mut doc := html.parse(fixed_text)
	mut root := doc.get_root()

	// mut vbox := ui.vbox(win)
	mut box := ui.box(win)

	// HTML body, margin of 8.
	box.set_bounds(8, 8, 900, 4)

	mut conf := &DocConfig{
		page_url: url
	}

	// root.children.len == 1 (html tag)
	for tag in root.children {
		if tag.name == 'meta' {
			println(tag)
			continue
		}

		render_tag_and_children(mut win, mut box, tag, mut conf)
	}
	mut vbox := box.get_vbox()

	vbox.z_index = -1
	vbox.draw_event_fn = box_draw_fn
	vbox.set_bounds(0, 42, 900, 500) // TODO; size
	tb.add_child(tb.active_tab, vbox)

	end := time.now().unix_time_milli()
	set_status(mut win, 'Done. Took ' + (end - start).str() + 'ms')

	unsafe {
		fixed_text.free()
	}
}

// TODO: CSS
fn set_conf_size(nam string, mut config DocConfig) {
	if nam == 'small' {
		config.size = -4
	}

	if nam == 'h1' {
		config.margin_top = iem(0.67)
		config.margin_bottom = iem(0.67)
		config.size = 16
	}

	if nam == 'h2' {
		config.size = 8
		config.margin_top = iem(0.83)
		config.margin_bottom = iem(0.83)
	}

	if nam == 'h3' {
		config.size = 4
		config.margin_top = iem(1)
		config.margin_bottom = iem(1)
		config.bold = true
	}

	if nam == 'h4' {
		config.size = 2
		config.margin_top = iem(1.33)
		config.margin_bottom = iem(1.33)
	}
}

fn render_tag_and_children(mut win ui.Window, mut box ui.Box, tag &html.Tag, mut conf DocConfig) {
	set_conf_size(tag.name, mut conf)

	block_tags := ['H1', 'H2', 'H3', 'H4', 'H5', 'P', 'CENTER', 'UL', 'LI', 'OL', 'BR']

	if tag.name in block_tags {
		display_rule := conf.get_css_val(tag.name, 'display', '')
		if !display_rule.contains('inline') {
			box.add_break(conf.margin_top)
		}
	}

	if tag.name == 'body' {
		mut body := &BackgroundBox(win.get_from_id('body'))
		color := conf.get_css_val('body', 'background', 'white')
		body.background = parse_color(color)
	}

	if tag.name == 'style' {
		ss := parse_min_css(tag.content)
		conf.stylesheets << ss
	}

	if tag.name == 'li' {
		should := conf.get_css_val('li', 'list-style-type', 'bullet') != 'none'

		if should {
			mut lbl := ui.label(win, '• ')
			padding_left := conf.get_css_val('li', 'padding-left', '40px')

			lbl.x = padding_left.int()
			lbl.set_config(conf.size, false, conf.bold)
			lbl.pack()
			box.add_child(lbl)
		}
	}

	for sub in tag.children {
		nam := sub.name.to_upper()

		if nam == 'STYLE' {
			ss := parse_min_css(sub.content)
			conf.stylesheets << ss
		}

		set_status(mut win, 'Layouting ' + nam + '...')

		if nam == 'TITLE' {
			mut tb := &ui.Tabbox(win.get_from_id('tabbar'))
			if tb.active_tab != sub.content {
				tb.change_title(tb.active_tab, sub.content)
			}
			continue
		}

		display_rule := conf.get_css_val(sub.name, 'display', '')

		if nam in block_tags && !display_rule.contains('inline') {
			box.add_break(conf.margin_top)
		}

		if nam == 'CENTER' {
			conf.centered = true
		}
		if conf.centered {
			box.center_current_hbox()
		}

		if nam == 'B' {
			conf.bold = true
		}

		if nam == 'IMG' {
			img := handle_image(mut win, sub, conf)
			box.add_child(img)
			box.set_current_height(img.height)
			continue
		}

		set_conf_size(sub.name, mut conf)

		if nam == 'FORM' || nam == 'INPUT' {
			handle_form_tags(mut win, mut box, sub, mut conf)
		}

		if nam == 'BUTTON' {
			mut btn := ui.button(text: sub.content)

			if conf.href.len > 0 {
				href := format_url(conf.href, conf.page_url)
				btn.set_click_fn(btn_href_click, &StringPtr{href})
			}

			btn.pack()
			box.add_child(btn)
		}

		if nam == 'A' {
			// Link
			conf.href = sub.attributes['href']

			if sub.content.trim_space().len > 0 {
				mut lbl := create_hyperlink_label(win, sub.content, conf)
				box.add_child(lbl)
			}
		} else if conf.href.len > 0 && tag.name == 'a' {
			// Link
			if nam == 'BUTTON' {
				// TODO: Button link
			} else {
				if !(nam == 'SCRIPT' || nam == 'STYLE' || nam == 'BUTTON')
					&& sub.content.trim_space().len > 0 {
					mut lbl := create_hyperlink_label(win, sub.content, conf)
					box.add_child(lbl)
				}
			}
		} else {
			if !(nam == 'SCRIPT' || nam == 'STYLE' || nam == 'BUTTON')
				&& sub.content.trim_space().len > 0 {
				content := sub.content.replace('&nbsp;', ' ')
				mut lbl := ui.label(win, unescape(content))
				lbl.set_config(conf.size, false, conf.bold)
				lbl.pack()

				box.add_child(lbl)
			}
		}
		if sub.children.len > 0 {
			render_tag_and_children(mut win, mut box, sub, mut conf)
		}

		if nam in block_tags {
			box.add_break(conf.margin_bottom)
			if nam.len == 2 && nam.starts_with('H') {
				box.add_break(10)
			}
		}

		if nam == 'BR' {
			box.add_break(20)
		}

		// Reset config
		conf.bold = false

		if nam == 'CENTER' {
			conf.centered = false
		}
		if conf.size > 0 {
			conf.size = 0
		}
		if nam.len == 2 && nam.starts_with('H') {
			conf.margin_top = 0
			conf.margin_bottom = 0
			conf.bold = false
		}
	}

	if 'href' in tag.attributes && tag.name == 'a' {
		conf.href = ''
	}

	if tag.name == 'form' {
		conf.action = ''
	}

	if tag.name == 'small' {
		conf.size = 0
	}

	if tag.name.starts_with('h') && tag.name.len == 2 {
		conf.margin_top = 0
		conf.margin_bottom = 0
		conf.bold = false
	}
}

// TODO: how to cast voidptr to string?
struct StringPtr {
	val string
}

fn btn_href_click(a voidptr, b voidptr, c voidptr) {
	mut win := &ui.Window(a)
	urll := &StringPtr(c)
	load_url(mut win, urll.val)
}

fn create_hyperlink_label(win &ui.Window, content string, conf DocConfig) &ui.Hyperlink {
	mut href := format_url(conf.href, conf.page_url)

	mut lbl := ui.link(
		text: content
		url:  href
	)

	lbl.click_event_fn = fn [win] (a voidptr) {
		mut this := &ui.Hyperlink(a)
		mut winn := win.graphics_context.win
		load_url(mut winn, this.url)
	}

	lbl.set_config(conf.size, false, conf.bold)
	lbl.pack()
	return lbl
}

// Eg: /test -> https://example.com/test
fn format_url(ref string, page_url string) string {
	mut href := ref

	if href.starts_with('./') {
		href = href.replace('./', '/')
	}

	if !(href.starts_with('http://') || href.starts_with('https://')) {
		// Not-Absolute URL
		if page_url.starts_with('file://') {
			return os.dir(page_url.split('file://')[1]) + '/' + href
		}

		if href.starts_with('/') {
			// Root
			test := page_url.split('?')[0].split('#')[0]
			href = test.split('//')[0] + '//' + test.split('//')[1].split('/')[0] + '/' + href
		} else {
			href = page_url.split('?')[0].split('#')[0] + '/' + href // TODO: handle prams.
		}
	}

	return href
}
