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

HFONT iui_win_font(int size) {
	return CreateFont(size, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, ANSI_CHARSET, 
				OUT_DEFAULT_PRECIS, CLIP_DFA_DISABLE, DEFAULT_QUALITY, DEFAULT_PITCH, TEXT("Arial"));
}

SIZE iui_text_size(HDC hdc, char* txt, int len, int font_size) {
	SIZE size;

	HFONT font = iui_win_font(font_size);
	SelectObject(hdc, font);
	GetTextExtentPoint32(hdc, txt, len, &size);
	DeleteObject(font);

	return size;
}

// Native TextOut
unsigned char* iui_text_pix(char* txt, int len, int font_size, int *ww, int *hh) {
	HDC hdc = GetDC(NULL);
    HDC mDC = CreateCompatibleDC(hdc);
	
	HFONT font = iui_win_font(font_size);
	SelectObject(mDC, font);

	SIZE size;
	GetTextExtentPoint32(mDC, txt, len, &size);

	int wid = size.cx, hei = size.cy, chanls = 4;
	int total = wid * hei * chanls;

    HBITMAP bmap = CreateCompatibleBitmap(hdc, wid, hei);
    HBITMAP hOldBitmap = (HBITMAP)SelectObject(mDC, bmap);

    SetTextColor(mDC, RGB(0, 0, 0));
    SetBkColor(mDC, RGB(255, 255, 255));

    TextOut(mDC, 0, 0, txt, len);
	DeleteObject(font);

    BITMAPINFOHEADER bih = {0};
    bih.biSize = sizeof(BITMAPINFOHEADER);
    bih.biWidth = wid;
    bih.biHeight = -hei; // Flip
    bih.biPlanes = 1;
    bih.biBitCount = 32; // color depth
    bih.biCompression = BI_RGB;

    unsigned char* pixls;
    CreateDIBSection(mDC, (BITMAPINFO*)&bih, DIB_RGB_COLORS, &pixls, NULL, 0);
    GetDIBits(mDC, bmap, 0, hei, pixls, (BITMAPINFO*)&bih, DIB_RGB_COLORS);

	for (int i = 0; i < total; i += chanls) {
		int r = pixls[i], g = pixls[i + 1], b = pixls[i + 2], a = pixls[i + 3];

		if (!(r == 255 && g == 255 && b == 255)) {
			pixls[i + 3] = 255;
		}

		pixls[i + 0] = b; // Convert BGR to RGB
		pixls[i + 2] = r;
    }

    *ww = wid;
	*hh = hei;

	return pixls;
}