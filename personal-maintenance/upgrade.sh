#!/bin/bash

# Upgrading the system
arch_news() {
    # Output list of packages that will be updated
    printf "Packages that will be updated:\n"
    if [[ $(pacman -Qu) ]]
    then
        pacman -Qu
    else
	printf "None\n"
    fi

    printf "\nCtrl-click on the following link to make sure that none of the updates require manual intervention: \e]8;;https://www.archlinux.org/news\aArch news\e]8;;\a\n"
    wait_for_keypress
}

update_mirrorlist() {
    reflector --verbose --latest 70 --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    printf "Done updating mirrorlist\n"
}

upgrade_system() {
    read -p "Do you want to upgrade the system? (y/N) "
    if [[ $REPLY == 'y' ]]; then
	pacman -Syu
	printf "Done updating system\n"
    fi

}

upgrade_aur() {
    read -p "Do you want to upgrade aur packages? (y/N) "
    if [[ $REPLY == 'y' ]]; then
	yay -Syu
	printf "Done updating aur packages\n"
    fi
}

pacman_alerts() {
    last_upgrade="$(sed -n '/pacman -Syu/h; ${x;s/.\([0-9-]*\).*/\1/p;}' /var/log/pacman.log)"
    printf "Pacman log warnings:\n"
    if [[ -n "$last_upgrade" ]]; then
	paclog --after="$last_upgrade" | paclog --warnings
    fi
    printf "Done checking for pacman log warnings\n"
    wait_for_keypress
}

handle_pacfiles() {
    printf "Handling pacfiles:\n"
    pacdiff
    printf "Done checking for pacfiles\n"
    wait_for_keypress
}

reboot() {
    reboot
}
# Revert broken updates if needed


upgrade_manual() {
    upgrade_quit=false
    while [ $upgrade_quit != true ]; do
	line
	options=("Check arch news" "Update mirrorlist" "Upgrade system" "Upgrade aur packages" "See pacman alerts" "Handle pacfiles" "Reboot" "Quit")
	PS3="Choose an option: "
	select option in "${options[@]}"; do
	    case $option in
		"Check arch news")
		    arch_news
		    break
		    ;;
		"Update mirrorlist")
		    update_mirrorlist
		    break
		    ;;
		"Upgrade system")
		    upgrade_system
		    break
		    ;;
		"Upgrade aur packages")
		    upgrade_aur
		    break
		    ;;
		"See pacman alerts")
		    pacman_alerts
		    break
		    ;;
		"Handle pacfiles")
		    handle_pacfiles
		    break
		    ;;
		"Reboot")
		    reboot
		    break
		    ;;
		"Quit")
		    upgrade_quit=true
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

upgrade_automatic() {
    update_mirrorlist
    arch_news
    upgrade_system
    upgrade_aur
    pacman_alerts
    handle_pacfiles
    reboot
}
