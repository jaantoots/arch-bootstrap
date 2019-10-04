#!/bin/bash

set -eux

mnt="$1"
hostname="$2"
cmdline="$3" # cryptdevice=UUID=$uuid:root:allow-discards root=/dev/mapper/root rw

# Set up local mirrorlist
cat mirrorlist /etc/pacman.d/mirrorlist >/etc/pacman.d/mirrorlist.new
mv /etc/pacman.d/mirrorlist.new /etc/pacman.d/mirrorlist

# Basic system
pacstrap "$mnt" base systemd-resolvconf intel-ucode iwd openssh
genfstab -U "$mnt" >> "$mnt/etc/fstab"
echo "$hostname" > "$mnt/etc/hostname"

# Configure network and access
install -Dm644 -t "$mnt/etc/systemd/network" /etc/systemd/network/*
install -Dm644 -t "$mnt/etc/iwd" /etc/iwd/main.conf
install -Dm600 -t "$mnt/var/lib/iwd" /var/lib/iwd/*.psk
install -Dm644 -t "$mnt/root/.ssh" /root/.ssh/authorized_keys

ln -sf ../run/systemd/resolve/stub-resolv.conf "$mnt/etc/resolv.conf"

# Initramfs configuration and boot loader entry
sed -i '/^HOOKS/s/\(filesystems\)/consolefont encrypt lvm2 \1/' "$mnt/etc/mkinitcpio.conf"
install -Dm644 /dev/stdin "$mnt/boot/loader/entries/arch.conf" <<EOF
title	Arch Linux
linux	/vmlinuz-linux
initrd	/intel-ucode.img
initrd	/initramfs-linux.img
options	$cmdline
EOF

# Create init script
install -Dm755 /dev/stdin "$mnt/root/init.sh" <<EOF
#!/bin/bash

set -eux

# Locale
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
sed -i 's/#\(en_GB\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Generate initramfs and install bootloader
mkinitcpio -P
bootctl install

# Enable systemd services
systemctl enable iwd.service systemd-networkd.service systemd-resolved.service systemd-timesyncd.service sshd.service
systemctl set-default multi-user.target
EOF

# Run init script
arch-chroot "$mnt" /root/init.sh
