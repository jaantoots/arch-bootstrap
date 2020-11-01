ARCH ?= x86_64
ARCHISO ?= archlinux-$(shell date '+%Y.%m.%d')-$(ARCH).iso

mirrorlist:
	reflector --verbose --sort rate --score 64 --fastest 16 > $@

archlive:
	cp -av /usr/share/archiso/configs/releng/ $@
	install -Dm644 -t $@/airootfs/etc vconsole.conf
	install -Dm600 -t $@/airootfs/var/lib/iwd iwd/*.psk
	install -Dm700 -d $@/airootfs/root/.ssh
	install -Dm600 -t $@/airootfs/root/.ssh authorized_keys
	ln -s /usr/lib/systemd/system/sshd.service $@/airootfs/etc/systemd/system/multi-user.target.wants/
	# Add install script
	install -Dm755 -t $@/airootfs/root install.sh

archlinux-%.iso: archlive
	mkarchiso -v -w /tmp/mkarchiso-work -o . $<

.PHONY: build
build: $(ARCHISO)

.PHONY: clean
clean:
	rm -rf archlive mirrorlist

ROOT = https://www.archlinux.org/iso
MIRROR ?= https://mirror.rackspace.com/archlinux/iso
RELEASE ?= 2019.10.01

.PHONY: image
image: archlinux-bootstrap-$(RELEASE)-$(ARCH).tar.gz.sig archlinux-bootstrap-$(RELEASE)-x86_64.tar.gz
	gpg --verify $<

archlinux-bootstrap-%-$(ARCH).tar.gz:
	wget $(MIRROR)/$*/$@

archlinux-bootstrap-%-$(ARCH).tar.gz.sig:
	wget $(ROOT)/$*/$@
