// basic_css.v:
//
// Very basic CSS parser
//
module main

import gx

struct StyleSheet {
pub mut:
	rules map[string]map[string]string
}

struct Rule {
pub mut:
	key   string
	value string
}

// Parses a CSS color string to gx.Color
fn parse_color(val string) gx.Color {
    if val.starts_with('rgb(') {
        inside := val.split('rgb(')[1].split(')')[0]
        splt := inside.split(',')
        if splt.len == 3 {
            r := splt[0].trim_space().byte()
            g := splt[1].trim_space().byte()
            b := splt[2].trim_space().byte()
            return gx.rgb(r, g, b)
        }
    }
    
    if val.starts_with('#') {
        
    }
    
    return gx.white
}

// Parse CSS content into a StyleSheet
fn parse_css(val string) &StyleSheet {
	mut ss := &StyleSheet{}

	lines := val.split_into_lines()

	mut current_id := ''

	for line in lines {
		trimed := line.trim_space()

		if trimed.len == 0 {
			continue
		}

		if trimed.ends_with('{') {
			current_id = trimed.split('{')[0].trim_space()
		}

		if trimed.contains(':') {
			spl := trimed.split(':')
			rule := Rule{spl[0].trim_space(), spl[1].trim_space().replace(';', '')}
			ss.rules[current_id][rule.key] = rule.value
		}
	}
    dump(ss) // debug
	return ss
}
