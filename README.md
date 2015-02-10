# fusor_vm_env
Vagrant files to provision Fusor environments

# Overview

* Vagrant configuration using vagrant-libvirt
* CentOS-7
* Katello 2.1
* Foreman 1.7
* Shared folders with NFS


# Fedora 21

* See notes in [host/vagrant_libvirt_setup.txt](host/vagrant_libvirt_setup.txt) for setting up vagrant + libvirt

## NFS Setup

*  On Fedora-21 you may execute this script to setup NFS [host/nfs_setup.sh](host/nfs_setup.sh)
	* It will setup firewalld for NFS as well
		
# Usage
* vagrant up --provider=libvirt		



