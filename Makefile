CPU_FLAG ?= host

default: clean prepare

prepare:
	packer init plugin.pkr.hcl

install_deps:
	curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
	apt-add-repository --yes "deb [arch=amd64] https://apt.releases.hashicorp.com focal main" && \
	apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get -y install packer qemu-system-x86

clean:
	rm -rf images

clean-cache:
	rm -rf ${HOME}/.cache/packer/

clean-packer:
	rm -rf ${HOME}/.config/packer/

build-centos-8:
	PACKER_LOG=1 packer build centos-8.pkr.hcl -var cpu_flag=${CPU_FLAG}

build-centos-9:
	PACKER_LOG=1 packer build centos-9.pkr.hcl -var cpu_flag=${CPU_FLAG}

build-rocky-8:
	PACKER_LOG=1 packer build rocky-8.pkr.hcl -var cpu_flag=${CPU_FLAG}

all: clean clean-cache install_deps prepare
