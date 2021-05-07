text
# System authorization information
auth --enableshadow --passalgo=sha512
# Reboot after installation
shutdown
# Use network installation
url --url="http://mirror.centos.org/centos/8/BaseOS/x86_64/os"
# Firewall configuration
firewall --enabled --service=ssh
firstboot --disable
ignoredisk --only-use=vda
# Keyboard layouts
keyboard us
# System language
lang en_US.UTF-8
repo --name="AppStream" --baseurl="http://mirror.centos.org/centos/8/AppStream/x86_64/os/" --cost=100
repo --name="extras" --baseurl="http://mirror.centos.org/centos/8/extras/x86_64/os/" --cost=100
# Network information
network  --bootproto=dhcp
network  --hostname=localhost.localdomain
# Root password
rootpw --iscrypted thereisnopasswordanditslocked
selinux --enforcing
services --disabled="kdump" --enabled="NetworkManager,sshd,rsyslog,chronyd,cloud-init,cloud-init-local,cloud-config,cloud-final,rngd"
timezone UTC --isUtc
# Disk
bootloader --append="console=ttyS0,115200n81 no_timer_check net.ifnames=0" --location=mbr --timeout=1 --boot-drive=vda
zerombr
clearpart --all --initlabel
reqpart
part / --fstype="ext4" --ondisk=vda --size=4096 --grow

# Disable kdump via Kickstart add-on
# https://docs.centos.org/en-US/centos/install-guide/Kickstart2/
%addon com_redhat_kdump --disable
%end

%post --erroronfail
passwd -d root
passwd -l root

# setup systemd to boot to the right runlevel
rm -f /etc/systemd/system/default.target
ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
echo .

dnf -C -y remove linux-firmware

# Remove firewalld; it is required to be present for install/image building.
# but we dont ship it in cloud
dnf -C -y remove firewalld --setopt="clean_requirements_on_remove=1"
dnf -C -y remove avahi\*

echo -n "Getty fixes"
# although we want console output going to the serial console, we don't
# actually have the opportunity to login there. FIX.
# we don't really need to auto-spawn _any_ gettys.
sed -i '/^#NAutoVTs=.*/ a\
NAutoVTs=0' /etc/systemd/logind.conf

echo -n "Network fixes"
# initscripts don't like this file to be missing.
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
NOZEROCONF=yes
EOF

# Remove build-time resolvers to fix #16948
echo > /etc/resolv.conf

# For cloud images, 'eth0' _is_ the predictable device name, since
# we don't want to be tied to specific virtual (!) hardware
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules
rm -f /etc/sysconfig/network-scripts/ifcfg-*

# simple eth0 config, again not hard-coded to the build hardware
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
BOOTPROTOv6="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
USERCTL="yes"
PEERDNS="yes"
IPV6INIT="no"
PERSISTENT_DHCLIENT="1"
EOF

# set virtual-guest as default profile for tuned
echo "virtual-guest" > /etc/tuned/active_profile

# generic localhost names
cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

EOF
echo .

systemctl mask tmp.mount

# Set python => python3
update-alternatives --set python /usr/bin/python

cat <<EOL > /etc/sysconfig/kernel
# UPDATEDEFAULT specifies if new-kernel-pkg should make
# new kernels the default
UPDATEDEFAULT=yes

# DEFAULTKERNEL specifies the default kernel package type
DEFAULTKERNEL=kernel
EOL

# make sure firstboot doesn't start
echo "RUN_FIRSTBOOT=NO" > /etc/sysconfig/firstboot

# centos cloud user
echo -e 'centos\tALL=(ALL)\tNOPASSWD: ALL' >> /etc/sudoers
sed -i 's/name: cloud-user/name: centos/g' /etc/cloud/cloud.cfg

# Mitigate CVE-2021-20271 (https://github.com/elastx/team-infra/issues/175)
echo '%_pkgverify_level all' > /etc/rpm/macros

echo "Cleaning old yum repodata."
dnf clean all

# XXX instance type markers - MUST match CentOS Infra expectation
echo 'genclo' > /etc/yum/vars/infra

# change dhcp client retry/timeouts to resolve #6866
cat  >> /etc/dhcp/dhclient.conf << EOF

timeout 300;
retry 60;
EOF

# clean up installation logs
rm -rf /root/anaconda-ks.cfg
rm -rf /root/original-ks.cfg
rm -rf /root/anac*
rm -rf /root/install.log
rm -rf /root/install.log.syslog
rm -rf /var/lib/dnf/*
rm -rf /var/lib/yum/*
rm -rf /var/log/anaconda*
rm -rf /var/log/dnf.log
rm -rf /var/log/yum.log

rm -f /var/lib/systemd/random-seed

cat /dev/null > /etc/machine-id

echo "Fixing SELinux contexts."
touch /var/log/cron
touch /var/log/boot.log
mkdir -p /var/cache/yum
/usr/sbin/fixfiles -R -a restore

# reorder console entries
sed -i 's/console=tty0/console=tty0 console=ttyS0,115200n8/' /boot/grub2/grub.cfg

#echo "Zeroing out empty space."
# This forces the filesystem to reclaim space from deleted files
dd bs=1M if=/dev/zero of=/var/tmp/zeros || :
rm -f /var/tmp/zeros
echo "(Don't worry -- that out-of-space error was expected.)"

true

%end

%packages --excludedocs
@core
chrony
cloud-init
cloud-utils-growpart
dracut-config-generic
dracut-norescue
dnf
dnf-utils
firewalld
grub2
kernel
NetworkManager
nfs-utils
rsync
tar
-aic94xx-firmware
-alsa-firmware
-alsa-lib
-alsa-tools-firmware
-biosdevname
-dracut-config-rescue
-iprutils
-ivtv-firmware
-iwl100-firmware
-iwl1000-firmware
-iwl105-firmware
-iwl135-firmware
-iwl2000-firmware
-iwl2030-firmware
-iwl3160-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6000g2b-firmware
-iwl6050-firmware
-iwl7260-firmware
-libertas-sd8686-firmware
-libertas-sd8787-firmware
-libertas-usb8388-firmware
-plymouth

python3-jsonschema
qemu-guest-agent
dhcp-client
-langpacks-*
-langpacks-en

centos-release
rng-tools

%end
