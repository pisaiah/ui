// A simple web browser written in V
// Copyright (c) 2022, Isaiah.
//
// References:
// - https://www.w3schools.com/cssref/css_default_values.asp
//
module main

import iui as ui
import net.http
import net.html
import os
import time

struct DocConfig {
mut:
	page_url string
	bold     bool
	size     int
	href     string
	centered bool
}

fn load_url(mut win ui.Window, url string) {
	println('Loading URL: ' + url)

	start := time.now().unix_time_milli()

	config := http.FetchConfig{
		user_agent: 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0 FrogfindBrowser/0.1 FrogWeb/0.1'
	}
	resp := http.fetch(http.FetchConfig{ ...config, url: url }) or {
		println('failed to fetch data from the server')
		return
	}

	mut tb := &ui.Tabbox(win.get_from_id('tabbar'))

	ctab := tb.active_tab

	// Remove old content; 25 is height of the navbar
	tb.kids[ctab] = tb.kids[ctab].filter(it.y < 25 || it is ui.Menubar)

	// Background
	mut bg := bg_area(win)
	bg.set_bounds(0, 25, 0, 45)
	bg.draw_event_fn = width_draw_fn
	tb.add_child(tb.active_tab, bg)

	// TODO: Frogfind uses broken HTML (?)
	fixed_text := resp.text.replace('Find!</font></a></b>', 'Find!</font></b></a>').replace('<p> </small></p>',
		'<p></p>')

	mut doc := html.parse(fixed_text)
	mut root := doc.get_root()

	// mut vbox := ui.vbox(win)
	mut box := ui.box(win)

	// HTML body, margin of 8.
	box.set_bounds(8, 8, 900, 25)

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

	vbox.draw_event_fn = width_draw_fn
	vbox.set_bounds(0, 25, 900, 500) // TODO; size
	tb.add_child(tb.active_tab, vbox)

	end := time.now().unix_time_milli()
	set_status(mut win, 'Done. Took ' + (end - start).str() + 'ms')
}

fn set_conf_size(nam string, def int) int {
	if nam == 'small' {
		return -4
	}

	if nam == 'h1' {
		return 16
	}

	if nam == 'h2' {
		return 8
	}

	if nam == 'h3' {
		return 3 // 2.72
	}

	return def
}

fn render_tag_and_children(mut win ui.Window, mut box ui.Box, tag &html.Tag, mut conf DocConfig) {
	conf.size = set_conf_size(tag.name, conf.size)

	block_tags := ['H1', 'H2', 'H3', 'H4', 'H5', 'P', 'CENTER', 'UL', 'LI']

	for sub in tag.children {
		nam := sub.name.to_upper()

		set_status(mut win, 'Layouting ' + nam + '...')

		if nam == 'TITLE' {
			mut tb := &ui.Tabbox(win.get_from_id('tabbar'))
			if tb.active_tab != sub.content {
				tb.change_title(tb.active_tab, sub.content)
			}
			continue
		}

		if nam == 'BR' {
			box.add_break()
		}

		if nam in block_tags || nam == 'H3' {
			box.add_break()
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
			println('Image: ' + sub.str())
			img := handle_image(mut win, sub, conf)
			box.add_child(img)
			box.set_current_height(img.height)
			continue
		}

		conf.size = set_conf_size(sub.name, conf.size)

		if nam == 'INPUT' {
			attr := sub.attributes.clone()
			typ := attr['type']
			mut size := 20 // 20 is Default value
			if 'size' in attr {
				size = attr['size'].int()
			}

			if typ == 'text' {
				mut te := ui.textedit(win, '')
				te.draw_line_numbers = false
				te.code_syntax_on = false

				te.set_bounds(0, 0, size * 8, 20)
				box.add_child(te)
			}
		}

		if nam == 'A' {
			// Link
			conf.href = sub.attributes['href']
			if sub.content.len > 0 {
				mut lbl := create_hyperlink_label(win, sub.content, conf)
				box.add_child(lbl)
			}
		} else if conf.href.len > 0 {
			// Link
			mut lbl := create_hyperlink_label(win, sub.content, conf)
			box.add_child(lbl)
		} else {
			mut lbl := ui.label(win, sub.content)
			lbl.set_config(conf.size, false, conf.bold)
			lbl.pack()

			box.add_child(lbl)
		}
		if sub.children.len > 0 {
			render_tag_and_children(mut win, mut box, sub, mut conf)
		}

		if nam in block_tags {
			box.add_break()
		}

		// Reset config
		conf.bold = false
		conf.href = ''
		conf.centered = false
		if conf.size > 0 {
			conf.size = 0
		}
	}
	if tag.name == 'small' {
		conf.size = 0
	}
}

fn handle_image(mut win ui.Window, tag &html.Tag, conf DocConfig) &ui.Image {
	src := tag.attributes['src']

	fixed_src := format_url(src, conf.page_url)

	tmp := os.temp_dir()
	cache := os.real_path(tmp + '/v-browser-cache/')
	os.mkdir(cache) or {}

	out := os.real_path(cache + '/test.png')

	println('Loading image: ' + fixed_src)

	http.download_file(fixed_src, out) or { println(err) }

	bytes := os.read_bytes(out) or { [] }

	mut w := 10
	mut h := 10

	if 'width' in tag.attributes {
		w = tag.attributes['width'].int()
	}

	if 'height' in tag.attributes {
		h = tag.attributes['height'].int()
	}

	img := ui.image_from_byte_array_with_size(mut win, bytes, w, h)
	return img
}

fn create_hyperlink_label(win &ui.Window, content string, conf DocConfig) &ui.Hyperlink {
	mut href := format_url(conf.href, conf.page_url)

	mut lbl := ui.hyperlink(win, content, href)

	lbl.click_event_fn = fn (a voidptr) {
		mut this := &ui.Hyperlink(a)
		load_url(mut this.app, this.url)
	}

	lbl.set_config(conf.size, false, conf.bold)
	lbl.pack()
	return lbl
}

// Eg: /test -> https://example.com/test
fn format_url(ref string, page_url string) string {
	mut href := ref

	if !(href.starts_with('http://') || href.starts_with('https://')) {
		// Not-Absolute URL

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
