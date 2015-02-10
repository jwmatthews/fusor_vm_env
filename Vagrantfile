# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "fusor.example.com"

  config.vm.box = "centos7"
  config.vm.box_url = "https://download.gluster.org/pub/gluster/purpleidea/vagrant/centos-7.0/centos-7.0.box"
  config.vm.provision :shell, :path => "setup_centos.sh"

  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "kvm"
    libvirt.memory = 4096
    libvirt.cpus = 2
  end
end
