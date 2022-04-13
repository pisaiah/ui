module main

fn unescape(text string) string {
	return text.replace('&nbsp;', ' ').replace('&copy;', '©').replace('&raquo;', '»')
}
