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
