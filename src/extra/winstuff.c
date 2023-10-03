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


// converts image data from the BGR format to the RGB format.
// It creates a copy of the input data, swaps the blue and red components of each pixel, and returns the modified copy.
unsigned char* ConvertBGRToRGB_(unsigned char* data, int width, int height, int bytesPerPixel) {
	unsigned char* copyData = malloc(width * height * bytesPerPixel);
	memcpy(copyData, data, width * height * bytesPerPixel);
	for (int i = 0; i < width * height * bytesPerPixel; i += bytesPerPixel) {
		unsigned char temp = copyData[i];
		copyData[i] = copyData[i + 2];
		copyData[i + 2] = temp;
	}
	return copyData;
}

// creates a bitmap in memory from pixel data provided as input. 
// The function first calls the ConvertBGRToRGB function to convert the input pixel data from BGR format to RGB format.
// This is necessary because the CreateDIBitmap function expects pixel data in RGB format.
HBITMAP CreateBitmapFromPixels_(HDC hdc,int width,int height,void *pixelss) {
	unsigned char* pixels = ConvertBGRToRGB_(pixelss, width, height, 4);

	BITMAPINFO bmi = {
	  .bmiHeader.biSize = sizeof(BITMAPINFOHEADER),
	  .bmiHeader.biWidth = width,
	  .bmiHeader.biHeight = -height,
	  .bmiHeader.biPlanes = 1,
	  .bmiHeader.biBitCount = 32,
	  .bmiHeader.biCompression = BI_RGB
	};

	HBITMAP hbm = CreateDIBitmap(hdc, &bmi.bmiHeader, CBM_INIT, pixels, &bmi, DIB_RGB_COLORS);
	free(pixels);

	return hbm;
}

// Native TextOut
unsigned char* i_txt_pix(char* txt, int len, int font_size, int *ww, int *hh, COLORREF tc) {
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

    // SetTextColor(mDC, RGB(0, 0, 0));
     SetTextColor(mDC, tc);
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