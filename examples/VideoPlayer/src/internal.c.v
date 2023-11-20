// わたしの未成年観測
module main

// C Header(s) to include
$if !windows {
	#include <mpv/client.h>
	#include <mpv/render.h>
	#pkgconfig --libs --cflags mpv
} $else {
	#include <@VMODROOT/include/mpv/client.h>
	#include <@VMODROOT/include/mpv/render.h>
	#flag "@VMODROOT/libmpv-2.dll"
}

// Structs
pub type MPVHandle = voidptr
pub type MPVRenderContext = voidptr

@[typedef]
struct C.mpv_event_property {
pub:
	name   &u8
	format int
	data   &voidptr
}

pub type MPVEventProperty = C.mpv_event_property

@[typedef]
struct C.mpv_event {
pub:
	event_id int
	data     &MPVEventProperty
}

pub type MPVEvent = C.mpv_event

@[typedef]
struct C.mpv_render_param {
pub:
	@type int
	data  &voidptr
}

pub type MPVRenderParameter = C.mpv_render_param

// Functions
pub fn C.mpv_create() &MPVHandle
pub fn C.mpv_initialize(&MPVHandle) int
pub fn C.mpv_destroy(&MPVHandle)

pub fn C.mpv_observe_property(&MPVHandle, u64, &char, int) int

pub fn C.mpv_request_log_messages(&MPVHandle, &u8) int

pub fn C.mpv_render_context_create(&&MPVRenderContext, &MPVHandle, []MPVRenderParameter) int
pub fn C.mpv_render_context_render(&MPVRenderContext, []MPVRenderParameter) int
pub fn C.mpv_render_context_update(&MPVRenderContext) u64
pub fn C.mpv_render_context_free(&MPVRenderContext)

pub fn C.mpv_set_wakeup_callback(&MPVHandle, &voidptr, &voidptr)
pub fn C.mpv_render_context_set_update_callback(&MPVHandle, &voidptr, &voidptr)

pub fn C.mpv_command_async(&MPVHandle, u64, []&char) int

pub fn C.mpv_wait_event(&MPVHandle, f64) &MPVEvent

pub fn C.mpv_error_string(int) &char

pub fn C.mpv_set_property_string(&MPVHandle, &char, &char) int
