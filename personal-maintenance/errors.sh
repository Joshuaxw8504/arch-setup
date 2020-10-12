#!/bin/bash

failed_services() {
    printf "Failed systemd services:\n"
    systemctl --failed
    wait_for_keypress
}

journal_errors() {
    printf "High priority systemd journal errors:\n"
    journalctl -p 3 -xb
    wait_for_keypress
}

errors_manual() {
    errors_quit=false
    while [ $errors_quit != true ]; do
	line
	options=("Print failed systemd services" "Print high priority systemd journal errors" "Quit")
	PS3="Choose an option: "
	select option in "${options[@]}"; do
	    case $option in
		"Print failed systemd services")
		    failed_services
		    break
		    ;;
		"Print high priority systemd journal errors")
		    journal_errors
		    break
		    ;;
		"Quit")
		    errors_quit=true
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

errors_automatic() {
    failed_services
    journal_errors
}
