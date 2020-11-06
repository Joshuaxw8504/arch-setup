#!/bin/bash

packages=(
    # Package groups
    base-devel xorg
    
    # Base packages
    base linux linux-firmware man-db man-pages pacman-contrib

    # Bootloader and related packages
    grub efibootmgr dosfstools os-prober mtools

    # Basic utilities
    networkmanager git cronie

    # Higher-level utilities
    vim emacs firefox mpv youtube-dl

    # Other xorg-related packages
    xorg-xinit

    # Sound
    alsa-utils alsa-plugins jack2 qjackctl

    # Make dependencies
    cmake

    # Virtual machines
    qemu libvirt virt-manager ebtables iptables dnsmasq edk2-ovmf

    # Backup
    borg

    # Password manager
    keepassxc

    # Cloud services
    rclone
)

packages_aur=(
    discord-canary reaper-bin unityhub yay-git
)

packages_dell_latitude=(
    # Drivers
    xf86-video-vesa sof-firmware
)
packages+=(${packages_dell_latitude[@]})
: '
packages_unneeded=(
    accountsservice alacritty devtools expac iwd lightdm lightdm-slick-greeter lightdm-gtk-greeter lsof luit maint pavucontrol picom pulseaudio-alsa pulseaudio-git s3cmd 
)
packages_unneeded+=$(pacman -Sgq gnome)
packages+=(${packages_unneeded[@]})
'
sync_package_list()
{
    output_package_list > temp_package_list.txt
    if [[ "$1" == "--noconfirm" ]]
    then
	sudo pacman -S --needed --noconfirm - < temp_package_list.txt
	sudo pacman -Rsu --noconfirm $(comm -23 <(pacman -Qqe | sort) <(sort temp_package_list.txt))
    else
	sudo pacman -S --needed - < temp_package_list.txt
	sudo pacman -Rsu $(comm -23 <(pacman -Qqe | sort) <(sort temp_package_list.txt))
    fi
    rm temp_package_list.txt
}

output_package_list()
{
    for p in ${packages[@]};
    do
	echo $p
    done | sort
}

diff_packages()
{
    comm -3 <(pacman -Qqe | sort) <(output_package_list)
}

post_install()
{
    grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
    grub-mkconfig -o /boot/grub/grub.cfg
    systemctl enable --now NetworkManager
    systemctl enable --now libvirtd
    # adding groups (this assumes the user is jw)
    usermod -aG libvirt,realtime jw
}
