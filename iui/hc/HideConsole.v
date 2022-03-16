// Console Hider - Public Domain
module hc

//
// Note: For some reason "import gg to hide console" only works
//       for me while using tcc not gcc. (made sure to not use [console])
//
pub fn hide_console() {
	$if windows {
		hide_console_win()
	} $else {
		// Nope
	}
}
