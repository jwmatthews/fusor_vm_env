#!/bin/sh

setenforce 0

yum install -y wget
wget http://ec2-23-22-86-129.compute-1.amazonaws.com/pub/fusor_el7_x86_64.repo -O /etc/yum.repos.d/fusor_el7_x86_64.repo

yum update -y nss
yum -y localinstall http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum -y localinstall https://www.softwarecollections.org/en/scls/rhscl/v8314/epel-7-x86_64/download/rhscl-v8314-epel-7-x86_64.noarch.rpm
yum -y localinstall https://www.softwarecollections.org/en/scls/rhscl/ruby193/epel-7-x86_64/download/rhscl-ruby193-epel-7-x86_64.noarch.rpm
yum -y localinstall http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm

yum -y localinstall http://koji.katello.org/releases/yum/katello-2.1/katello/RHEL/7Server/x86_64/katello-repos-2.1.3-1.el7.noarch.rpm
yum -y localinstall http://yum.theforeman.org/releases/1.7/el7/x86_64/foreman-release.rpm

yum -y install katello
yum -y install fusor-installer
yum -y install ruby193-rubygem-fusor_ui
yum -y install foreman-discovery-image


