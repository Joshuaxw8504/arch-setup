#!/bin/bash

# Upgrading the system
arch_news() {
    print_line
    # Output list of packages that will be updated
    printf "Packages that will be updated:\n"
    if [[ $(pacman -Qu) ]]
    then
        pacman -Qu
    else
	printf "None\n"
    fi
    # Maybe look at that arch wiki link to print out the arch news in the terminal itself
    printf "\nCtrl-click on the following link to make sure that none of the updates require manual intervention: \e]8;;https://www.archlinux.org/news\aArch news\e]8;;\a\n"
}

update_mirrorlist() {
    print_line
    reflector --latest 70 --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    printf "Done updating mirrorlist\n"
    wait_for_keypress
}

upgrade_system() {
    print_line
    printf "Upgrading system\n"
    pacman -Syu
    printf "Done updating system\n"
}

upgrade_aur() {
    print_line
#    read -p "Do you want to upgrade aur packages? (y/N) "
    #    if [[ $REPLY == 'y' ]]; then
    printf "Upgrading aur packages\n"
        sudo -u "$user" yay -Syu
	printf "Done updating aur packages\n"
#    fi
}

pacman_alerts() {
    print_line
    last_upgrade="$(sed -n '/pacman -Syu/h; ${x;s/.\([0-9-]*\).*/\1/p;}' /var/log/pacman.log)"
    printf "Pacman log warnings:\n"
    if [[ -n "$last_upgrade" ]]; then
	paclog --after="$last_upgrade" | paclog --warnings
    fi
    printf "Done checking for pacman log warnings\n"
    wait_for_keypress
}

handle_pacfiles() {
    print_line
    printf "Handling pacfiles:\n"
    pacdiff
    printf "Done checking for pacfiles\n"
    wait_for_keypress
}

reboot() {
    print_line
    reboot
}

# Revert broken updates if needed
