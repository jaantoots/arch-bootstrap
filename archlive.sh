#!/bin/bash

set -eux

cp -av /usr/share/archiso/configs/releng/ archlive

install -Dm644 -t archlive/airootfs/etc/pacman.d mirrorlist
install -Dm644 -t archlive/airootfs/etc/systemd/network 10-dhcp.network
install -Dm644 -t archlive/airootfs/etc/iwd iwd/main.conf
install -Dm600 -t archlive/airootfs/var/lib/iwd iwd/*.psk
install -Dm644 -t archlive/airootfs/root/.ssh authorized_keys

ln -sf ../run/systemd/resolve/stub-resolv.conf archlive/airootfs/etc/resolv.conf
sed -i -e '/\/etc\/pacman\.d\/mirrorlist/d' \
    -e 's/ choose-mirror.service/ iwd.service systemd-networkd.service systemd-resolved.service sshd.service/' \
    archlive/airootfs/root/customize_airootfs.sh
