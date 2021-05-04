
PACKER_VERSION=1.7.2
PACKER_DOWNLOAD_BASE_URL=https://releases.hashicorp.com/packer/${PACKER_VERSION}
PACKER_CHECKSUM=packer_${PACKER_VERSION}_SHA256SUMS
UNAME_S := $(shell uname -s | tr A-Z a-z)
PACKER_BIN=packer_${PACKER_VERSION}_${UNAME_S}_amd64.zip
PACKER_INSTALLED_VERSION := $(shell ./packer --version)

CENTOS7_IMAGE=$(shell curl -s http://mirror.nsc.liu.se/centos/7/isos/x86_64/sha256sum.txt | sed -n "s/^.*\(CentOS-7-x86_64-Minimal-[0-9]\+\.iso\).*$$/\1/p")
CENTOS8_IMAGE=$(shell curl -s http://mirror.nsc.liu.se/CentOS/8-stream/isos/x86_64/CHECKSUM | sed -n "s/^SHA256 (\(CentOS-Stream-8-x86_64-[0-9]\+-boot\.iso\)).*$$/\1/p")


default: clean prepare build 

clean:
	rm -rf images

clean-cache:
	rm -rf packer_cache

prepare:
ifneq (${PACKER_INSTALLED_VERSION},${PACKER_VERSION})
	curl -o ${PACKER_BIN} -fSL "${PACKER_DOWNLOAD_BASE_URL}/${PACKER_BIN}"
	curl -o ${PACKER_CHECKSUM} -fSL "${PACKER_DOWNLOAD_BASE_URL}/${PACKER_CHECKSUM}"
	sha256sum -c --ignore-missing ${PACKER_CHECKSUM}
	unzip -o ${PACKER_BIN} packer
	rm -f ${PACKER_BIN} ${PACKER_CHECKSUM}
endif

build:
	./packer build -var centos7_image=${CENTOS7_IMAGE} -var centos8_image=${CENTOS8_IMAGE} build-cloudimg.json

all: clean clean-cache prepare build
