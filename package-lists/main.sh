#!/bin/bash

packages=(

# Base packages
base linux linux-firmware man-db man-pages pacman-contrib

# Bootloader and related packages
grub efibootmgr dosfstools os-prober mtools

# Basic utilities
networkmanager git cronie

# Higher-level utilities
vim emacs firefox mpv youtube-dl

# base-devel group
autoconf automake binutils bison fakeroot file findutils flex gawk gcc gettext grep groff gzip libtool m4 make pacman patch pkgconf sed sudo texinfo which

# xorg package group
xf86-video-vesa xorg-bdftopcf xorg-docs xorg-font-util xorg-fonts-100dpi xorg-fonts-75dpi xorg-fonts-encodings xorg-iceauth xorg-mkfontscale xorg-server xorg-server-common xorg-server-devel xorg-server-xephyr xorg-server-xnest xorg-server-xvfb xorg-server-xwayland xorg-sessreg xorg-setxkbmap xorg-smproxy xorg-x11perf xorg-xauth xorg-xbacklight xorg-xcmsdb xorg-xcursorgen xorg-xdpyinfo xorg-xdriinfo xorg-xev xorg-xgamma xorg-xhost xorg-xinput xorg-xkbcomp xorg-xkbevd xorg-xkbutils xorg-xkill xorg-xlsatoms xorg-xlsclients xorg-xmodmap xorg-xpr xorg-xprop xorg-xrandr xorg-xrdb xorg-xrefresh xorg-xset xorg-xsetroot xorg-xvinfo xorg-xwd xorg-xwininfo xorg-xwud

# Login manager
#    lightdm lightdm-gtk-greeter

# Sound
alsa-utils alsa-plugins jack2 qjackctl

# Other graphical desktop utilities
#    picom

# Virtual machines
qemu libvirt virt-manager ebtables iptables dnsmasq edk2-ovmf
)

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

output_new_groups()
{
    echo "libvirt,realtime"
}

post_install()
{
    grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
    grub-mkconfig -o /boot/grub/grub.cfg
    systemctl enable --now NetworkManager
    systemctl enable --now libvirtd
}
