#!/usr/bin/env zsh

menu() {
    printf '\nDiffer menu:\n'
    printf '  1) Edit file 1\n'
    printf '  2) Edit file 2\n'
    printf '  3) View diff (simple)\n'
    printf '  4) View diff (visual)\n'
    printf '  5) Exit\n'
    printf 'Choose an option [1-5]: '
}

differ() {
    local tmp1 tmp2 choice

    tmp1=$(mktemp)
    tmp2=$(mktemp)

    while true; do
        menu
        read -r choice
        case $choice in
            1)
                $EDITOR "$tmp1"
                ;;
            2)
                $EDITOR "$tmp2"
                ;;
            3)
                git diff --no-index -- "$tmp1" "$tmp2"
                ;;
            4)
                git difftool --no-index -- "$tmp1" "$tmp2"
                ;;
            5)
                rm -f -- "$tmp1" "$tmp2"
                return 0
                ;;
            *)
                echo "Invalid choice."
                ;;
        esac
    done
}
