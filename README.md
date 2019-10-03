# Install Arch Linux

## Build archiso

Add wireless network configuration to `iwd/<SSID>.psk` (if required) and SSH
key(s) to `authorized_keys`. This will create a custom image that will
automatically connect to any wired and configured wireless networks (using
`iwd` and `systemd-networkd`) and has `sshd` enabled. Hostname will be
`archiso`.

```shell
sudo make build
```

The resulting image will be `archlinux-*-x86_64.iso`.

## Boot and manual setup

Manually `dd` and boot image, `fdisk`, `cryptsetup`, LVM, `mkfs`, etc.

## Install

The install script will have been copied over to the ISO. Determine the
necessary cmdline for the new system and install, e.g.:

```shell
./install.sh /mnt hostname "cryptdevice=UUID=<UUID>:root:allow-discards root=/dev/mapper/root rw"
```
