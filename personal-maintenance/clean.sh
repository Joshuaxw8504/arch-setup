#!/bin/bash

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
    printf "Placeholder, checking symlinks does not actually work yet"
}

clean_manual() {
    options=("Clean package cache" "Clean broken symlinks" "Clean old config files" "Quit")
    PS3="Choose an option: "
    select option in "${options[@]}"; do
	case $option in
	    "Clean package cache")
		clean_package_cache
		;;
	    "Clean broken symlinks")
		clean_broken_symlinks
		;;
	    "Clean old config files")
		clean_old_config
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

clean_automatic() {
    clean_package_cache
    clean_broken_symlinks
    clean_old_config
}
