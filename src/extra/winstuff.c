#include <windows.h>
#include <stdio.h>
#include <wingdi.h>

// set the background mode to transparent
void fix_text_bg(HDC hdc) {
	SetBkMode(hdc, TRANSPARENT);
}

// set the text color
void iui_text_color(HDC hdc, COLORREF color) {
	SetTextColor(hdc, color);
}

HFONT iui_create_font(int size) {
	return CreateFont(size, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, ANSI_CHARSET, 
				OUT_DEFAULT_PRECIS, CLIP_DFA_DISABLE, DEFAULT_QUALITY, DEFAULT_PITCH, TEXT("Arial"));
}

SIZE iui_text_size(HDC hdc, char* text, int textLength) {
	SIZE size;

	// select a font into the device context
	//HFONT hFont = my_create_font(16);
	//SelectObject(hdc, hFont);

	// get the size of the text
	GetTextExtentPoint32(hdc, text, textLength, &size);
	
	//DeleteObject(hFont);

	// the width and height of the text are in the size structure
	return size;
}