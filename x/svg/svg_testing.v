//
// Module iui.x.svg - Experimental SVG <Path> support
// Copyright (C) 2025 Isaiah. All Rights Reserved.
//
// References:
// - https://www.w3schools.com/graphics/svg_path.asp
// - https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Element/svg
// - https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorials/SVG_from_scratch/Paths
// - https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Element/path
// - https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Attribute/d
// - https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Attribute/preserveAspectRatio
// - https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Attribute/viewBox
//
module svg

import iui as ui
import regex
import gx

// (Experimental) SVG
pub struct Svg {
	ui.Component_A
pub mut:
	paths           []string
	cmds            [][]Command
	viewbox         string
	preserve_aspect string = 'xMidYMid meet'
	ox              f32
	oy              f32
	sx              f32
	sy              f32
	color           ?gx.Color
	accent_first    int
}

@[params]
pub struct SvgConfig {
pub:
	path         string
	paths        []string
	viewbox      string
	width        int
	height       int
	accent_first int
	color        ?gx.Color
}

pub fn Svg.new(c SvgConfig) &Svg {
	mut svg := &Svg{
		paths:        if c.paths.len > 0 { c.paths } else { [c.path] }
		viewbox:      c.viewbox
		width:        c.width
		height:       c.height
		accent_first: c.accent_first
		color:        c.color
	}

	// Calculate viewbox
	svg.compute_viewbox()
	return svg
}

pub fn (s Svg) color(g &ui.GraphicsContext, idx int) gx.Color {
	if idx < s.accent_first {
		return g.theme.accent_fill
	}

	if s.color != none {
		return s.color
	}
	return g.theme.text_color
}

// Convert SVG x-pos into screen pos
pub fn (mut s Svg) x(x f32) f32 {
	return s.x + s.ox + (x * s.sx)
}

// Convert SVG y-pos into screen pos
pub fn (mut s Svg) y(y f32) f32 {
	return s.y + s.oy + (y * s.sy)
}

pub fn (mut s Svg) compute_viewbox() {
	sx, sy, ox, oy := compute_viewbox_xmidymid(s.viewbox, s.width, s.height)
	s.ox = ox
	s.oy = oy
	s.sx = sx
	s.sy = sy
}

// Draw our Svg
fn (mut this Svg) draw(g &ui.GraphicsContext) {
	// TODO: cache this array
	// commands := parse_svg_path(this.path)

	if this.width == 0 && this.height == 0 {
		values := this.viewbox.split(' ').map(it.f32())
		if values.len == 4 {
			this.width = int(values[2])
			this.height = int(values[3])
		}
	}

	if this.cmds.len == 0 {
		for path in this.paths {
			this.cmds << parse_svg_path(path)
		}
	}

	if this.sx == 0 || true {
		// TODO: cache this
		this.compute_viewbox()
	}

	for i, cmds in this.cmds {
		this.draw_path_gg(g, i, cmds)
	}
}

// SVG <Path> command
struct Command {
	cmd  string
	args []f32
}

// Parse the given data into SVG Command(s)
fn parse_svg_path(path_data string) []Command {
	mut re := regex.regex_opt(r'([MLCQAHVZmlcqahvz])([^MLCQAHVZmlcqahvz]*)') or { panic(err) }
	matches := re.find_all_str(path_data)
	mut commands := []Command{}

	for matchh in matches {
		cmd := matchh.split('')[0]
		raw_args := matchh.split(cmd)[1].split(' ').filter(it.len > 0)
		mut args := []f32{}
		for arg in raw_args {
			args << arg.f32()
		}
		commands << Command{cmd, args}
	}

	return commands
}

// Draw the path command
// M = move to, L=line, C=cubic, Q=Quadratic, H=Horizontal, V=Vertical, Z=End
fn (mut s Svg) draw_path_gg(g &ui.GraphicsContext, idx int, commands []Command) {
	mut last_x := f32(0.0)
	mut last_y := f32(0.0)

	for command in commands {
		match command.cmd {
			'M', 'm' {
				last_x = command.args[0]
				last_y = command.args[1]
			}
			'L', 'l' {
				g.gg.draw_line(s.x(last_x), s.y(last_y), s.x(command.args[0]), s.y(command.args[1]),
					s.color(g, idx))
				last_x = command.args[0]
				last_y = command.args[1]
			}
			'H', 'h' {
				g.gg.draw_line(s.x(last_x), s.y(last_y), s.x(command.args[0]), s.y(last_y),
					s.color(g, idx))
				last_x = command.args[0]
			}
			'V', 'v' {
				g.gg.draw_line(s.x(last_x), s.y(last_y), s.x(last_x), s.y(command.args[0]),
					s.color(g, idx))
				last_y = command.args[0]
			}
			'C', 'c' {
				// Cubic Bezier curve
				g.gg.draw_cubic_bezier([s.x(last_x), s.y(last_y),
					s.x(command.args[0]), s.y(command.args[1]),
					s.x(command.args[2]), s.y(command.args[3]),
					s.x(command.args[4]), s.y(command.args[5])], s.color(g, idx))

				last_x = command.args[4]
				last_y = command.args[5]
			}
			'Z', 'z' {
				// Close the path by drawing back to the initial move point
				// TODO: seems something is off here (see examples\demo)
				g.gg.draw_line(s.x(last_x), s.y(last_y), s.x(commands[0].args[0]), s.y(commands[0].args[1]),
					s.color(g, idx))
			}
			else {
				println('Unsupported command: ${command.cmd}')
			}
		}
	}
}

// Function to compute xMidYMid scaling & centering
fn compute_viewbox_xmidymid(viewbox_str string, new_width f32, new_height f32) (f32, f32, f32, f32) {
	values := viewbox_str.split(' ').map(it.f32())
	if values.len != 4 {
		panic('Invalid viewBox format')
	}

	// orig_x := values[0]
	// orig_y := values[1]
	orig_width := values[2]
	orig_height := values[3]

	// Compute scaling while maintaining aspect ratio
	scale := if (new_width / orig_width) < (new_height / orig_height) {
		new_width / orig_width
	} else {
		new_height / orig_height
	}

	// Calculate center offsets
	offset_x := (new_width - (orig_width * scale)) / 2
	offset_y := (new_height - (orig_height * scale)) / 2

	return scale, scale, offset_x, offset_y
}
