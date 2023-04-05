#/usr/bin/env bash

__mgr_create_bootstrap_repo_options="h:help n:dryrun i:interactive l:list c:create= a:auto
    datamodule= d:debug f:flush no-flush force with-custom-channels with-parent-channel="

# Adds a trailing space to a word if it does not end with a '=' character
# The resulting word is assigned to the 'opt' variable
# 1: the word to be appended
_add_suffix() {
    case $1 in
        *=) opt="$1" ;;
        *) opt="$1 " ;;
    esac
}

# Fills the completion array with the wordlist that start with the word
# stored in the 'cur' variable
# @: The word list
_complete_list() {
    local wordlist
    wordlist="$@"
    wordlist=($(compgen -W "$wordlist" -- "${cur-}"))
    if [ "${#wordlist[@]}" == "1" ]; then
        # Append a space if there is only one option
        COMPREPLY=("${wordlist[0]} ")
    else
        COMPREPLY=(${wordlist[@]})
    fi
}

# Returns success if the current option matches the option specified in the arguments
# 1: the short option
# 2: the matching long option
_is_option() {
    local prev pprev
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    pprev="${COMP_WORDS[COMP_CWORD-2]}"

    if [ "$prev" = "-$1" ] || [ "$prev" = "--$2" ] ||
        $([ "$prev" = "=" ] && [ "$pprev" = "--$2" ]); then
            return 0
        else
            return 1
    fi
}

_mgr_create_bootstrap_repo_completions() {
    local cur IFS=$' \t\n'
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Replace short options with long versions
    local short long c i
    for c in $__mgr_create_bootstrap_repo_options; do
        short="${c%%:*}"
        long="${c#*:}"
        if [ "-$short" = "$cur" ]; then
            _add_suffix $long
            COMPREPLY[i++]="--$opt"
            return
        fi
    done

    # Complete channels
    if _is_option c create; then
        cur="${cur#=}"
        _complete_list $(mgr-create-bootstrap-repo --list | sed 's/^[^\.]*\. //')
        return
    fi

    # Long options
    case "$cur" in
        *=) ;;
        -*)
            for o in $__mgr_create_bootstrap_repo_options; do
                o="${o#*:}"
                if [[ "--$o" = "$cur"* ]]; then
                    _add_suffix $o
                    COMPREPLY[i++]="--$opt"
                fi
            done
            ;;
    esac
}

complete -o nospace -F _mgr_create_bootstrap_repo_completions mgr-create-bootstrap-repo
