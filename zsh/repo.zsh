#!/usr/bin/env zsh

# define global array so completions will have access to the variable
typeset -ga sources_dirs=("$HOME/cs")

repo_find_match() {
	local search_term="$1"
	local pathname base

	# loop over all sources directories
	for dir in "${sources_dirs[@]}"; do
		while IFS= read -r pathname; do
			# check if path is a directory or symlink to a directory
			[[ -d "$pathname" ]] || continue
			# extract basename and convert to lowercase
			base="${pathname:t:l}"
			if [[ "$base" == "$search_term" ]]; then
				# return match
				REPLY="$pathname"
				return 0
			fi
			# search for directories and symlinks only one level deep in $dir, and search case-insensitively
		done < <(fd "$search_term" "$dir" --max-depth 1 --type d --type l --ignore-case)
	done

	return 1
}

repo() {
	# if no args or too many args passed
	if [ $# -ne 1 ]; then
		echo "Usage: repo <repository name>"
		return 1
	fi

	# convert query into lowercase
	local search_term="${1:l}"
	repo_find_match "$search_term"
	local target=$REPLY

	# if target is not empty
	if [ -n "$target" ]; then
		# get absolute path to resolve symlinks
		local absolute_target="${target:A}"
		cd "$absolute_target" || return 1
	else
		echo "Repository not found: $1"
		return 1
	fi
}

# tab completion for repo function
_repo_complete() {
	# check that completions are for the first argument
	(( CURRENT == 2 )) || return 1

	local -a repos
	local pathname base

	# loop over all sources directories
	for dir in "${sources_dirs[@]}"; do
		while IFS= read -r pathname; do
			# check if path is a directory or symlink to a directory
			[[ -d "$pathname" ]] || continue
			# get just the basename
			base="${pathname:t}"
			repos+=("$base")
			# search for directories and symlinks
		done < <(fd . "$dir" --max-depth 1 --type d --type l)
	done

	_describe 'repositories' repos || compadd "${repos[@]}"
}

compdef _repo_complete repo
