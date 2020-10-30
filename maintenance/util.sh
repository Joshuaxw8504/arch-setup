#!/bin/bash

# Refer to https://misc.flogisoft.com/bash/tip_colors_and_formatting for colors
default_color="\e[49m"
red="\e[41m"
heading_color=$red

user="jw"
user_home="/home/$user"
package_list_file="$user_home/arch-setup/package-lists/main.sh"
git_repos=("arch-setup" "dotfiles" "etc")
backup_dir="$user_home/backup/borg"
symlink_dirs=("/etc" "/home" "/opt" "/srv" "/usr")
boot_time=$(date +%s -d 'tomorrow 7:00') #TODO: how do i account for if i shutdown after midnight

print_line() {
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

setup_dirs() {
    # $package_list_file should already be created

    #Create $backup_dir
    if [[ ! -f "$backup_dir" ]]
    then
	mkdir -p "$backup_dir"
    fi
}
