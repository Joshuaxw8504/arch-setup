#!/bin/bash

failed_services() {
	printf "Failed systemd services:\n"
	systemctl --failed
}

journal_errors() {
    #TODO: let user press enter to continue, since the journal command autoamtically takes over the screen
	printf "High priority systemd journal errors:\n"
	journalctl -p 3 -xb
}

errors_manual() {
    options=("Print failed systemd services" "Print high priority systemd journal errors" "Quit")
    PS3="Choose an option: "
    select option in "${options[@]}"; do
	case $option in
	    "Print failed systemd services")
		failed_services
		;;
	    "Print high priority systemd journal errors")
		journal_errors
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

errors_automatic() {
    failed_services
    journal_errors
}