#!/usr/bin/env -S v

fn println_one_of_many(msg string, entry_idx int, entries_len int) {
	eprintln('${entry_idx + 1:2}/${entries_len:-2} ${msg}')
}

print('v version: ${execute('v version').output}')

examples_dir := join_path(@VMODROOT, 'examples')
mut all_entries := ls(examples_dir)!
mut all_entries2 := ls(join_path(examples_dir, 'Games'))!

all_entries.sort()
all_entries2.sort()

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

mut err := 0
mut failures := []string{}
chdir(examples_dir)!
for entry_idx, entry in entries {
	cmd := 'v -skip-unused ${entry}'
	println_one_of_many('compile with: ${cmd}', entry_idx, entries.len)
	ret := execute(cmd)
	if ret.exit_code != 0 {
		err++
		eprintln('>>> FAILURE')
		failures << cmd
	}
}

if err > 0 {
	err_count := if err == 1 { '1 error' } else { '${err} errors' }
	for f in failures {
		eprintln('> failed compilation cmd: ${f}')
	}
	eprintln('\nFailed with ${err_count}.')
	exit(1)
}
