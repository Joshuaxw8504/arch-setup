#!/bin/bash

update_config_files() {
    print_line
    printf "Remember to update the following github repos, if needed:\n"
    for repo in "${git_repos[@]}"
    do
	printf "$repo\n"
    done
    wait_for_keypress
}

# List of installed packages (maybe look at metapackages too?)
package_list() {
    print_line
#    pacman -Qqe > "$package_list_file"
    printf "Differences between installed packages (left) and package list (right):\n"
    source "$package_list_file"
    diff_packages
    printf "Update package lists and/or remove installed packages accordingly\n"
    wait_for_keypress
}

# Home backup
home_backup() {
    setup_dirs
    print_line
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
