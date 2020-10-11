#!/bin/bash

update_config_files() {
    printf "Remember to update the following github repos, if needed:\n"
    for repo in "${git_repos[@]}"
    do
	printf "$repo\n"
    done
}

# List of installed packages (maybe look at metapackages too?)
package_list() {
    if [[ ! -f "$package_list_file" ]]
    then
	printf "The package list file that was specified ($package_list_file) does not exist. Please create it and try again.\n"
	return
    fi
    
#    printf "Do you want to backup your package list to $package_list_file?\n"
    pacman -Qe > "$package_list_file"
    # Consider automatically backing this up to git/metapackages?
    printf "Done updating package list\n"
}

# System backup
system_backup() { # Idea: don't do system backups at all, keep all important stuff in home and just reinstall when you need to
    rsync -aAXHv --info=progress2 --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found", "/home/*"} / /mnt
}
: '
# Home backup
home_backup() {
    #Use borg
}

restore_home_backup() {
    
}'

backup_manual() {
    options=("Update config files" "Update package lists" "Backup home directory" "Restore home backup" "Quit")
    PS3="Choose an option: "
    select option in "${options[@]}"; do
	case $option in
	    "Update config files")
		update_config_files
		;;
	    "Update package lists")
		package_list
		;;
	    "Backup home directory")
		home_backup
		;;
	    "Restore home backup")
		restore_backup
		;;
	    "Quit")
		exit
		;;
	    *)
		printf "Please choose a valid option\n"
		;;
	esac
    done
}

backup_automatic() {
    package_list
    update_config_files
    home_backup
}
