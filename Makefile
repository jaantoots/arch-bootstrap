ROOT = https://www.archlinux.org/iso
MIRROR ?= https://mirror.rackspace.com/archlinux/iso
RELEASE ?= 2019.10.01
ARCH ?= x86_64

mirrorlist:
	reflector --verbose --sort rate --score 64 --fastest 16 > $@

archlive: mirrorlist
	./archlive.sh

.PHONY: build
build: archlive
	cd $< && ./build.sh -v
	mv -v $</out/archlinux-*-$(ARCH).iso .

.PHONY: image
image: archlinux-bootstrap-$(RELEASE)-$(ARCH).tar.gz.sig archlinux-bootstrap-$(RELEASE)-x86_64.tar.gz
	gpg --verify $<

.PHONY: clean
clean:
	rm -rf archlinux-bootstrap-*-$(ARCH).tar.gz archlive mirrorlist

archlinux-bootstrap-%-$(ARCH).tar.gz:
	wget $(MIRROR)/$*/$@

archlinux-bootstrap-%-$(ARCH).tar.gz.sig:
	wget $(ROOT)/$*/$@
