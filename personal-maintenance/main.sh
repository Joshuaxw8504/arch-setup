#!/bin/bash

usage() {
    cat <<EOF
Usage: $0 [options]

-h    show help
-a    run all maintenance functions automatically
-m    manually choose which maintenance functions to run
EOF
}

# Make sure script is running as sudo
if [[ "$EUID" -ne 0 ]]; then
	printf "This script must be run as root\n" 1>&2
	exit 1
fi

pkg_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$pkg_dir/settings.sh"
source "$pkg_dir/util.sh"
source "$pkg_dir/errors.sh"
source "$pkg_dir/backup.sh"
source "$pkg_dir/upgrade.sh"
source "$pkg_dir/clean.sh"

automatic() {
    backup_automatic
    sudo rtcwake -l -m disk -t "$boot_time"
    upgrade_automatic
    errors_automatic
    clean_automatic
}

manual() {
    quit=false
    while [ $quit != true ]; do
	line
	options=("Errors" "Backup" "Upgrade" "Clean" "Change settings" "Quit")
	PS3="Main menu - choose an option: "
	select option in "${options[@]}"; do
	    case $option in
		"Errors")
		    errors_manual
		    break ;;
		"Backup")
		    backup_manual
		    break ;;
		"Upgrade")
		    upgrade_manual
		    break ;;
		"Clean")
		    clean_manual
		    break ;;
		"Change settings")
		    vim "$pkg_dir/settings.sh"
		    break ;;
		"Quit")
		    quit=true
		    break ;;
		*)
		    printf "Please choose a valid option\n"
		    break
		    ;;
	    esac
	done
    done
}

while getopts :ham arg; do
    case ${arg} in
	h)
	    usage
	    ;;
	a)
	    automatic
	    ;;
	m)
	    manual
	    ;;
	?)
	    printf "Invalid option: -${OPTARG}\n"
	    usage
	    exit 2
	    ;;
    esac
done
	
: '
# Backup things
update_config_files
package_list
home_backup

# Shutdown and schedule startup time
sudo rtcwake -l -m disk -t "$boot_time"

# Upgrade system
update_mirrorlist
arch_news
update_system
update_aur
pacman_alerts
handle_pacfiles
reboot

# Check for errors
failed_services
journal_errors

# Clean filesystem
clean_package_cache
clean_broken_symlinks
clean_old_config'
# asdf
