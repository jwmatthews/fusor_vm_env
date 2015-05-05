install
text
lang en_US.UTF-8
keyboard us
network --bootproto dhcp
rootpw vagrant
firewall --enabled --ssh
timezone --utc America/New_York
selinux --permissive

services --disabled="NetworkManager" --enabled="network"

bootloader --location=mbr --append="console=tty0 console=ttyS0,115200 rd_NO_PLYMOUTH"
zerombr
clearpart --all --initlabel
part /boot --fstype=ext4 --size=512 --asprimary
part swap --size=1024 --asprimary
part / --fstype=ext4 --size=1024 --grow --asprimary

poweroff

%packages
@core
-NetworkManager

%end

%post
#
# Putting in a workaround so the eth0 config file will work with 'service network restart'
# Needed for fusor-installer's puppet networking module which is not working well with:
#  RHEL 7.1 and coexistence of NetworkManager & network scripts
#
if [ -f /etc/sysconfig/network-scripts/ifcfg-eth0 ]; then
  grep "DEVICE=" /etc/sysconfig/network-scripts/ifcfg-eth0 &> /dev/null
  if [ "$?" -ne "0" ]; then
    echo 'DEVICE="eth0"' >> /etc/sysconfig/network-scripts/ifcfg-eth0
  fi
fi
%end

