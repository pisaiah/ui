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
	mut neg := false

	for i, s in spl {
		if s in nums {
			cn = cn + s
		} else {
			if cn.len > 0 {
				if neg {
					val << '-' + cn
				} else {
					val << cn
				}
			}
			cn = ''

			if op.len > 0 && val.len > 1 {
				// dump(val)
				// dump(op)
				vvv := do_op(val[0] + op + val[1], op)
				op = ''
				val.clear()
				val << '${vvv}'
			}

			if s == '-' && (op.len > 0 || i == 0) {
				neg = true
			} else if s.trim(' ').len > 0 {
				op = s
				neg = false
			}
		}
	}
	if cn.len > 0 {
		val << cn
	}

	res := val.join(' ').f32()
	return res
}

fn do_op(input string, op string) f32 {
	mut res := input.f32()
	mut inp := input
	if op.contains('x') {
		spl := input.split('x')
		res = spl[0].f32() * spl[1].f32()
	}
	if op.contains('/') {
		spl := inp.split('/')
		res = spl[0].f32() / spl[1].f32()
	}
	if op.contains('+') {
		spl := inp.split('+')
		res = spl[0].f32() + spl[1].f32()
	}
	if op.contains('-') {
		spl := inp.split('-')
		res = spl[0].f32() - spl[1].f32()
	}
	return res
}
