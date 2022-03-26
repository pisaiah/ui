module main

import iui as ui
import net.http
import net.html

struct DocConfig {
mut:
	page_url string
	bold     bool
	size     int
	href     string
	centered bool
}

fn load_url(win &ui.Window, url string) {
	println('Loading URL: ' + url)

	config := http.FetchConfig{
		user_agent: 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0 FrogfindBrowser/0.1 FrogWeb/0.1'
	}
	resp := http.fetch(http.FetchConfig{ ...config, url: url }) or {
		println('failed to fetch data from the server')
		return
	}

	mut tb := &ui.Tabbox(win.get_from_id('tabbar'))

	ctab := tb.active_tab

	tb.kids[ctab] = tb.kids[ctab].filter(mut it !is ui.VBox)

	mut doc := html.parse(resp.text)
	mut root := doc.get_root()

	// mut vbox := ui.vbox(win)
	mut box := ui.box(win)
	box.set_bounds(0, 0, 900, 25)

	mut conf := &DocConfig{
		page_url: url
	}

	// root.children.len == 1 (html tag)
	for tag in root.children {
		if tag.name == 'meta' {
			continue
		}

		test(win, mut box, tag, mut conf)
	}
	mut vbox := box.get_vbox()

	vbox.draw_event_fn = width_draw_fn
	vbox.set_bounds(0, 25, 900, 500) // TODO; size
	tb.add_child(tb.active_tab, vbox)
}

fn test(win &ui.Window, mut box ui.Box, tag &html.Tag, mut conf DocConfig) {
	if tag.name == 'small' {
		conf.size = -4
	}

	if tag.name == 'h3' {
		conf.size = 3 // 2.72
	}

	if tag.name == 'h1' {
		conf.size = 16
	}

	for sub in tag.children {
		nam := sub.name.to_upper()

		if nam == 'TITLE' {
			mut tb := &ui.Tabbox(win.get_from_id('tabbar'))
			if tb.active_tab != sub.content {
				tb.change_title(tb.active_tab, sub.content)
			}
			continue
		}

		if nam == 'BR' {
			box.add_break() // <br>
			continue
		}

		if nam == 'H1' || nam == 'H2' || nam == 'H3' || nam == 'H4' || nam == 'p' || nam == 'CENTER' {
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

		if nam == 'SMALL' {
			conf.size = -4
		}

		if nam == 'H3' {
			conf.size = 3
		}

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
			test(win, mut box, sub, mut conf)
		}

		if nam == 'H1' || nam == 'H2' || nam == 'H3' || nam == 'H4' || nam == 'p' {
			box.add_break()
		}

		// Reset config
		conf.bold = false
		conf.href = ''
		conf.centered = false
	}
}

fn create_hyperlink_label(win &ui.Window, content string, conf DocConfig) &ui.Hyperlink {
	mut href := conf.href

	if !href.starts_with('http://') {
		// Absolute URL
		href = conf.page_url.split('?')[0].split('#')[0] + '/' + href // TODO: handle prams.
	}

	mut lbl := ui.hyperlink(win, content, href)

	lbl.click_event_fn = fn (a voidptr) {
		this := &ui.Hyperlink(a)
		load_url(this.app, this.url)
	}

	lbl.set_config(conf.size, false, conf.bold)
	lbl.pack()
	return lbl
}
