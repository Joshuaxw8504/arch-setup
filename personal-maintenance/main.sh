#!/bin/bash

# Variables
# Refer to https://misc.flogisoft.com/bash/tip_colors_and_formatting for colors
default_color="\e[49m"
red="\e[41m"
heading_color=$red
user_home="/home/jw"
package_list_file="$user_home/backup/package_list.txt"
declare -a git_repos=("arch-setup" "dotfiles" ".emacs.d")
boot_time=$(date +%s -d 'tomorrow 7:00')

# Check for errors
failed_services() {
	printf "FAILED SYSTEMD SERVICES:\n"
	systemctl --failed
}

journal_errors() {
	printf "HIGH PRIORITY SYSTEMD JOURNAL ERRORS:\n"
	journalctl -p 3 -xb
}

check_errors() {
    failed_services
    journal_errors
}


# Backups
# Config files (git)
update_config_files() {
    printf "Remember to update the following github repos, if needed:\n"
    for repo in "$(git_repos[@])"
    do
	printf "$repo\n"
    done
}

# List of installed packages (maybe look at metapackages too?)
package_list() {
    pacman -Qe > "$package_list_file"
    # Consider automatically backing this up to git/metapackages?
    printf "Done updating package list\n"
}

# System backup
system_backup() { # Idea: don't do system backups at all, keep all important stuff in home and just reinstall when you need to
    rsync -aAXHv --info=progress2 --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found", "/home/*"} / /mnt
}

# Home backup
home_backup() {
    #Use borg
}

restore_home_backup() {
    
}

# Upgrading the system
arch_news() {
    # Output list of packages that will be updated
    printf "Packages that will be updated:\n"
    pacman -Qu
    printf "Ctrl-click on the following link to make sure that none of the updates require manual intervention: \e]8;;https://www.archlinux.org/news\aArch news\e]8;;\a\n"
    # Wait for user to confirm that they read it
    echo "Press any key to continue, after reading the arch news"
    while [[ true ]] ; do
	read -t 1 -n 1
	if [[ $? = 0 ]] ; then
	    exit ;
	fi
    done
}

update_mirrorlist() {
    reflector --latest 200 --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    printf "Done updating mirrorlist\n"
}

update_system() {
    pacman -Syu
    printf "Done updating system\n"
}

update_aur() {
    yay -Syu
    printf "Done updating aur packages\n"
}

pacman_alerts() {
	last_upgrade="$(sed -n '/pacman -Syu/h; ${x;s/.\([0-9-]*\).*/\1/p;}' /var/log/pacman.log)"

	if [[ -n "$last_upgrade" ]]; then
		paclog --after="$last_upgrade" | paclog --warnings
	fi
	printf "Done checking for pacman log warnings\n"
}

handle_pacfiles() {
	pacdiff
	printf "Done checking for pacfiles\n"
}

reboot() {
    reboot
}
# Revert broken updates if needed

# Clean the filesystem
# Maybe use disk-usage.el?
clean_package_cache() {
    # Leaves past three versions of installed packages but only one past version of uninstalled packages
    paccache -rk3 -ruk1
    printf "Done cleaning the package cache\n"
}

# Check for orphans/dropped packages
clean_old_config() {
    printf "REMINDER: Check the following directories for old configuration files\n"
    printf "$user_home/\n"
    printf "$user_home/.config/\n"
    printf "$user_home/.cache/\n"
    printf "$user_home/.local/share/\n"
}

# Check for broken symlinks
clean_broken_symlinks() {
    
}

# Main script

# Make sure script is running as sudo
if [[ "$EUID" -ne 0 ]]; then
	printf "This script must be run as root\n" 1>&2
	exit 1
fi

# Backup things
#config_backup?
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

# Check for errors
failed_services
journal_errors

# Clean filesystem
clean_package_cache
clean_broken_symlinks
clean_old_config
