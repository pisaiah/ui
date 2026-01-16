module main

import os
import iui as ui

const home_folders = HomeFolders.new()
const home_path = os.home_dir()

struct HomeFolders {
mut:
	folders []string
	icons   []&ui.Image
	map     map[string]&ui.Image
}

fn HomeFolders.new() HomeFolders {
	mut hf := HomeFolders{}
	hf.init()
	return hf
}

fn (mut hf HomeFolders) init() {
	folds := [
		'Desktop',
		'Documents',
		'Pictures',
		'Downloads',
	]
	for fold in folds {
		folder := os.join_path(os.home_dir(), fold)
		hf.folders << fold
		icon := ui.Image.new(
			file: os.resource_abs_path('assets/${fold.to_lower()}.png')
			pack: true
		)
		hf.icons << icon
		hf.map[folder] = icon
	}
}
