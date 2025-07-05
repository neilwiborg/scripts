#!/usr/bin/env zsh

# define associative array (map) to keep track of marked locations
typeset -A MARKED_LOCATIONS

mark() {
  # check if clearing a mark
  if [[ "$1" == "--clear" || "$1" == "-c" ]]; then
    # if no additional arguments given, clear the default mark
    if [[ $# -eq 1 ]]; then
      # check if default mark is set
      if [[ -v MARKED_LOCATIONS[default] ]]; then
        unset 'MARKED_LOCATIONS[default]'
	      echo "Default mark cleared"
      else
	      echo "No default mark set"
      fi
    # if --clear and mark name given, clear the named mark
    elif [[ $# -eq 2 ]]; then
      # check if mark is set
      if [[ -v MARKED_LOCATIONS[$2] ]]; then
        unset "MARKED_LOCATIONS[$2]"
        echo "Mark '$2' cleared"
      else
        echo "Error: mark '$2' does not exist"
        return 1
      fi
    else
      echo "Usage: mark --clear [name]"
      return 1
    fi
  # if no additional arguments given, set the default mark
  elif [[ $# -eq 0 ]]; then
    MARKED_LOCATIONS[default]=$(pwd)
  # set mark named with the argument
  else
    MARKED_LOCATIONS[$1]=$(pwd)
  fi
}

recall() {
  # if no additional arguments given, recall to the default mark
  if [[ $# -eq 0 ]]; then
    # if default mark set, use that location
    if [[ -v MARKED_LOCATIONS[default] ]]; then
      cd "${MARKED_LOCATIONS[default]}" || return 1
    # fallback to home directory if no default mark set
    else
      cd "$HOME" || return 1
    fi
  # if mark name given, recall to the named mark
  else
    # check if the mark exists
    if [[ -v MARKED_LOCATIONS[$1] ]]; then
      cd "${MARKED_LOCATIONS[$1]}" || return 1
    else
      echo "Error: mark '$1' does not exist"
      return 1
    fi
  fi
}

# tab completion for mark and recall
_marks_completion() {
  local -a marks
  # get all keys (mark names)
  marks=(${(k)MARKED_LOCATIONS})
  _describe 'marks' marks || compadd "${marks[@]}"
}

compdef _marks_completion mark
compdef _marks_completion recall
