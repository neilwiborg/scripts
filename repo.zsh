#!/usr/bin/env zsh

typeset -ga sources_dirs=("$HOME/cs")

repo() {
	# if no args or too many args passed
	if [ $# -ne 1 ]; then
		echo "Usage: repo <repository name>"
		return 1
	fi

	# convert query into lowercase
	local search_term=$(echo "$1" | tr '[:upper:]' '[:lower:]')
	local target=""

	# loop over all sources directories
	for dir in "${sources_dirs[@]}"; do
		# search for directories and symlinks only one level deep in $sources_dir, and search case-insensitively
		target=$(find "$dir" -maxdepth 1 \( -type d -o -type l \) -iname "*$search_term*" | head -n 1)
		# if we find the target, then break
		[[ -n "$target" ]] && break
	done

	# if target is not empty
	if [ -n "$target" ]; then
		cd "$target" || return 1
	else
		echo "Repository not found: $1"
		return 1
	fi
}

# Tab completion for repo function
_repo_complete() {
	local -a repos
	# loop over all sources directories
	for dir in "${sources_dirs[@]}"; do
		# get just the basenames of all directories and symlinks and remove the first line ($sources_dir)
		repos+=($(find "$dir" -maxdepth 1 \( -type d -o -type l \) -exec basename {} \; | sed '1d'))
	done

	_describe 'repositories' repos || compadd "${repos[@]}"
}

compdef _repo_complete repo
