#!/bin/sh
#
# This script is based off of work James Shubin published at:
#  https://ttboj.wordpress.com/2014/01/20/building-base-images-for-vagrant-with-a-makefile/
#  https://github.com/purpleidea/vagrant-builder/blob/master/v7/Makefile
#  https://ttboj.wordpress.com/2015/02/23/building-rhel-vagrant-boxes-with-vagrant-builder/
#
# We are modifying his work to create an image to use for Fusor development.
#
# Below are issues we ran into with using purpleidea/vagrant-builder as-is:
#  - 2/17/15:  I attempted to use 'vagrant-builder' from purpleidea's github repo to generate a CentOS-7 Box.
#              I am not using Docker, nor including any Docker files, this might have broken his script.
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

NAME="fusor_rhel_7.0"
BOX="${NAME}.box"
VERSION="rhel7.0"  # from virt-builder --list
OUTPUT="./output"
SIZE="750"
ROOT_PASSWORD="vagrant"
FILES_DIR="../files"
VIRT_BUILDER_INDEX="${OUTPUT}/index"


which virt-builder
if [ "$?" -ne "0" ]; then
    echo "Please install 'libguestfs-tools-c' before proceeding"
    exit
fi

[ -d ${OUTPUT} ] || mkdir -p ${OUTPUT}/	

RHN_CREDENTIALS="./credentials"
if [ ! -f ${RHN_CREDENTIALS} ]; then
    echo "Unable to continue, we need credentials for registering with subscription-manager in ${RHN_CREDENTIALS}"
    exit
fi

source ${RHN_CREDENTIALS}
if [ "${RHN_USER}" == "" ]; then
    echo "Unable to find a value for RHN_USER being set and exported in ${RHN_CREDENTIALS}"
    exit
fi
if [ "${RHN_PASS}" == "" ]; then
    echo "Unable to find a value for RHN_PASS being set and exported in ${RHN_CREDENTIALS}"
    exit
fi

if [ ! -f ${VIRT_BUILDER_INDEX} ]; then
    echo "Please create an image template for '${VERSION}' which can be used by virt-builder"
    echo "Run:  ./create_rhel7_virt_builder_image.sh PATH_TO_ISO"
    exit
fi


echo "Running virt-builder"
virt-builder --delete-cache  # Deleting cache to avoid problems if this is called multiplt times
virt-builder ${VERSION} \
  --run-command "subscription-manager register --username='${RHN_USER}' --password='${RHN_PASS}' --auto-attach" \
  --no-check-signature \
  --fingerprint 'BOGUS, see https://bugzilla.redhat.com/show_bug.cgi?id=1193237' \
  --source file://`realpath ${VIRT_BUILDER_INDEX}` \
  --output ${OUTPUT}/builder.img \
  --format qcow2 \
  --size ${SIZE}G \
  --install rsync,nfs-utils,sudo,openssh-server,openssh-clients,screen,tar,net-tools,vim-enhanced \
  --root-password password:${ROOT_PASSWORD} \
  --run ${FILES_DIR}/user.sh \
  --run ${FILES_DIR}/ssh.sh \
  --run-command 'sed -i s"/SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux' \
  --run-command 'systemctl disable firewalld' \
  --run-command 'systemctl enable sshd' \
  --run-command 'yum clean all' \
  --run-command 'touch /.autorelabel' \
  --run-command "subscription-manager unregister"

if [ "$?" -ne "0" ]; then
  echo "Error running 'virt-builder' so quitting now"
  exit
fi

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
tar -cvzf ${OUTPUT}/${BOX} ../Vagrantfile --directory=${OUTPUT}/ ./metadata.json ./box.img

echo "To import this into vagrant run:"
echo "vagrant box add ${OUTPUT}/${BOX} --name ${NAME}"
