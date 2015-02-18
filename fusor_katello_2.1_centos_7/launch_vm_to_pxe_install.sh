
DATE=`date +"%Y%m%d"`
NAME="pxe_example_vm_${DATE}"
DISK_SIZE="10"
MEMORY="1024"
CPUS="1"
FUSOR_NETWORK="fusor_net1"

echo "Verifying expected network:"
virsh net-info fusor_net1
if [ "$?" != 0 ]; then
  echo "Unable to find network: ${FUSOR_NETWORK}"
  echo "Perhaps you want to run as 'sudo'?"
  echo "Please update and continue."
fi


virt-install \
 -n ${NAME} \
 --description "VM for testing PXE boot" \
 --os-type=Linux \
 --os-variant=rhel6 \
 --ram=${MEMORY} \
 --vcpus=${CPUS} \
 --disk path=/var/lib/libvirt/images/${NAME}.img,bus=virtio,size=${DISK_SIZE} \
 --graphics vnc \
 --pxe \
 --network network=${FUSOR_NETWORK}

