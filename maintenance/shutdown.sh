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
# rsync -aAXHv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found", "/home/*"} / /mnt
# insert home directory backup
# update list of installed packages

# Shutdown and then wake up at specified time
sudo rtcwake -l -m disk -t "$boot_time"
