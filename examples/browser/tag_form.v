module main

import iui as ui
import net.html

fn handle_form_tags(mut win ui.Window, mut box ui.Box, sub &html.Tag, mut conf DocConfig) {
	nam := sub.name.to_upper()

	if nam == 'FORM' {
		if 'action' in sub.attributes {
			conf.action = sub.attributes['action']
		}
	}

	if nam == 'INPUT' {
		attr := sub.attributes.clone()
		typ := attr['type']
		mut size := 20 // 20 is Default value
		if 'size' in attr {
			size = attr['size'].int()
		}

		if typ == 'text' || 'type' !in attr {
			mut te := ui.textedit(win, '')
			te.draw_line_numbers = false
			te.code_syntax_on = false

			if 'name' in attr {
				conf.action = conf.action + '?' + attr['name'] + '='
			}

			te.set_bounds(0, 0, size * 8, 20)
			conf.last_need = te
			box.add_child(te)
		}

		if typ == 'submit' {
			mut btn := ui.button(win, attr['value'])
			btn.set_click_fn(form_submit, conf)
			btn.pack()
			box.add_child(btn)
		}
	}
}

fn form_submit(win_ptr voidptr, btn_ptr voidptr, data voidptr) {
	mut win := &ui.Window(win_ptr)
	conf := &DocConfig(data)
	te := &ui.TextEdit(conf.last_need)

	formatted_url := format_url(conf.action, conf.page_url)
	full_url := formatted_url + te.lines[0]

	load_url(mut win, full_url)
}
