#include <Windows.h>
#include <stdio.h>

#ifndef OSDIALOG_MALLOC
#define OSDIALOG_MALLOC malloc
#endif

// Manually declare the OPENFILENAME structure
typedef struct tagOFNAa {
  DWORD         lStructSize;
  HWND          hwndOwner;
  HINSTANCE     hInstance;
  LPCSTR        lpstrFilter;
  LPSTR         lpstrCustomFilter;
  DWORD         nMaxCustFilter;
  DWORD         nFilterIndex;
  LPSTR         lpstrFile;
  DWORD         nMaxFile;
  LPSTR         lpstrFileTitle;
  DWORD         nMaxFileTitle;
  LPCSTR        lpstrInitialDir;
  LPCSTR        lpstrTitle;
  DWORD         Flags;
  WORD          nFileOffset;
  WORD          nFileExtension;
  LPCSTR        lpstrDefExt;
  LPARAM        lCustData;
  LPCSTR        lpTemplateName;
  LPCSTR        lpstrPrompt;
  void          *pvReserved;
  DWORD         dwReserved;
  DWORD         FlagsEx;
} OPENFILENAMEWa, *LPOPENFILENAMaE;

// BOOL WINAPI GetOpenFileName(LPOPENFILENAME lpofn);
