#!/bin/bash

# Variables
# Refer to https://misc.flogisoft.com/bash/tip_colors_and_formatting for colors
default_color="\e[49m"
red="\e[41m"
heading_color=$red
user_home="/home/jw"
package_list_file="$user_home/backup/package_list.txt"

# Check for errors
failed_services() {
	printf "\nFAILED SYSTEMD SERVICES:\n"
	systemctl --failed
}

journal_errors() {
	printf "\nHIGH PRIORITY SYSTEMD JOURNAL ERRORS:\n"
	journalctl -p 3 -xb
}

# Backups
# Config files (git)
# List of installed packages (maybe look at metapackages too?)
package_list() {
    pacman -Qe > "$package_list_file"
    # Consider automatically backing this up to git/metapackages?
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
    printf "Ctrl-click on the following link to make sure there are no updates requiring manual intervention: \e]8;;https://www.archlinux.org/news\aArch news\e]8;;\a\n"
    # Wait for user to confirm that they read it
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
    printf "Done updating aur packages"
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
	printf "...Done checking for pacfiles\n"
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
    printf "Done cleaning the package cache"
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

boot_time=$(date +%s -d 'tomorrow 7:00')
sudo rtcwake -l -m disk -t "$boot_time"
