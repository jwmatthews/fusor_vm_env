#!/bin/sh

setenforce 0

yum -y localinstall http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum -y localinstall https://www.softwarecollections.org/en/scls/rhscl/v8314/epel-7-x86_64/download/rhscl-v8314-epel-7-x86_64.noarch.rpm
yum -y localinstall https://www.softwarecollections.org/en/scls/rhscl/ruby193/epel-7-x86_64/download/rhscl-ruby193-epel-7-x86_64.noarch.rpm
yum -y localinstall http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm


