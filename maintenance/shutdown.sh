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
			       
# Do system backup and home directory backup
update_config_files
package_list
home_backup

# Shutdown and then wake up at specified time
#sudo rtcwake -l -m disk -t "$boot_time"
