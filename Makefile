ROOT = https://www.archlinux.org/iso
MIRROR ?= https://mirror.rackspace.com/archlinux/iso
RELEASE ?= 2019.10.01

mirrorlist:
	reflector --verbose --sort rate --score 64 --fastest 16 > $@

archlive: mirrorlist
	./archlive.sh

.PHONY: image
image: archlinux-bootstrap-$(RELEASE)-x86_64.tar.gz.sig archlinux-bootstrap-$(RELEASE)-x86_64.tar.gz
	gpg --verify $<

.PHONY: clean
clean:
	rm -rf archlinux-bootstrap-*-x86_64.tar.gz archlive mirrorlist

archlinux-bootstrap-%-x86_64.tar.gz:
	wget $(MIRROR)/$*/$@

archlinux-bootstrap-%-x86_64.tar.gz.sig:
	wget $(ROOT)/$*/$@
