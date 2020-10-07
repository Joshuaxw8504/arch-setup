#!/bin/bash

# Can be accessed from https://tinyurl.com/zqxjvkb-install-arch
# Can be run with the command: $ source <(curl -sL https://tinyurl.com/zqxjvkb-install-arch)

set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

#exec 1> >(tee "stdout.log")
#exec 2> >(tee "stderr.log")

# Default values for variables (CHANGE THESE IF NEEDED)
hostname=arch
username=jw
disk=/dev/sda
boot_size=550
swap_size=4096

# Ask user if they want to change any of the default variables
echo "Here are all the disks that are available (output of lsblk):"
lsblk
echo "--------------------------------------------------------------------------------"
echo "Here is the amount of free RAM in the system (output of free --mebi):"
free --mebi
echo "--------------------------------------------------------------------------------"
echo "Here are all the currently set values:"
echo "hostname=$hostname"
echo "username=$username"
echo "disk=$disk"
echo "boot_size=$boot_size"
echo "swap_size=$swap_size"
echo -n "Would you like to change any of these values? (y/N): "
read user_ans
[[ "$user_ans" == "y" ]] && ( echo "Download this script using \"curl -sL https://tinyurl.com/zqxjvkb-install-arch > install.sh\" and change the variables to your liking, then run the script with \"sh install.sh\" when you are satisfied."; exit 1; )

# Update the system clock
timedatectl set-ntp true

# Ask user for password
echo -n "Password: "
read -s password
echo
echo -n "Repeat Password: "
read -s password2
echo
[[ "$password" == "$password2" ]] || ( echo "Passwords did not match"; exit 1; )

# Calculate partition endpoints
boot_end=$((1 + $boot_size + 1))
swap_end=$(($boot_end + $swap_size + 1))

# Partition, format, and setup the disk
parted --script "${disk}" -- mklabel gpt \
       mkpart ESP fat32 1MiB ${boot_end}MiB \
       set 1 boot on \
       mkpart primary linux-swap ${boot_end}MiB ${swap_end}MiB \
       mkpart primary ext4 ${swap_end}MiB 100%

part_boot="$(ls ${disk}* | grep -E "^${disk}p?1$")"
part_swap="$(ls ${disk}* | grep -E "^${disk}p?2$")"
part_root="$(ls ${disk}* | grep -E "^${disk}p?3$")"

mkfs.vfat -F32 "${part_boot}"
mkswap "${part_swap}"
mkfs.ext4 "${part_root}"

swapon "${part_swap}"
mount "${part_root}" /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount "${part_boot}" /mnt/boot/efi

# Install base system
pacstrap /mnt base linux linux-firmware

# Generate fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Set timezone
arch-chroot /mnt ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
arch-chroot /mnt hwclock --systohc

# Generate locales
echo "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf
locale-gen

# Set hostname and /etc/hosts file
echo "${hostname}" > /mnt/etc/hostname

echo "127.0.0.1	localhost" > /mnt/etc/hosts
echo "::1	localhost" >> /mnt/etc/hosts
echo "127.0.1.1	${hostname}.localdomain	${hostname}" >> /mnt/etc/hosts

# Add a new user
arch-chroot /mnt useradd -mU -G wheel,uucp,video,audio,storage,games,input "$user"

# Add new user to /etc/sudoers
echo "%wheel ALL=(ALL:ALL) ALL" | sudo EDITOR='tee -a' visudo

# Set passwords
echo "$user:$password" | chpasswd --root /mnt
echo "root:$password" | chpasswd --root /mnt

# Set up bootloader (grub)
arch-chroot /mnt pacman -S --no-confirm grub efibootmgr dosfstools os-prober mtools
arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Add additional packages
arch-chroot /mnt pacman -S --noconfirm networkmanager vim base-devel
arch-chroot /mnt systemctl enable NetworkManager
