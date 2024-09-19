// textarea_match.v
// A string matcher, used for TextArea.
// Ex:
//  	Input : 'mut str := test'
//  	Keys  : ['mut', ':=']
//  	Output: ['mut', ' str', ':=', ' test']
module iui

import gg

pub const keys = ['fn', 'mut', '// ', '\t', "'", '(', ')', ' as ', '/*', '*/']

pub const numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'if', 'else', 'for']

pub const blue_keys = ['fn', 'module', 'import', 'interface', 'map', 'assert', 'sizeof', 'typeof',
	'mut', '[', ']']

pub const purp_keys = ' int,i8,i16,i64,i128,u8,u16,u32,u64,u128,f32,f64, bool, byte,byteptr,charptr, voidptr,string,ustring, rune,(,)'.split(',')

pub const red_keys = '||,&&,&,=,:=,==,<=,>=,>,<,!'.split(',')

pub const colors = 'blue,red,green,yellow,orange,purple,black,gray,pink,white'.split(',')

fn is_enter(key gg.KeyCode) bool {
	return key == .enter || key == .kp_enter
}

pub fn get_line_height(ctx &GraphicsContext) int {
	return ctx.line_height + 2
}

pub struct Group {
pub:
	start int = -1
	end   int = -1
}

pub fn make_match(in_col string, keys []string) []string {
	mut groups := []Group{}
	mut indx := 0

	for indx != -1 {
		indxx, keyy := get_nearest_match(keys, in_col, indx)

		group := Group{
			start: indxx
			end:   indxx + keyy.len
		}

		indx = indxx + keyy.len

		if group.start > -1 && group.end > -1 {
			groups << group
		}
	}

	return make_group(in_col, groups)
}

pub fn get_nearest_match(keys []string, input string, start int) (int, string) {
	mut low_indx := input.len
	mut low_key := ''

	for key in keys {
		indx := input.index_after(key, start)
		if indx != -1 {
			if indx < low_indx {
				low_indx = indx
				low_key = key
			}
		}
	}

	if low_key == '' {
		return -1, ''
	}
	return low_indx, low_key
}

pub fn make_group(input string, groups []Group) []string {
	mut res := []string{}

	for i in 0 .. groups.len {
		group := groups[i]
		if i == 0 {
			res << input.substr_ni(0, group.start)
		}

		res << input.substr_ni(group.start, group.end)
		if i < groups.len - 1 {
			nxt := groups[i + 1]
			res << input.substr_ni(group.end, nxt.start)
		} else {
			res << input[group.end..input.len]
		}
	}

	if res.len == 0 {
		return [input]
	}

	return res
}
