ifdef CPU_FLAG
CPU_FLAG := $(CPU_FLAG)
else
CPU_FLAG := host
endif

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
	PACKER_LOG=1 packer build -var cpu_flag="$(CPU_FLAG)" centos-8.pkr.hcl

build-centos-9:
	PACKER_LOG=1 packer build -var cpu_flag="$(CPU_FLAG)" centos-9.pkr.hcl

build-rocky-8:
	PACKER_LOG=1 packer build -var cpu_flag="$(CPU_FLAG)" rocky-8.pkr.hcl

build-rocky-9:
	PACKER_LOG=1 packer build -var cpu_flag="$(CPU_FLAG)" rocky-9.pkr.hcl

all: clean clean-cache install_deps prepare
