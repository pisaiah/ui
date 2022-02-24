module iui

import gg
import gx
import time
import math

// Slider - implements Component interface
struct Slider {
	Component_A
pub mut:
	win            &Window
	text           string
	//click_event_fn fn (mut Window, Button)
    min f32
    cur f32
    max f32
    flip bool
    dir Direction
    last_s int
}

pub enum Direction {
    hor
    vert
}

// Return new Slider
pub fn slider(win &Window, min f32, max f32, dir Direction) &Slider {
	mut slid := &Slider{
		win: win
		text: 'TEST'
        min: min
        max: max
        dir: dir
	}
    //go test(mut slid)
    return slid
}

fn test(mut this &Slider) {
    
    for true {
        if this.flip {
            this.cur -= 1
        } else {
            this.cur += 1
        }
        if this.cur >= this.max {
            this.flip = true
        }
        if this.cur <= this.min {
            this.flip = false
        }
        time.sleep(10 * time.millisecond)
    }
}


// Draw this component
pub fn (mut this Slider) draw() {
    //println('SLIDER DRAW! ' + this.scroll_i.str())
    
    if this.is_mouse_down {        
        if this.dir == .hor {
            mut cx := math.clamp(this.win.mouse_x - this.x, 0, this.width)
            mut perr := cx / this.width
            perr = perr * this.max
            this.cur = f32(perr)
        } else {
            mut cx := math.clamp(this.win.mouse_y - this.y, 0, this.height)
            mut perr := cx / this.height
            perr = perr * this.max
            this.cur = f32(perr)
        }
    }

    // TODO: Scroll
    /*if this.last_s != this.scroll_i {
        mut pos := this.scroll_i > this.last_s
        mut diff := abs(this.scroll_i - this.last_s) + 1

        if pos {
            this.cur += diff
        } else {
            this.cur -= diff
        }
        this.cur = f32(math.clamp(this.cur, this.min, this.max))

        this.last_s = this.scroll_i
    }*/

    mut per := this.cur / this.max

    if this.dir == .hor {
        mut wid := (this.width * per)
        wid -= per * 20
    
        // Horizontal
        this.win.gg.draw_rect_filled(this.x + wid, this.y, 20, this.height, this.win.theme.scroll_bar_color)
        this.win.gg.draw_rect_empty(this.x, this.y, this.width, this.height, this.win.theme.button_border_normal)

        text := this.cur.str() + ' / ' + this.max.str()
        size := text_width(this.win, text) / 2
        sizh := text_height(this.win, text) / 2

        this.win.gg.draw_text((this.x + (this.width / 2)) - size, this.y + (this.height / 2) - sizh,
            text, gx.TextCfg{
            size: this.win.font_size
            color: this.win.theme.text_color
        })
    } else {
        mut wid := (this.height * per)
        wid -= per * 20

        // Vertical
        this.win.gg.draw_rect_filled(this.x, this.y + wid, this.width, 20, this.win.theme.scroll_bar_color)
        this.win.gg.draw_rect_empty(this.x, this.y, this.width, this.height, this.win.theme.button_border_normal)

        text := this.cur.str() + ' / ' + this.max.str()
        size := text_width(this.win, text) / 2
        sizh := text_height(this.win, text) / 2

        this.win.gg.draw_text((this.x + (this.width / 2)) - size, this.y + (this.height / 2) - sizh,
            text, gx.TextCfg{
            size: this.win.font_size
            color: this.win.theme.text_color
        })
    }
}
