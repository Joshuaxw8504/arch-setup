#!/bin/bash

# Maybe use disk-usage.el?

clean_package_cache() {
    print_line
    # Leaves past three versions of installed packages but only one past version of uninstalled packages
    paccache -rk3 -ruk1
    printf "Done cleaning the package cache\n"
    wait_for_keypress
}

clean_old_config() {
    print_line
    printf "REMINDER: Check the following directories for old configuration files\n"
    printf "$user_home/\n"
    printf "$user_home/.config/\n"
    printf "$user_home/.cache/\n"
    printf "$user_home/.local/share/\n"
    wait_for_keypress
}

clean_broken_symlinks() {
    print_line
    printf "Broken symlinks:\n"
    symlinks=$(find "${symlink_dirs[@]}" -xtype l -print)
    printf '%s\n' "$symlinks"
    read -p "Do you want to remove all the above symlinks? (y/N) "
    if [[ $REPLY == 'y' ]]; then
	rm $symlinks
    fi
}

remove_orphans() {
    print_line
    orphans=$(pacman -Qtdq)
    printf "Orphaned packages:\n"
    printf '%s\n' "${orphaned[@]}"
    read -p "Do you want to remove the above orphaned packages? (y/N) "
    if [[ $REPLY == "y" ]]; then
	pacman -Rns --noconfirm "${orphaned[@]}"
    fi
}

# "Dropped" packages are usually just AUR packages anyway so we don't need to worry about them unless there are actual dropped packages
