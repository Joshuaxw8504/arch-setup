#!/bin/bash

# Maybe use disk-usage.el?
clean_package_cache() {
    # Leaves past three versions of installed packages but only one past version of uninstalled packages
    paccache -rk3 -ruk1
    printf "Done cleaning the package cache\n"
    wait_for_keypress
}

# Check for orphans/dropped packages
clean_old_config() {
    printf "REMINDER: Check the following directories for old configuration files\n"
    printf "$user_home/\n"
    printf "$user_home/.config/\n"
    printf "$user_home/.cache/\n"
    printf "$user_home/.local/share/\n"
    wait_for_keypress
}

# Check for broken symlinks
clean_broken_symlinks() {
    printf "Broken symlinks:\n"
    symlinks=$(find "${symlink_dirs[@]}" -xtype l -print)
    printf '%s\n' "$symlinks"
    read -p "Do you want to remove all the above symlinks? (y/N) "
    if [[ $REPLY == 'y' ]]; then
	rm $symlinks
    fi
    wait_for_keypress
}

clean_manual() {
    clean_quit=false
    while [ $clean_quit != true ]; do
	line
	options=("Clean package cache" "Clean broken symlinks" "Clean old config files" "Quit")
	PS3="Choose an option: "
	select option in "${options[@]}"; do
	    case $option in
		"Clean package cache")
		    clean_package_cache
		    break
		    ;;
		"Clean broken symlinks")
		    clean_broken_symlinks
		    break
		    ;;
		"Clean old config files")
		    clean_old_config
		    break
		    ;;
		"Quit")
		    clean_quit=true
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

clean_automatic() {
    clean_package_cache
    clean_broken_symlinks
    clean_old_config
}
