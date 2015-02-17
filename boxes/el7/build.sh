#!/bin/sh
#
# This script is based off of work James Shubin published at:
#  https://ttboj.wordpress.com/2014/01/20/building-base-images-for-vagrant-with-a-makefile/
#  https://github.com/purpleidea/vagrant-builder/blob/master/v7/Makefile
#
#
# We are modifying his work to create an image to use for Fusor development.
#
# Below are issues we ran into with using purpleidea/vagrant-builder as-is:
#  - 2/17/15:  I attempted to use 'vagrant-builder' from purpleidea's github repo to generate a CentOS-7 Box.
#              I am not using Docker, nor including any Docker files, this have broken his script.
#
#    Issue-1:  Bumped disk size to 750GB, built image, failed to come up completely.
#                Boots, but fails at a disk check.  Says I need to run fsck
#
#    Issue-2:  Next tried using 'centos-7.0.sh' from same github repo:
#              https://github.com/purpleidea/vagrant-builder/blob/master/v7/versions/centos-7.0.sh
#              VM boots but vagrant runs into a problem with 'sudo' missing from VM.
#
#
# Requires RPM packages:
#  libguestfs-tools-c
#

# Usage:
# 1) Build the box:
#    ./build.sh
# 2) Import the box
#    vagrant box add ${OUTPUT}/${BOX} --name ${NAME}

NAME="fusor_centos_7.0"
BOX="${NAME}.box"
VERSION="centos-7.0"  # from virt-builder --list
OUTPUT="./output"
SIZE="750"
ROOT_PASSWORD="vagrant"

[ -d ${OUTPUT} ] || mkdir -p ${OUTPUT}/	

echo "Running virt-builder"
virt-builder ${VERSION} \
	--output ${OUTPUT}/builder.img \
	--format qcow2 \
	--size ${SIZE}G \
	--install rsync,nfs-utils,sudo,openssh-server,openssh-clients,screen,tar,net-tools \
	--root-password password:${ROOT_PASSWORD} \
	--run files/user.sh \
	--run files/ssh.sh \
	--run-command 'sed -i s"/SELINUX=enforcing/SELINUX=disabled"/g /etc/sysconfig/selinux' \
	--run-command 'systemctl disable firewalld' \
	--run-command 'systemctl enable sshd' \
	--run-command 'yum clean all' \
	--run-command 'touch /.autorelabel'


#
# James made a comment in his Makefile that the below qemu-img convert is needed as a workaround:
#   https://github.com/purpleidea/vagrant-builder/blob/master/v7/Makefile#L144
#
#   workaround sparse qcow2 images bug
#   thread: https://www.redhat.com/archives/libguestfs/2014-January/msg00008.html
echo "Converting image"
qemu-img convert -O qcow2 ${OUTPUT}/builder.img ${OUTPUT}/box.img

echo "{\"provider\": \"libvirt\", \"format\": \"qcow2\", \"virtual_size\": ${SIZE}}" > ${OUTPUT}/metadata.json
echo '' >> ${OUTPUT}/metadata.json	# newline

echo "Compressing files into ${OUTPUT}/${BOX}"
tar -cvzf ${OUTPUT}/${BOX} ./Vagrantfile --directory=${OUTPUT}/ ./metadata.json ./box.img

echo "To import this into vagrant run:"
echo "vagrant box add ${OUTPUT}/${BOX} --name ${NAME}"
