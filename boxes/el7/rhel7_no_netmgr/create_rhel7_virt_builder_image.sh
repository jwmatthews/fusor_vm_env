#!/bin/sh

##
# This script will create an image template usable by virt-builder
# Requires an OS ISO and a Kickstart
##

if [ "$#" -ne 1 ]; then
  echo "Please re-run with path to an OS ISO as an argument"
  echo "Usage: $0 PATH_TO_ISO"
  exit 1
fi
ISO=$1

NAME="rhel7.1"
OUTPUT_DIR="./output"
OUTPUT_IMAGE="${OUTPUT_DIR}/${NAME}"
KS="./rhel7.ks"
VM_NAME=${NAME}`date +"%Y%m%d%H%M"`

[ -d ${OUTPUT_DIR} ] || mkdir -p ${OUTPUT_DIR}/	

if [ -d ${OUTPUT_IMAGE} ]; then
    echo "${OUTPUT_IMAGE} exists"
    echo "Please delete and re-run if you want to regenerate this file"
    exit
fi

sudo virt-install \
  --name=${VM_NAME} \
  --ram=2048 \
  --cpu=host --vcpus=2 \
  --os-type=linux --os-variant=rhel7 \
  --initrd-inject=${KS} \
  --extra-args="ks=file:/`basename ${KS}` console=tty0 console=ttyS0,115200" \
  --disk "${OUTPUT_IMAGE},size=6" \
  --serial pty \
  --location="${ISO}" \
  --nographics \
  --noreboot


sudo virt-sysprep -a ${OUTPUT_IMAGE}
sudo virt-sparsify --in-place ${OUTPUT_IMAGE}
sudo xz --best --block-size=16777216 ${OUTPUT_IMAGE}

sudo chown $USER ${OUTPUT_IMAGE}.xz

#
# Creates an index file which will be passed to virt-builder so it sees this image template we built
#
cat << EOF > ${OUTPUT_DIR}/index
[${NAME}]
name=${NAME}
#osinfo=${NAME}
arch=x86_64
file=`python -c "import os.path; print(os.path.relpath('${OUTPUT_IMAGE}.xz', '${OUTPUT_DIR}'))"`
checksum[sha512]=`sha512sum ${OUTPUT_IMAGE}.xz | awk '{print $1}'`
format=raw
# hardcoded to 6GiB
size=6442450944
compressed_size=`stat -c %s ${OUTPUT_IMAGE}.xz`
expand=/dev/sda3
notes=Built on `date` by ${USER}
hidden=true
EOF


