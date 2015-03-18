install
text
lang en_US.UTF-8
keyboard us
network --bootproto dhcp
rootpw vagrant
firewall --enabled --ssh
timezone --utc America/New_York
selinux --permissive

bootloader --location=mbr --append="console=tty0 console=ttyS0,115200 rd_NO_PLYMOUTH"
zerombr
clearpart --all --initlabel
part /boot --fstype=ext4 --size=512 --asprimary
part swap --size=1024 --asprimary
part / --fstype=xfs --size=1024 --grow --asprimary

poweroff

%packages
@core

%end
