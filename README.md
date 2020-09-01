# CentOS Cloudimg

This git repo contain Packer and kickstart files to define and build CentOS cloud images optimized for [Elastx OpenStack IaaS](https://elastx.se).

[centos-7-ext4.ks](httpdir/centos-7-ext4.ks) is based on the kickstarter file used for building official CentOS 7 cloud image ([source](https://git.centos.org/centos/kickstarts/blob/master/f/CentOS-7-GenericCloud.ks)).
https://git.centos.org/centos/kickstarts/raw/master/f/CentOS-8-GenericCloud.ks
[centos-8-ext4.ks](httpdir/centos-8-ext4.ks) is based on the kickstarter file used for building official CentOS 8 cloud image ([source](https://git.centos.org/centos/kickstarts/blob/master/f/CentOS-8-Stream-GenericCloud.ks)).

## Prerequisites

1. `qemu-kvm` and a working installation of [Packer](https://www.packer.io/). Tested version is **v1.6.1**.

2. `curl` and `sed` already installed on your system if you want to dynamically build from latest rolling upgrade release.

## Building the image

The images built with Packer will be located in **images** directory.

### Make

If you have `make` installed you can simply run `make` to build images.

### Shell

In case you are located outside of Sweden, or if the mirror is down, you will want to change value for `iso_url` and `iso_checksum` inside **build-cloudimg.json** to an address closer to your location.

Execute the following command to build your image.

    packer build \
      -var centos7_image=$(curl -s http://mirror.nsc.liu.se/centos/7/isos/x86_64/sha256sum.txt | sed -n "s/^.*\(CentOS-7-x86_64-Minimal-[0-9]\+\.iso\).*$/\1/p") \
      -var centos8_image=$(curl -s http://mirror.nsc.liu.se/CentOS/8-stream/isos/x86_64/CHECKSUM | sed -n "s/^SHA256 (\(CentOS-Stream-8-x86_64-[0-9]\+-boot\.iso\)).*$/\1/p")
      build-cloudimg.json
