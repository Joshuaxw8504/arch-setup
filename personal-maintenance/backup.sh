#!/bin/bash

update_config_files() {
    printf "Remember to update the following github repos, if needed:\n"
    for repo in "${git_repos[@]}"
    do
	printf "$repo\n"
    done
    wait_for_keypress
}

# List of installed packages (maybe look at metapackages too?)
package_list() {
    if [[ ! -f "$package_list_file" ]]
    then
	printf "The package list file that was specified ($package_list_file) does not exist. Please create it and try again.\n"
	return
    fi
    
    read -p "Do you want to backup your package list to $package_list_file? (y/N) "
    if [[ $REPLY == 'y' ]]; then
	pacman -Qe > "$package_list_file"
    fi
    
    # Consider automatically backing this up to git/metapackages?
    printf "Done updating package list\n"
    wait_for_keypress
}

# System backup
system_backup() { # Idea: don't do system backups at all, keep all important stuff in home and just reinstall when you need to
    rsync -aAXHv --info=progress2 --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found", "/home/*"} / /mnt
}

# Home backup
home_backup() {
    read -p "Do you want to backup the chosen directories to $backup_dir? (y/N) "
    if [[ $REPLY != 'y' ]]; then return; fi
    
    # Setting this, so the repo does not need to be given on the commandline:
    export BORG_REPO="$backup_dir"

    # See the section "Passphrase notes" for more infos.
    #export BORG_PASSPHRASE='XYZl0ngandsecurepa_55_phrasea&&123'

    # some helpers and error handling:
    info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
    trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

    info "Starting backup"

    # Backup the most important directories into an archive named after
    # the machine this script is currently running on:

    borg create                         \
	 --verbose                       \
	 --filter AME                    \
	 --list                          \
	 --stats                         \
	 --show-rc                       \
	 --compression lz4               \
	 --exclude-caches                \
	 --exclude '/home/*/.cache/*'    \
	 --exclude '/var/cache/*'        \
	 --exclude '/var/tmp/*'          \
         \
	 ::'{hostname}-{now}'            \
	 /etc                            \
	 /home                           \
	 /root                           \
	 /var                            \

	 backup_exit=$?

    info "Pruning repository"

    borg prune                          \
	 --list                          \
	 --prefix '{hostname}-'          \
	 --show-rc                       \
	 --keep-daily    7               \
	 --keep-weekly   4               \
	 --keep-monthly  6               \

	 prune_exit=$?

    # use highest exit code as global exit code
    global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

    if [ ${global_exit} -eq 0 ]; then
	info "Backup and Prune finished successfully"
    elif [ ${global_exit} -eq 1 ]; then
	info "Backup and/or Prune finished with warnings"
    else
	info "Backup and/or Prune finished with errors"
    fi
}

restore_backup() {
    printf "placeholder\n"
}

backup_manual() {
    backup_quit=false
    while [ $backup_quit != true ]; do
	line
	options=("Update config files" "Update package lists" "Backup home directory" "Restore home backup" "Quit")
	PS3="Choose an option: "
	select option in "${options[@]}"; do
	    case $option in
		"Update config files")
		    update_config_files
		    break
		    ;;
		"Update package lists")
		    package_list
		    break
		    ;;
		"Backup home directory")
		    home_backup
		    break
		    ;;
		"Restore home backup")
		    restore_backup
		    break
		    ;;
		"Quit")
		    backup_quit=true
		    break
		    ;;
		*)
		    printf "Please choose a valid option\n"
		    break
		    ;;
	    esac
	done
    done
}

backup_automatic() {
    package_list
    update_config_files
    home_backup
}
