
PACKER_VERSION=1.7.2
PACKER_DOWNLOAD_BASE_URL=https://releases.hashicorp.com/packer/${PACKER_VERSION}
PACKER_CHECKSUM=packer_${PACKER_VERSION}_SHA256SUMS
UNAME_S := $(shell uname -s | tr A-Z a-z)
PACKER_BIN=packer_${PACKER_VERSION}_${UNAME_S}_amd64.zip
PACKER_INSTALLED_VERSION := $(shell ./packer --version)

CENTOS7_IMAGE=$(shell curl -s http://mirror.nsc.liu.se/centos/7/isos/x86_64/sha256sum.txt | sed -n "s/^.*\(CentOS-7-x86_64-Minimal-[0-9]\+\.iso\).*$$/\1/p")
CENTOS8_IMAGE=$(shell curl -s http://mirror.nsc.liu.se/CentOS/8-stream/isos/x86_64/CHECKSUM | sed -n "s/^SHA256 (\(CentOS-Stream-8-x86_64-[0-9]\+-boot\.iso\)).*$$/\1/p")

ifeq ($(shell uname),Linux)
ACCEL ?= "kvm"
else ifeq ($(shell uname),Darwin)
ACCEL ?= "hvf"
else
ACCEL ?= "tcg"
endif


.PHONY: default
default: clean prepare build

.PHONY: clean
clean:
	rm -rf images

.PHONY: clean-cache
clean-cache:
	rm -rf packer_cache

.PHONY: prepare
prepare:
ifneq (${PACKER_INSTALLED_VERSION},${PACKER_VERSION})
	curl -o ${PACKER_BIN} -fSL "${PACKER_DOWNLOAD_BASE_URL}/${PACKER_BIN}"
	curl -o ${PACKER_CHECKSUM} -fSL "${PACKER_DOWNLOAD_BASE_URL}/${PACKER_CHECKSUM}"
	sha256sum -c --ignore-missing ${PACKER_CHECKSUM}
	unzip -o ${PACKER_BIN} packer
	rm -f ${PACKER_BIN} ${PACKER_CHECKSUM}
endif

.PHONY: build
build:
	./packer build \
		-var centos7_image=${CENTOS7_IMAGE} \
		-var centos8_image=${CENTOS8_IMAGE} \
		build-cloudimg.json

images/%-test.img: images/%
	qemu-img create -f qcow2 \
		-o backing_file="$(shell basename $<)" "$@"

images/cloudconfig-test.img: test/user-data test/meta-data
	truncate -s 2M "$@"
	mkfs.vfat -n cidata "$@"
	mcopy -oi "$@" $^ ::
	mdir -i "$@" ::

run-%: images/%-latest-test.img images/cloudconfig-test.img
	qemu-system-x86_64 \
		-m 512 \
		-drive file="$<",if=virtio,format=qcow2 \
		-drive file=images/cloudconfig-test.img,if=virtio,format=raw \
		-device virtio-net-pci,romfile=,netdev=net0 \
		-netdev user,hostfwd=tcp::5555-:22,id=net0 \
		-accel "$(ACCEL)" \
		-machine type=q35,smm=on,usb=on \
		-serial mon:stdio \
		-no-reboot \
		-nographic \

.PHONY: all
all: clean clean-cache prepare build
