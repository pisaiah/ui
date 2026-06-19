/**
 * Open File Dialog without linking -lcomdlg32
 * as TCC does not include the header file commdlg.h.
 */

#include <Windows.h>
#include <stdio.h>
#include <commdlg.h>
// #include <dialogs_win.h>

// int win_open_file_dialog() {
	
static char* wchar_to_utf8(const wchar_t* s) {
	if (!s)
		return NULL;
	int len = WideCharToMultiByte(CP_UTF8, 0, s, -1, NULL, 0, NULL, NULL);
	if (!len)
		return NULL;
	char* r = OSDIALOG_MALLOC(len);
	WideCharToMultiByte(CP_UTF8, 0, s, -1, r, len, NULL, NULL);
	return r;
}
	
char * win_open_file_dialog(char const * aTitle) {
    OPENFILENAME ofn;
    wchar_t szFile[MAX_PATH] = L"";

    ZeroMemory(&ofn, sizeof(ofn));
    ofn.lStructSize = sizeof(ofn);
    ofn.hwndOwner = NULL;
    ofn.lpstrFile = szFile;
    ofn.nMaxFile = sizeof(szFile);
    // ofn.lpstrFilter = "All Files (*.*)\0*.*\0";
    ofn.nFilterIndex = 1;
    ofn.lpstrFileTitle = NULL;
    ofn.nMaxFileTitle = 0;
    ofn.lpstrInitialDir = NULL;
    ofn.Flags = 0x00000001 | 0x00001000;


    if (GetOpenFileNameW(&ofn)) {
        printf("Selected file: %s\n", szFile);
        // Now you can use 'szFile' for further processing.
		return wchar_to_utf8(szFile);
    } else {
        printf("User canceled the file selection.\n");
		return "";
    }

    return "";
}