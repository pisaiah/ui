#include <stdio.h>
#include <windows.h>

bool need = true;

static float SECC = 1000;
static int FPS = (int)(((float)1000) / 60);
static bool i_power_save = false;

void i_set_power_save(bool value) {
	i_power_save = value;
}

void i_set_fps(int new_value) {
	FPS = (int)(((float)1000) / new_value);
}

float get_refresh_rate() {
    DEVMODE lpDevMode;
    memset(&lpDevMode, 0, sizeof(DEVMODE));
    lpDevMode.dmSize = sizeof(DEVMODE);
    lpDevMode.dmDriverExtra = 0;

    if (EnumDisplaySettings(NULL, ENUM_CURRENT_SETTINGS, &lpDevMode) == 0) {
        return 60;
    } else {
        return lpDevMode.dmDisplayFrequency;
    }
}

static LARGE_INTEGER frequency, t1, t2, t3; 
static int frequency_set = 0;

int our_sleep(int period, int val) {
    timeBeginPeriod(period);
	Sleep(val);
	timeEndPeriod(period);
}

void i_sleep(int u) {
	if (i_power_save) {
		// Avoid using CPU-heavy Windows's Timer API
		Sleep(1);
		return;
	}
	
	if (0 == frequency_set) {
		QueryPerformanceFrequency(&frequency);
		QueryPerformanceCounter(&t1);
		frequency_set = 1;
	}
	
	LONGLONG elapsed;
	do {
		our_sleep(1, 1);
		QueryPerformanceCounter(&t2);
		elapsed = (t2.QuadPart - t1.QuadPart) * 1000 / frequency.QuadPart;
	} while (elapsed < u);
	
	t1 = t2;
}

// We override the frame loop with our own FPS limit,
// As sokol/gl's SwapBuffers + VSYNC does play well on Windows.
// (Tested on N4020, We go from ~90% CPU to ~8% CPU, for the same 48 Hz)
void _sapp_win32_run_2(const sapp_desc* desc) {
	_sapp_init_state(desc);
	_sapp.swap_interval = 0; // iui: override swap_interval for performance
	
	_sapp_win32_init_console();
	_sapp.win32.is_win10_or_greater = _sapp_win32_is_win10_or_greater();
	_sapp_win32_init_keytable();
	_sapp_win32_utf8_to_wide(_sapp.window_title, _sapp.window_title_wide, sizeof(_sapp.window_title_wide));
	_sapp_win32_init_dpi();
	_sapp_win32_init_cursors();
	_sapp_win32_create_window();
	sapp_set_icon(&desc->icon);
	#if defined(SOKOL_D3D11)
		_sapp_d3d11_create_device_and_swapchain();
		_sapp_d3d11_create_default_render_target();
	#endif
	#if defined(SOKOL_GLCORE)
		_sapp_wgl_init();
		_sapp_wgl_load_extensions();
		_sapp_wgl_create_context();
	#endif
	_sapp.valid = true;

	int rr = (int)(1000 / get_refresh_rate());
	// printf("%i RR\n", rr);
	bool done = false;
	while (!(done || _sapp.quit_ordered)) {
		_sapp_win32_timing_measure();
		MSG msg;

		while (PeekMessageW(&msg, NULL, 0, 0, PM_REMOVE)) {
			if (WM_QUIT == msg.message) {
				done = true;
				continue;
			} else {
				TranslateMessage(&msg);
				DispatchMessageW(&msg);
			}
		}
		
		_sapp_frame();
		#if defined(SOKOL_D3D11)
			_sapp_d3d11_present(false);
		#endif	
		
		if (IsIconic(_sapp.win32.hwnd)) {
			Sleep(500);
		}

		#if defined(SOKOL_GLCORE)
			if (_sapp.swap_interval == 0) {
				i_sleep(FPS);
			}
		   _sapp_wgl_swap_buffers();
		#endif

		if (_sapp_win32_update_dimensions()) {
			#if defined(SOKOL_D3D11)
				_sapp_d3d11_resize_default_render_target();
			#endif
			_sapp_win32_app_event(SAPP_EVENTTYPE_RESIZED);
		}

		if (_sapp_win32_update_monitor()) {
			_sapp_timing_reset(&_sapp.timing);
		}
		if (_sapp.quit_requested) {
			PostMessage(_sapp.win32.hwnd, WM_CLOSE, 0, 0);
		}
	}
	_sapp_call_cleanup();

	#if defined(SOKOL_D3D11)
		_sapp_d3d11_destroy_default_render_target();
		_sapp_d3d11_destroy_device_and_swapchain();
	#else
		_sapp_wgl_destroy_context();
		_sapp_wgl_shutdown();
	#endif
	_sapp_win32_destroy_window();
	_sapp_win32_destroy_icons();
	_sapp_win32_restore_console();
	_sapp_discard_state();
}


SOKOL_API_IMPL void sapp_run_2(const sapp_desc* desc) {
	SOKOL_ASSERT(desc);
	#if defined(_SAPP_MACOS)
		_sapp_macos_run(desc);
	#elif defined(_SAPP_IOS)
		_sapp_ios_run(desc);
	#elif defined(_SAPP_EMSCRIPTEN)
		_sapp_emsc_run(desc);
	#elif defined(_SAPP_WIN32)
		_sapp_win32_run_2(desc);
	#elif defined(_SAPP_LINUX)
		_sapp_linux_run(desc);
	#else
	#error "sapp_run() not supported on this platform"
	#endif
}

#define sapp_run(x) sapp_run_2(x)
