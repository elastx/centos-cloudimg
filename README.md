# CentOS Cloudimg

This git repo contain Packer and kickstart files to define and build CentOS cloud images optimized for [Elastx OpenStack IaaS](https://elastx.se).

- [centos-7-ext4.ks](httpdir/centos-7-ext4.ks) is based on the kickstarter file used for building official CentOS 7 cloud image ([source](https://git.centos.org/centos/kickstarts/blob/master/f/CentOS-7-GenericCloud.ks)).
- [centos-8-ext4.ks](httpdir/centos-8-ext4.ks) is based on the kickstarter file used for building official CentOS 8 cloud image ([source](https://git.centos.org/centos/kickstarts/blob/master/f/CentOS-8-Stream-GenericCloud.ks)).

## Prerequisites
These prerequisites are written for Ubuntu 20.04.

1. `qemu-system-x86`, `qemu-utils` and a working installation of [Packer](https://www.packer.io/). Tested version is **v1.7.2**.

2. `curl` and `sed` already installed on your system if you want to dynamically build from latest rolling upgrade release.

3. For testing you also need `mtools`.

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

## Testing the image

If you want to run the image locally, you can do so by running
`make run-centos-7`.

> 💡 **Tip:** You can exit out of QEMU using `Ctrl+a + x`.
You might need to run `stty sane` afterwards if you exited QEMU in a state
where the terminal was set up in a funny way.

The make command will create a cloud-init configuration bundle using
VFAT which the machine will then pick up. The built image is mounted as
copy-on-write, if you want to reset your test environment you can do so by
executing `rm -iv images/*-test.img`.

The username / password is set to be `centos` / `centos` in the test
environment. It will have internet access, and you can SSH into the instance
by running `ssh -o NoHostAuthenticationForLocalhost=yes -p 5555 localhost -l centos`.
