module main

import gg
import iui as ui { debug }
import net.http
import net.html

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.get_system_theme(), 'My Window', 800, 480)

    mut title_box := ui.vbox(window)
    title_box.set_id(mut window, 'vbox')

    make_title(window, mut title_box)

    mut hbox := ui.hbox(window)

    sections := ['TOP', 'WORLD', 'NATION', 'BUSINESS', 'TECHNOLOGY', 'SPORTS', 'SCIENCE', 'HEALTH']
    for section in sections {
        mut btn := ui.button(window, section)
        btn.draw_event_fn = section_btn_draw
        btn.set_bounds(0, 0, 90, 30)
        hbox.add_child(btn)
    }

    hbox.set_pos(0, 0)
    hbox.set_width_as_percent(true, 100)
    title_box.add_child(hbox)

    window.add_child(title_box)
    
    parse_section(mut window, '', mut title_box)

	window.gg.run()
}

fn make_title(window &ui.Window, mut vbox &ui.VBox) {
    mut title := ui.label(window, '68k.news in an app')
    title.draw_event_fn = center_title
    title.set_config(16, false, true)
    title.pack()
    vbox.children.insert(0, [title])
}

fn parse_section(mut win &ui.Window, section string, mut vbox &ui.VBox) {
    text := http.get_text('http://68k.news' + section)

    indx  := text.index_after('<h3><font size="5">', 0)
    mut start := text.substr(indx, text.len - indx)

    start = start.replace('</small></p>', '</small></p></div>')
    start = start.replace('<h3><font size="5">', '<div id="article"><h3><font size="5">')

    dom := html.parse('<html><body>' + start)

    mut lbl := ui.label(win, ' ')
    lbl.set_bounds(0, 0, 40, 30)
    vbox.add_child(lbl)

    for tag in dom.get_tag('div') {
        art := get_tag(tag, 1)

        mut title := art.title.split('{URL')[0]
        mut links := art.links.split('\n')

        mut title_lbl := ui.label(win, ' ' + title)
        title_lbl.set_config(4, false, true)
        title_lbl.pack()
        vbox.add_child(title_lbl)

        for link in links {
            mut con := link.split('{URL:')
            win.extra_map[con[0]] = con[1].split('&a=')[1]
        
            mut link_lbl := ui.label(win, con[0])
            link_lbl.click_event_fn = fn (mut win ui.Window, com ui.Label) {
                ui.open_url('http://68k.news/article.php?a=' + win.extra_map[com.text])
            }
            link_lbl.pack()
            vbox.add_child(link_lbl)
        }

        mut lbl_ := ui.label(win, ' ')
        lbl_.set_bounds(0, 0, 40, 15)
        vbox.add_child(lbl_)
    }
}

struct Article {
    title string
    links string //[]&html.Tag
}

fn get_tag(tag &html.Tag, tabs int) &Article {
    mut txt := ''
    mut new_tabs := tabs

    mut title := ''

    for child in tag.children {
    
        if child.name == 'a' {
            if child.children.len == 0 {
                title = child.content
            }
        }

        if child.content.len > 0 {
            if child.name == 'a' {
                txt += '\t'.repeat(tabs) + child.content + '\n'
            } else {
                txt += '\t'.repeat(tabs) + '(' + child.name +  ')' + child.content + '\n'
            }
            new_tabs += 1
        }
        
        c_text := get_tag_links(child, new_tabs)
        
        if !c_text.contains('(text)') {
            title = c_text
        } else {
            txt += c_text.replace('\t(text)', ' - ')
        }
    }

    return &Article{
        title: title.trim('\n').trim('\t')
        links: txt.trim('\n')
    }
}

fn get_tag_links(tag &html.Tag, tabs int) string {
    mut txt := ''
    mut new_tabs := tabs

    mut url := ''

    for child in tag.children {
        if child.content.len > 0 {
            
            if url.len == 0 {
                url = child.attributes['href']
            }
            if child.name == 'a' {
                txt += '\t'.repeat(tabs) + child.content
            } else {
                txt += '\t'.repeat(tabs) + '(' + child.name +  ')' + child.content
            }
        }
        txt += get_tag_links(child, new_tabs)
    }
    
    if url.len > 0 {
        txt = txt + ' {URL:' + url + '\n'
    }
    
    return txt
}

fn center_title(mut win ui.Window, com &ui.Component) {
    size := gg.window_size()
    half_size := size.width / 2
    
    mut this := *com
    this.x = half_size - (this.width / 2)
    
}

fn section_btn_draw(mut win ui.Window, com &ui.Component) {
    size := gg.window_size()

    mut this := *com
    this.width = size.width / 8
    
    if this.is_mouse_rele {
        mut vbox := &ui.VBox(win.get_from_id('vbox'))
        vbox.children = vbox.children.filter(mut it !is ui.Label)
        this.is_mouse_rele = false
        make_title(win, mut vbox)
        parse_section(mut win, '?section=' + this.text + '&loc=US', mut vbox)
    }
}

fn on_click(mut win ui.Window, com ui.Button) {
	debug('on_click')
}

fn theme_click(mut win ui.Window, com ui.MenuItem) {
	text := com.text
	// debug(text)
	mut theme := ui.theme_by_name(text)
	win.set_theme(theme)
}