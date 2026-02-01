#!/usr/bin/env zsh

# define global array so completions will have access to the variable
typeset -g -a _REPO_SOURCES_DIRS=("$HOME/cs")

_repo_list_all_repos() {
	local pathname base

	# loop over all sources directories
	for dir in "${_REPO_SOURCES_DIRS[@]}"; do
		while IFS= read -r pathname; do
			# check if path is a directory or symlink to a directory
			[[ -d "$pathname" ]] || continue
			# get just the basename
			base="${pathname:t}"
			echo "$base"
			# search for directories and symlinks
		done < <(fd . "$dir" --max-depth 1 --type d --type l)
	done
}

_repo_find_match() {
	local search_term="$1"
	local pathname base

	# loop over all sources directories
	for dir in "${_REPO_SOURCES_DIRS[@]}"; do
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

	REPLY=""
}

repo() {
	local open_flag=0
	local repo_name

	# parse arguments for -o flag
	if [[ "$1" == "-o" ]]; then
		open_flag=1
		# remove flag from args
		shift
	fi

	# if no remaining args, use fzf to select repo
	if [[ $# -eq 0 ]]; then
		# get list of repo names and pipe to fzf
		repo_name="$(_repo_list_all_repos | fzf --height=40% --layout=reverse)"
		
		# if no selection made, exit
		if [[ -z "$repo_name" ]]; then
			return 0
		fi
	elif [[ $# -eq 1 ]]; then
		repo_name="$1"
	else
		echo "Usage: repo [-o] [repository name]"
		return 1
	fi

	# convert query into lowercase
	local search_term="${repo_name:l}"
	_repo_find_match "$search_term"
	local target=$REPLY

	# if target is not empty
	if [ -n "$target" ]; then
		# get absolute path to resolve symlinks
		local absolute_target="${target:A}"
		if [[ $open_flag -eq 1 ]]; then
			code "$absolute_target"
		else
			cd "$absolute_target" || return 1
		fi
	else
		echo "Repository not found: $repo_name"
		return 1
	fi
}

# tab completion for repo function
_repo_complete() {
	if [[ "$words[2]" == "-o" ]]; then
		# check that completions are for the second argument
		(( CURRENT == 3 )) || return 1
	else
		# check that completions are for the first argument
		(( CURRENT == 2 )) || return 1
	fi

	local -a repos
	
	# get list of repo names and convert to array, splitting on newlines
	repos=("${(@f)$(_repo_list_all_repos)}")

	_describe 'repositories' repos || compadd "${repos[@]}"
}

compdef _repo_complete repo
