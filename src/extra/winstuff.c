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

SIZE iui_text_size(HDC hdc, char* text, int textLength, int font_size) {
	SIZE size;

	HFONT hFont = iui_create_font(font_size);
	SelectObject(hdc, hFont);
	GetTextExtentPoint32(hdc, text, textLength, &size);
	DeleteObject(hFont);

	return size;
}

// Native TextOut
unsigned char* iui_draw_text_to_pix(char* text, int textLength, int font_size, int *ww, int *hh) {
	HDC hdc = GetDC(NULL);
    HDC memDC = CreateCompatibleDC(hdc);
	
	HFONT hFont = iui_create_font(font_size);
	SelectObject(memDC, hFont);

	SIZE size;
	GetTextExtentPoint32(memDC, text, textLength, &size);

	int width = size.cx;
	int height = size.cy;
	int channels = 4;
	int numPixels = width * height * channels;

	// Create an HDC and an HBITMAP
    HBITMAP hBitmap = CreateCompatibleBitmap(hdc, width, height);
    HBITMAP hOldBitmap = (HBITMAP)SelectObject(memDC, hBitmap);

    // Set the text color and background color
    SetTextColor(memDC, RGB(0, 0, 0));
    SetBkColor(memDC, RGB(255, 255, 255));

    TextOut(memDC, 0, 0, text, textLength);
	DeleteObject(hFont);

    // Create a pixel array to store the image data
    BITMAPINFOHEADER bmiHeader = {0};
    bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
    bmiHeader.biWidth = width;
    bmiHeader.biHeight = -height; // Negative height to flip the image
    bmiHeader.biPlanes = 1;
    bmiHeader.biBitCount = 32; // 32-bit color depth
    bmiHeader.biCompression = BI_RGB;

    unsigned char* pixels;
    HBITMAP hDIB = CreateDIBSection(memDC, (BITMAPINFO*)&bmiHeader, DIB_RGB_COLORS, &pixels, NULL, 0);

    // Copy the bitmap data to the DIB section
    GetDIBits(memDC, hBitmap, 0, height, pixels, (BITMAPINFO*)&bmiHeader, DIB_RGB_COLORS);

	for (int i = 0; i < numPixels; i += channels) {
		int r = pixels[i + 0];
		int g = pixels[i + 1];
		int b = pixels[i + 2];
		int a = pixels[i + 3];
		
		if (r == 255 && g == 255 && b == 255) {
		} else {
			pixels[i + 3] = 255;
		}
		// BGR to RGB
		pixels[i + 0] = b;
		pixels[i + 2] = r;
    }

    *ww = width;
	*hh = height;

	return pixels;
}