#!/usr/bin/env zsh

typeset -g sources_dir="$HOME/cs"

repo() {
	if [ $# -eq 0 ]; then
		echo "Usage: repo <repository name>"
		return 1
	fi

	local search_term=$(echo "$1" | tr '[:upper:]' '[:lower:]')
	local target=$(find "$sources_dir" -maxdepth 1 \( -type d -o -type l \) -iname "*$search_term*" | head -n 1)

	if [ -n "$target" ]; then
		cd "$target" || return 1
	else
		echo "Repository not found: $1"
		return 1
	fi
}

# Tab completion for repo function
_repo_complete() {
	local repos=($(find "$sources_dir" -maxdepth 1 \( -type d -o -type l \) -exec basename {} \; | sed '1d'))
	_describe 'repositories' repos || compadd "${repos[@]}"
}

compdef _repo_complete repo
