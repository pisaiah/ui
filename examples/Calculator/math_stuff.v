// This file contains the non-ui related stuff for Calculator
module main

fn compute_value(input string) f32 {
	ops := ['x', '+', '/', '-']
	mut has_op := false
	for op in ops {
		if input.contains(op) {
			has_op = true
			break
		}
	}
	if !has_op {
		return input.f32()
	}

	mut nums := ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.']

	mut val := []string{}
	mut spl := (input + ' ').split('')

	mut cn := ''
	mut op := ''

	for s in spl {
		if s in nums {
			cn = cn + s
		} else {
			if cn.len > 0 {
				val << cn
			}
			cn = ''

			if op.len > 0 && val.len > 1 {
				vvv := do_op(val[0] + op + val[1])
				op = ''
				val.clear()
				val << '${vvv}'
			}
			if s.trim(' ').len > 0 {
				op = s
			}
		}
	}
	if cn.len > 0 {
		val << cn
	}

	res := val.join(' ').f32()
	return res
}

fn do_op(input string) f32 {
	mut res := input.f32()
	if input.contains('x') {
		spl := input.split('x')
		res = spl[0].f32() * spl[1].f32()
	}
	if input.contains('+') {
		spl := input.split('+')
		res = spl[0].f32() + spl[1].f32()
	}
	if input.contains('/') {
		spl := input.split('/')
		res = spl[0].f32() / spl[1].f32()
	}
	if input.contains('-') {
		spl := input.split('-')
		res = spl[0].f32() - spl[1].f32()
	}
	return res
}
