#!/bin/bash

# Can be accessed from https://tinyurl.com/zqxjvkb-install-arch
# Can be run with the command: $ source <(curl -sL https://tinyurl.com/zqxjvkb-install-arch)

set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# Update the system clock
timedatectl set-ntp true

# Set preliminary variables
echo -n "Hostname: "
read hostname
: "${hostname:?"Missing hostname"}"

echo -n "Password: "
read -s password
echo
echo -n "Repeat Password: "
read -s password2
echo
[[ "$password" == "$password2" ]] || ( echo "Passwords did not match"; exit 1; )

echo -e "\nDisks:"
lsblk

echo ${hostname} ${password}

echo -e "\nChoose a disk from the above:"
read disk
: "${disk:?"Missing disk"}"
echo -n "Size of boot partition (in MiB): "
read boot_size
: "${boot_size:?"Missing boot size"}"
echo -n "Size of swap partition (in MiB): "
read swap_size
: "${swap_size:?"Missing swap size"}"

boot_end=$((1 + $boot_size + 1))
swap_end=$(($boot_end + $swap_size + 1))

# Partition disk
parted --script "${disk}" -- mklabel gpt \
       mkpart ESP fat32 1Mib ${boot_end}MiB \
       set 1 boot on \
       mkpart primary linux-swap ${boot_end}MiB ${swap_end}MiB \
       mkpart primary ext4 ${swap_end}MiB 100%

part_boot="$(ls ${disk}* | grep -E "^${disk}p?1$")"
part_swap="$(ls ${disk}* | grep -E "^${swap}p?2$")"
part_root="$(ls ${disk}* | grep -E "^${root}p?3$")"

wipefs "${part_boot}"
wipefs "${part_swap}"
wipefs "${part_root}"

sleep 30

mkfs.vfat -F32 "${part_boot}"
mkswap "${part_swap}"
mkfs.f2fs -f "${part_root}"

swapon "${part_swap}"
mount "${part_root}" /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount "${part_boot}" /mnt/boot/efi

# Install base system
pacstrap /mnt base linux linux-firmware

# Configure the system
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt ln-sf /usr/share/zoneinfo/America/Chicago /etc/localtime
arch-chroot /mnt hwclock --systohc

echo "LANG=en_GB.UTF-8" > /mnt/etc/locale.conf
