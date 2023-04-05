#/usr/bin/env bash

__spacewalk_remove_channel_options="v:verbose l:list c:channel= a:channel-with-children=
    u:unsubscribe justdb force p:skip-packages skip-kickstart-trees just-kickstart-trees
    skip-channels username= password= h:help"

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

_spacewalk_remove_channel_completions() {
    local cur IFS=$' \t\n'
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Replace short options with long versions
    local short long c i
    for c in $__spacewalk_remove_channel_options; do
        short="${c%%:*}"
        long="${c#*:}"
        if [ "-$short" = "$cur" ]; then
            _add_suffix $long
            COMPREPLY[i++]="--$opt"
            return
        fi
    done


    # Complete channels
    if _is_option c channel; then
        cur="${cur#=}"
        _complete_list $(spacewalk-remove-channel --list | sed 's/\s+//')
        return
    fi

    # Complete base channels
    if _is_option a channel-with-children; then
        cur="${cur#=}"
        _complete_list $(spacewalk-remove-channel --list | grep '^\w')
        return
    fi

    # Long options
    case "$cur" in
    *=) ;;
    *)
        for o in $__spacewalk_remove_channel_options; do
            o="${o#*:}"
            if [[ "--$o" = "$cur"* ]]; then
                _add_suffix $o
                COMPREPLY[i++]="--$opt"
            fi
        done
        ;;
    esac
}

complete -o nospace -F _spacewalk_remove_channel_completions spacewalk-remove-channel
