# CentOS Cloudimg

This git repo contain Packer and kickstart files to define and build CentOS cloud images optimized for [Elastx OpenStack IaaS](https://elastx.se).

- [centos8-ext4.ks](httpdir/centos8-ext4.ks) is based on the kickstart file used for building official CentOS 8 Stream cloud image ([source](https://git.centos.org/centos/kickstarts/blob/master/f/CentOS-8-Stream-GenericCloud.ks)).
- [centos9-ext4.ks](httpdir/centos9-ext4.ks) is based on the kickstart file used for building official CentOS 9 Stream cloud image ([source](https://gitlab.com/redhat/centos-stream/release-engineering/kickstarts/-/blob/main/CentOS-Stream-9-kvm-x86_64.ks)).
- [rocky8-ext4.ks](httpdir/rocky8-ext4.ks) is based on the kickstart file used for building official Rocky 8 images ([source](https://git.rockylinux.org/rocky/kickstarts/-/blob/r8/Rocky-8-GenericCloud.ks)).
- [rocky9-ext4.ks](httpdir/rocky9-ext4.ks) is based on the kickstart file used for building official Rocky 8 images ([source](https://git.rockylinux.org/rocky/kickstarts/-/blob/r9/Rocky-9-GenericCloud.ks)).

## Prerequisites
These prerequisites are written for Ubuntu 20.04.

1. `qemu-system-x86`, `qemu-utils` and a working installation of [Packer](https://www.packer.io/). Tested version is **v1.7.2**.

2. `curl` and `sed` already installed on your system if you want to dynamically build from latest rolling upgrade release.

3. For testing you also need `mtools` and optionally `tigervnc-viewer`, `remmina` or any other VNC viewer.

## Building the image

The images built with Packer will be located in **images** directory.

### Make

If you have `make` installed you can simply run `make` and `make build-centos8` to build a Centos 8 Stream image.

### Shell

In case you are located outside of Sweden, or if the mirror is down, you will want to change value for `iso_url` and `iso_checksum` inside **build-cloudimg.json** to an address closer to your location.

Execute the following command to build your image.

    packer build \
      -var iso_url="http://mirror.nsc.liu.se/CentOS/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-latest-boot.iso" \
      -var iso_checksum="file:http://mirror.nsc.liu.se/CentOS/8-stream/isos/x86_64/CHECKSUM" \
      centos8.pkr.hcl

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

### Debugging

Sadly `packer` relies heavily on VNC for their QEMU integration and thus you need
to use VNC to access the terminal to read logs. This is very silly and not great.
There is a PR available (#4) for exporting log files instead, but it is not ready
right now.

To connect to the debug terminal, see the log message from `packer` to see what port
QEMU is listening. Example: `vncviewer 127.0.0.1:5975`.
