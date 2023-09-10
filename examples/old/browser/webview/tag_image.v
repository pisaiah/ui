module webview

import iui as ui
import net.html
import net.http
import os
import encoding.base64

fn handle_image(mut win ui.Window, tag &html.Tag, conf DocConfig) &ui.Image {
	src := tag.attributes['src']

	tmp := os.temp_dir()
	cache := os.real_path(tmp + '/v-browser-cache/')
	os.mkdir(cache) or {}

	mut w := -1
	mut h := 10

	if 'width' in tag.attributes {
		w = tag.attributes['width'].int()
	}

	if 'height' in tag.attributes {
		h = tag.attributes['height'].int()
	}

	if src.starts_with('data:') && src.contains('base64') {
		// Base64 encoded image
		encoded := src.split('base64,')[1]

		decode_str := base64.decode_str(encoded)
		out := os.real_path(cache + '/base64-' + os.base(encoded) + '.png')
		os.write_file(out, decode_str) or {}

		gg_img := win.gg.create_image(out)
		if w == -1 {
			w = gg_img.width
			h = gg_img.height
		}

		img := ui.image_with_size(win, gg_img, w, h)

		return img
	}

	fixed_src := format_url(src, conf.page_url)

	mut out := os.real_path(cache + '/' + os.base(fixed_src).replace(':', '_'))

	println('Loading image: ' + fixed_src)

	if os.exists(fixed_src) {
		// Local file
		out = fixed_src
	} else {
		http.download_file(fixed_src, out) or { println(err) }
	}

	gg_img := win.gg.create_image(out)
	if w == -1 {
		w = gg_img.width
		h = gg_img.height
	}

	img := ui.image_with_size(win, gg_img, w, h)

	return img
}
