#!/bin/bash

# Can be accessed from https://tinyurl.com/zqxjvkb-install-arch
# Can be run with the command: $ source <(curl -sL https://tinyurl.com/zqxjvkb-install-arch)

set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

#exec 1> >(tee "stdout.log")
#exec 2> >(tee "stderr.log")

# Update the system clock
timedatectl set-ntp true

# Get user input
read -p "Enter hostname: " hostname

read -p "Enter name of first user: " user

read -sp "Enter password (this will become both the root password and user password): " password
echo
read -sp "Confirm password: " password2
echo
[[ "$password" == "$password2" ]] || ( echo "Passwords did not match"; exit 1; )

echo "Available disks on the system (output of lsblk):"
lsblk
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
read -p "Enter the disk that you would like to install on (THIS WILL WIPE ALL DATA ON THE DISK): " disk

read -p "Enter the size of your boot partition (in MiB): " boot_size

echo "Amount of free RAM in the system (output of free --mebi):"
free --mebi
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
read -p "Enter the amount of swap space that you want (in MiB): " swap_size

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
wipefs "${part_boot}"
wipefs "${part_swap}"
wipefs "${part_root}"

mkfs.vfat -F32 "${part_boot}"
mkswap "${part_swap}"
mkfs.ext4 "${part_root}"

swapon "${part_swap}"
mount "${part_root}" /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount "${part_boot}" /mnt/boot/efi

# Install base system
pacstrap /mnt base linux linux-firmware git base-devel

# Generate fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Set timezone
arch-chroot /mnt ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
arch-chroot /mnt hwclock --systohc

# Generate locales
echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
echo "LANG=en_US.UTF-8" >> /mnt/etc/locale.conf
arch-chroot /mnt locale-gen

# Set hostname and /etc/hosts file
echo "${hostname}" > /mnt/etc/hostname

echo "127.0.0.1 localhost" > /mnt/etc/hosts
echo "::1	localhost" >> /mnt/etc/hosts
echo "127.0.1.1	${hostname}.localdomain	${hostname}" >> /mnt/etc/hosts

# Add a new user
arch-chroot /mnt useradd -mU -G wheel,video,audio,storage,games,input "$user"
# TODO: add realtime and libvirt groups to metapackages
# Add wheel users to /etc/sudoers
#arch-chroot /mnt echo "%wheel ALL=(ALL:ALL) ALL" | EDITOR='tee -a' visudo
#arch-chroot /mnt echo "$wheel ALL=(ALL) ALL" >> /etc/sudoers
arch-chroot /mnt echo "%wheel ALL=(ALL) ALL" | sudo EDITOR="tee -a" visudo # TODO: this still doesn't work

# Set passwords
echo "$user:$password" | chpasswd --root /mnt # TODO: setting passwords (probably) still doesn't work
echo "root:$password" | chpasswd --root /mnt

# Install packages
arch-chroot /mnt /bin/bash <<EOF # TODO: config is not recognized
cd "/home/$user"
sudo -u $user git clone https://github.com/zqxjvkb/arch-setup
source arch-setup/package-lists/main.sh && sync_package_list --noconfirm && post_install

# git clone dotfiles
cd "/home/$user"
#temp()
#{
#    /usr/bin/git --git-dir=/home/$user/dotfiles/ --work-tree=/home/$user $@
#}
#echo "alias config='/usr/bin/git --git-dir=/home/$user/dotfiles/ --work-tree=/home/$user'" >> /home/$user/.bashrc
#alias config='/usr/bin/git --git-dir=/home/$user/dotfiles/ --work-tree=/home/$user'
#. /home/$user/.bashrc
echo "dotfiles" >> .gitignore
git clone --bare https://github.com/zqxjvkb/dotfiles "/home/$user/dotfiles"

# Deal with the dotfiles that already have a config in place (config checkout will fail in those cases)
/usr/bin/git --git-dir=/home/$user/dotfiles/ --work-tree=/home/$user checkout -f

/usr/bin/git --git-dir=/home/$user/dotfiles/ --work-tree=/home/$user config --local status.showUntrackedFiles no
EOF
#mkdir -p .config-backup && \
#config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
#    xargs -I{} mv {} .config-backup/{}
