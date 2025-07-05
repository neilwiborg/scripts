#!/usr/bin/env zsh

typeset -A MARKED_LOCATIONS

mark() {
  if [[ "$1" == "--clear" || "$1" == "-c" ]]; then
    if [[ $# -eq 1 ]]; then
      if [[ -v MARKED_LOCATIONS[default] ]]; then
	unset 'MARKED_LOCATIONS[default]'
	echo "Default mark cleared"
      else
	echo "No default mark set"
      fi
    elif [[ $# -eq 2 ]]; then
      if [[ -v MARKED_LOCATIONS[$2] ]]; then
	unset "MARKED_LOCATIONS[$2]"
	echo "Mark '$2' cleared"
      else
	echo "Error: mark '$2' does not exist"
      fi
    else
      echo "Usage: mark --clear [name]"
    fi
  elif [[ $# -eq 0 ]]; then
    MARKED_LOCATIONS[default]=$(pwd)
  else
    MARKED_LOCATIONS[$1]=$(pwd)
  fi
}

recall() {
  if [[ $# -eq 0 ]]; then
    local target=${MARKED_LOCATIONS[default]:-$HOME}
    cd "$target" || cd "$HOME"
  else
    if [[ -v MARKED_LOCATIONS[$1] ]]; then
      cd "${MARKED_LOCATIONS[$1]}"
    else
      echo "Error: mark '$1' does not exist"
      return 1
    fi
  fi
}

# Tab completion for mark and recall
_marks_completion() {
  local -a marks
  marks=(${(k)MARKED_LOCATIONS})
  _describe 'marks' marks
}

compdef _marks_completion mark
compdef _marks_completion recall
