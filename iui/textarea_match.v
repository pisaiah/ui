// textarea_match.v
// A string matcher, used for TextArea.
// Ex:
//  	Input : 'mut str := test'
//  	Keys  : ['mut', ':=']
//  	Output: ['mut', ' str', ':=', ' test']
module iui

pub struct Group {
pub:
	start int = -1
	end   int = -1
}

fn make_match(in_col string, keys []string) []string {
	mut groups := []Group{}
	mut indx := 0

	for indx != -1 {
		indxx, keyy := get_nearest_match(keys, in_col, indx)

		group := Group{
			start: indxx
			end: indxx + keyy.len
		}

		indx = indxx + keyy.len

		if group.start > -1 && group.end > -1 {
			groups << group
		}
	}

	return make_group(in_col, groups)
}

fn get_nearest_match(keys []string, input string, start int) (int, string) {
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

fn make_group(input string, groups []Group) []string {
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
