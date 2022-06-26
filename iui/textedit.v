module iui

import gx

// Deprecated: TextEdit replaced by TextArea, just need to move a few things over.

// Syntax Highlight
pub struct SyntaxHighlighter {
pub mut:
	colors   map[string]gx.Color
	keywords map[string][]string
	between  map[string][]string
}

pub fn syntax_highlight_for_v() &SyntaxHighlighter {
	mut sh := &SyntaxHighlighter{}

	sh.colors['numbers'] = gx.rgb(240, 200, 0)
	sh.colors['decl'] = gx.rgb(0, 0, 200)
	sh.colors['string'] = gx.rgb(200, 100, 0)
	sh.colors['oper'] = gx.rgb(120, 81, 255)
	sh.colors['comment'] = gx.rgb(0, 150, 0)
	sh.colors['dec2'] = gx.rgb(0, 0, 255)
	sh.colors['dec3'] = gx.rgb(0, 0, 255)

	sh.keywords['numbers'] = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
	sh.keywords['decl'] = 'mut:,pub:,pub mut:,mut,pub ,unsafe ,default ,struct,type ,enum ,struct ,union ,const'.split(',')
	sh.keywords['dec2'] = ['import', 'break ', 'byte ', 'continue ', 'else ', 'false ', 'fn ',
		'for ', 'if ', 'import ', 'interface ']
	sh.keywords['dec3'] = 'is |module |return |select |shared |true |typeof union'.split('|')
	sh.keywords['oper'] = '[,],{,}'.split(',')
	sh.between['string'] = ["'", '"']
	sh.between['comment'] = ['//\n']

	return sh
}
