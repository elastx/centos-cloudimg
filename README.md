# CentOS Cloudimg

This git repo contain Packer and kickstart files to define and build CentOS cloud images optimized for [Elastx OpenStack IaaS](https://elastx.se).

[centos-7-ext4.ks](httpdir/centos-7-ext4.ks) is based on the kickstarter file used for building official CentOS 7 cloud image ([source](https://github.com/CentOS/sig-cloud-instance-build/blob/8197650d8ef8e8841f77e2d38253ff0e1d8e6fb3/cloudimg/CentOS-7-x86_64-GenericCloud-201606-r1.ks)).

## Prerequisites

1. `qemu-kvm` and a working installation of [Packer](https://www.packer.io/). Tested version is **v1.1.0**.

2. `curl` and `sed` already installed on your system if you want to dynamically build from latest CentOS 7 rolling upgrade release.

## Building the image

In case you are located outside of Sweden, or if the mirror is down, you will want to change value for `iso_url` inside **build-cloudimg.json** to an address closer to your location.

Execute the following command to build your image.

    packer build \
      -var centos7_image=$(curl -s http://mirror.centos.org/centos/7/isos/x86_64/sha256sum.txt | sed -n "s/^.*\(CentOS-7-x86_64-Minimal-[0-9]\+\)\.iso.*$/\1/p") \
      build-cloudimg.json

The image will be located in **build** directory.
