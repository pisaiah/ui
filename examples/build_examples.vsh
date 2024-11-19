#!/usr/bin/env -S v

import time

struct Data {
mut:
	failures []string = []string{}
	err      int
}

fn println_one_of_many(msg string, entry_idx int, entries_len int) {
	println('${entry_idx}/${entries_len} ${msg}')
}

fn (mut data Data) do_execute(cmd string, entry_idx int, entries_len int) {
	println_one_of_many('compile with: ${cmd}', entry_idx, entries_len)
	ret := execute(cmd)
	if ret.exit_code != 0 {
		data.err++
		eprintln('>>> FAILURE')
		data.failures << cmd
	}
}

// mut err := 0
// mut failures := []string{}

print('v version: ${execute('v version').output}')

examples_dir := join_path(@VMODROOT, 'examples')
mut all_entries := ls(examples_dir)!
mut all_entries2 := ls(join_path(examples_dir, 'Games'))!

all_entries.sort()
all_entries2.sort()

mut start := time.now()

mut data := &Data{}
mut entries := []string{}

for entry in all_entries {
	if (entry.contains('.') && !entry.contains('.v')) || entry.contains('.vsh')
		|| entry.contains('Games') || entry.starts_with('old') {
		continue
	}

	entries << entry
}

for entry in all_entries2 {
	entries << 'Games\\${entry}'
}

desk := join_path(home_dir(), 'Desktop')

other := [
	join_path(desk, 'paint'),
	join_path(desk, 'vide2'),
]

for entry in other {
	if is_dir(entry) {
		entries << entry
	}
}

chdir(examples_dir)!

mut threads := []thread{}

mut count := 0

for entry_idx, entry in entries {
	cmd := 'v -skip-unused ${entry}'
	// println_one_of_many('Creating thread with: ${cmd}', entry_idx, entries.len)
	ret := spawn data.do_execute(cmd, entry_idx, entries.len)
	threads << ret

	if count >= 8 {
		threads.wait()
		threads.clear()
		count = 0
		continue
	}

	count += 1

	// ret.wait()
	/*
	if ret.exit_code != 0 {
		err++
		eprintln('>>> FAILURE')
		failures << cmd
	}*/
}

threads.wait()

mut end := time.now()

println((end - start))

if data.err > 0 {
	err_count := if data.err == 1 { '1 error' } else { '${data.err} errors' }
	for f in data.failures {
		eprintln('> failed compilation cmd: ${f}')
	}
	eprintln('\nFailed with ${err_count}.')
	exit(1)
}
