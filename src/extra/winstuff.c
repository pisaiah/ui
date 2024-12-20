#include <windows.h>
#include <stdio.h>
#include <wingdi.h>

// #include <commctrl.h> // Include this header for DefSubclassProc

// Note: TCC does not have timeapi.h
#ifdef __V_GCC__
#include <timeapi.h> 
#endif

HWND get_hwnd();

// #ifndef get_hwnd
//HWND get_hwnd();

HWND get_hwnd_2() {
	if (!_sapp.valid) {
		// return get_hwnd();
	}
	
	return (HWND)sapp_win32_get_hwnd();
}
// #else 
/*
HWND get_hwnd_2() {
	return get_hwnd();
}
*/
// #endif

//
// Borderless Window API
//
static int borderless = 0;
static WNDPROC originalWindowProc;
static iui__Window* wind;

static int not_sokol = 0;

// have these here so gcc don't complain
VV_EXPORTED_SYMBOL bool iui_check_for_menuitem(iui__Window* w, int x, int y);
// VV_EXPORTED_SYMBOL voidptr iui_get_hwnd_2(iui__Window* win);

#define BUTTON_CLOSE 1

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wimplicit-function-declaration"
LRESULT CALLBACK CustomWindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam, UINT_PTR uIdSubclass, DWORD_PTR dwRefData) {
	switch (uMsg) {
		case WM_CREATE: {
			//CreateWindow("BUTTON", NULL, WS_VISIBLE | WS_CHILD, 760, 10, 30, 30, hwnd, (HMENU)BUTTON_CLOSE, NULL, NULL);
			break;
		}
		case WM_PAINT: {
			//if (borderless == 0) {
			//	CreateWindow("BUTTON", NULL, WS_VISIBLE | WS_CHILD, 760, 10, 30, 30, hwnd, (HMENU)BUTTON_CLOSE, NULL, NULL);
			//}
			//PAINTSTRUCT ps;
			//HDC hdc = BeginPaint(hwnd, &ps); // Draw the close button
			//RECT rect = {760, 10, 790, 40}; 
			//DrawFrameControl(hdc, &rect, DFC_CAPTION, DFCS_CAPTIONCLOSE); // Draw the minimize button 
			//rect.left = 720; rect.right = 750;
			//DrawFrameControl(hdc, &rect, DFC_CAPTION, DFCS_CAPTIONMIN); // Draw the maximize button
			//rect.left = 680; rect.right = 710; 
			//DrawFrameControl(hdc, &rect, DFC_CAPTION, DFCS_CAPTIONMAX); 
			//EndPaint(hwnd, &ps);
		}
		case WM_NCHITTEST: {
            LRESULT hit = originalWindowProc(hwnd, uMsg, wParam, lParam);
            if (hit == HTCLIENT) {
                POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
                ScreenToClient(hwnd, &pt);
                
				// TODO: Check for our menubar
				if (pt.y < 30) { // Make the top 30 pixels draggable
					if (iui_check_for_menuitem(wind, pt.x, pt.y)) {
						break;
					}
                    return HTCAPTION;
                }
            }
            return hit;
        }
		case WM_GETMINMAXINFO: {
            MINMAXINFO* mmi = (MINMAXINFO*)lParam;
            RECT workArea;
            SystemParametersInfo(SPI_GETWORKAREA, 0, &workArea, 0);
           //  mmi->ptMaxPosition.x = workArea.left;
            mmi->ptMaxPosition.y = workArea.top;
            // mmi->ptMaxSize.x = workArea.right - workArea.left;
            mmi->ptMaxSize.y = workArea.bottom - workArea.top + 6;
            return 0;
        }
		case WM_NCRBUTTONUP: { // Display the system menu at the cursor position
			POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
			HMENU hMenu = GetSystemMenu(hwnd, FALSE);
			if (hMenu) {
				TrackPopupMenu(hMenu, TPM_RIGHTBUTTON, pt.x, pt.y, 0, hwnd, NULL); 
			}
		}
		case WM_SYSCOMMAND: {
            // Handle system menu commands
            if ((wParam & 0xFFF0) == SC_CLOSE) {
                PostMessage(hwnd, WM_CLOSE, 0, 0);
            } else if ((wParam & 0xFFF0) == SC_MINIMIZE) {
                ShowWindow(hwnd, SW_MINIMIZE);
            } else if ((wParam & 0xFFF0) == SC_MAXIMIZE) {
                ShowWindow(hwnd, IsZoomed(hwnd) ? SW_RESTORE : SW_MAXIMIZE);
            } else {
                return DefWindowProc(hwnd, uMsg, wParam, lParam);
            }
        }
		
		case WM_NCCALCSIZE: {
			if (wParam == TRUE) {
				NCCALCSIZE_PARAMS* pncsp = (NCCALCSIZE_PARAMS*)lParam;
				pncsp->rgrc[0].top -= 6; // Adjust the top border
			}
			break;
		} 
		default:
			return originalWindowProc(hwnd, uMsg, wParam, lParam);
	}
	return originalWindowProc(hwnd, uMsg, wParam, lParam);
}

void win_post_control_message(int val) {
	//HWND hwnd = (HWND)sapp_win32_get_hwnd();
	HWND hwnd = get_hwnd_2(wind);
	if (val == 0) {
		PostMessage(hwnd, WM_CLOSE, 0, 0);
	} else if (val == 1) {
		ShowWindow(hwnd, SW_MINIMIZE);
	} else if (val == 2) {
		ShowWindow(hwnd, IsZoomed(hwnd) ? SW_RESTORE : SW_MAXIMIZE);
	} else {
	}
}
#pragma GCC diagnostic pop

// Modify the window style to make it borderless
void win_make_borderless(iui__Window* winn) {
	if (borderless == 1) {
		return;
	}

	
	wind = winn;
	//HWND hwnd = (HWND)sapp_win32_get_hwnd();
	HWND hwnd = get_hwnd_2(winn);
	LONG style = GetWindowLong(hwnd, GWL_STYLE);
	style &= ~(WS_CAPTION | WS_THICKFRAME);
	style |= WS_THICKFRAME;

	SetWindowLong(hwnd, GWL_STYLE, style);
	SetWindowPos(hwnd, NULL, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
	originalWindowProc = (WNDPROC)SetWindowLongPtr(hwnd, GWLP_WNDPROC, (LONG_PTR) CustomWindowProc);
	// SetWindowPos(hwnd, NULL, 0, 0, sapp_width() + 13, sapp_height() + 28, SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE);
	
	int width = 100;
	int height = 100;
	
	RECT rect;
	if (GetWindowRect(hwnd, &rect)) {
		width = rect.right - rect.left;
		height = rect.bottom - rect.top;
	}
	
	SetWindowPos(hwnd, NULL, 0, 0, width + 13, height + 28, SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE);

	borderless = 1;
}
// Borderless api end

int i_sleepy(int val) {
    timeBeginPeriod(val);
	Sleep(val);
	timeEndPeriod(val);
}

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