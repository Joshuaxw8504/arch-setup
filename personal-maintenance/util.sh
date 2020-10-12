#!/bin/bash

line() {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

wait_for_keypress() {
    echo "Press any key to continue"
    while [[ true ]] ; do
	read -t 1 -n 1
	if [[ $? = 0 ]] ; then
	    return
	fi
    done
}
: '
yes_no_question() {
    read -p "$1"
    if [[ $REPLY == 'y' ]]; then
	
}'
