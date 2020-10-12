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
    echo "Press any key to continue, after reading the arch news"
    while [[ true ]] ; do
	read -t 1 -n 1
	if [[ $? = 0 ]] ; then
	    return
	fi
    done
}

update_mirrorlist() {
    reflector --verbose --latest 70 --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    printf "Done updating mirrorlist\n"
}

upgrade_system() {
    pacman -Syu
    printf "Done updating system\n"
}

upgrade_aur() {
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
