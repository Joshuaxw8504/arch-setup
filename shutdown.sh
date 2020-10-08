#!/bin/bash

# Wakeup time
boot_time=$(date +%s -d 'tomorrow 7:00')

# Make sure script is running as root/sudo
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
			       
#--------------Shutting down at night--------------

# Do system backup and home directory backup
# rsync -aAXHv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found", "/home/*"} / /mnt
# insert home directory backup
# update list of installed packages

# Shutdown and then wake up at specified time
sudo rtcwake -l -m disk -t "$boot_time"

#-------------After booting up in the morning-------------

# Do system maintenance stuff
# https://wiki.archlinux.org/index.php/System_maintenance
systemctl --failed
journalctl -p 3 -xb

# Update mirrorlist
reflector --latest 70 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Upgrade system, except read the RSS feed/arch news first
echo "Check the arch news for any updates that require manual intervention: https://www.archlinux.org/news/"
while 
pacman -Syu

# Upgrade AUR packages


