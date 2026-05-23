#!/usr/bin/env zsh

_differ_menu() {
    printf '\nDiffer menu:\n'
    printf '  1) Edit file 1\n'
    printf '  2) Edit file 2\n'
    printf '  3) Swap files\n'
    printf '  4) View diff (simple)\n'
    printf '  5) View diff (visual)\n'
    printf '  6) Exit\n'
    printf 'Choose an option [1-6]: '
}

differ() {
    # check if git is installed
    if ! whence git > /dev/null; then
        echo "Error: git is not installed"
        return 1
    fi

    local file1 file2 choice

    file1=$(mktemp)
    file2=$(mktemp)

    while true; do
        _differ_menu
        read -r choice
        case $choice in
            1)
                $EDITOR "$file1"
                ;;
            2)
                $EDITOR "$file2"
                ;;
            3)
                local tmp
                tmp=$file1
                file1=$file2
                file2=$tmp
                ;;
            4)
                git diff --no-index -- "$file1" "$file2"
                ;;
            5)
                git difftool --no-index -- "$file1" "$file2"
                ;;
            6)
                rm -f -- "$file1" "$file2"
                return 0
                ;;
            *)
                echo "Invalid choice."
                ;;
        esac
    done
}
