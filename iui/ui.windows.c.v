module iui

fn C.MessageBox(h voidptr, text &u16, caption &u16, kind u32) int

// Native Message Box
// TODO: non-native message box
pub fn message_box(title string, s string) {
	C.MessageBox(0, s.to_wide(), title.to_wide(), C.MB_OK)
}
