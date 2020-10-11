#!/bin/bash

# Refer to https://misc.flogisoft.com/bash/tip_colors_and_formatting for colors
default_color="\e[49m"
red="\e[41m"
heading_color=$red
user_home="/home/jw"
package_list_file="$user_home/backup/package_list.txt"
declare -a git_repos=("arch-setup" "dotfiles" ".emacs.d")
boot_time=$(date +%s -d 'tomorrow 7:00')
