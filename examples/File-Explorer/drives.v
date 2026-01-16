import os

fn C.GetLogicalDrives() u64
fn C.GetDriveTypeW(&u16) int
fn C.GetDiskFreeSpaceExW(&u16, &u64, &u64, int) bool

struct DriveInfo {
	path       string // Mount point or drive letter
	drive_type string // HDD, SSD, USB, SD, CD/DVD, Network, Unknown
	filesystem string // Filesystem type (NTFS, ext4, APFS, etc.)
	total_size u64    // Total size in bytes
	free_space u64    // Free space in bytes
}

pub fn (info DriveInfo) get_used() f32 {
	return f32(info.total_size - info.free_space) / f32(info.total_size)
}

pub fn (info DriveInfo) get_used_size() string {
	sfree := format_size2(info.free_space)
	stotal := format_size2(info.total_size)

	return '${sfree} free of ${stotal}'

	// return format_size2(info.get_used())
}

fn format_size2(bytes u64) string {
	kb := f32(bytes) / 1024.0
	if kb < 1024.0 {
		return '${kb:.2f} KB'
	}
	mb := kb / 1024.0
	if mb < 1024 {
		return '${mb:.2f} MB'
	}
	gb := mb / 1024.0
	return '${gb:.2f} GB'
}

// Note: GPT helped with DriveInfo

pub fn get_drives() []DriveInfo {
	mut drives := []DriveInfo{}

	$if windows {
		#include <windows.h>

		mask := C.GetLogicalDrives()
		for i in 0 .. 26 {
			if (mask >> i) & 1 == 1 {
				path := '${rune(`A` + i)}:\\'
				dtype := C.GetDriveTypeW(path.to_wide())
				drive_type := match dtype {
					C.DRIVE_FIXED { 'Fixed (HDD/SSD)' }
					C.DRIVE_REMOVABLE { 'Removable (USB/SD)' }
					C.DRIVE_CDROM { 'CD/DVD' }
					C.DRIVE_REMOTE { 'Network' }
					C.DRIVE_RAMDISK { 'RAM Disk' }
					else { 'Unknown' }
				}

				// Filesystem + size info via `GetDiskFreeSpaceExW`
				mut free_space := u64(0)
				mut total_size := u64(0)
				C.GetDiskFreeSpaceExW(path.to_wide(), &free_space, &total_size, 0)

				drives << DriveInfo{
					path:       path
					drive_type: drive_type
					filesystem: 'NTFS/FAT' // Simplified; full detection requires `GetVolumeInformationW`
					total_size: total_size
					free_space: free_space
				}
			}
		}
	} $else {
		// Unix-like systems
		if os.exists('/proc/mounts') {
			mounts := os.read_file('/proc/mounts') or { return drives }
			for line in mounts.split_into_lines() {
				parts := line.split(' ')
				if parts.len >= 3 {
					dev := parts[0]
					path := parts[1]
					fs := parts[2]

					// Try to detect type via /sys/block
					mut dtype := 'Unknown'
					if dev.starts_with('/dev/') {
						blk := dev.all_after('/dev/')
						rotational := os.read_file('/sys/block/${blk}/queue/rotational') or { '' }
						removable := os.read_file('/sys/block/${blk}/removable') or { '' }
						if removable.trim_space() == '1' {
							dtype = 'Removable (USB/SD)'
						} else if rotational.trim_space() == '1' {
							dtype = 'HDD'
						} else {
							dtype = 'SSD'
						}
					}

					// Size info via `statvfs`
					mut stat := C.statvfs{}
					if C.statvfs(path.str, &stat) == 0 {
						total_size := u64(stat.f_frsize) * u64(stat.f_blocks)
						free_space := u64(stat.f_frsize) * u64(stat.f_bavail)
						drives << DriveInfo{
							path:       path
							drive_type: dtype
							filesystem: fs
							total_size: total_size
							free_space: free_space
						}
					}
				}
			}
		} else {
			// macOS fallback using `df`
			df_out := os.execute('df -T').output
			for line in df_out.split_into_lines()[1..] {
				parts := line.split_whitespace()
				if parts.len >= 7 {
					dev := parts[0]
					fs := parts[1]
					path := parts[6]
					dtype := if 'disk' in dev { 'Fixed (HDD/SSD)' } else { 'Removable' }
					drives << DriveInfo{
						path:       path
						drive_type: dtype
						filesystem: fs
						total_size: 0 // parsing size from df output is possible
						free_space: 0
					}
				}
			}
		}
	}

	return drives
}
