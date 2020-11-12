#!/bin/bash

# Make sure script is running as sudo
if [[ "$EUID" -ne 0 ]]; then
	printf "This script must be run as root\n" 1>&2
	exit 1
fi

pkg_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$pkg_dir/util.sh"
source "$pkg_dir/errors.sh"
source "$pkg_dir/backup.sh"
source "$pkg_dir/upgrade.sh"
source "$pkg_dir/clean.sh"

# Upgrade system
arch_news
update_mirrorlist
upgrade_system
upgrade_aur
pacman_alerts
handle_pacfiles
#reboot
# Check errors
failed_services
journal_errors
# Clean filesystem
clean_package_cache
remove_orphans
clean_broken_symlinks
clean_old_config
