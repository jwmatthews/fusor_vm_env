#!/bin/bash --login

sudo setenforce 0
sudo yum -y localinstall http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm

gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -L https://get.rvm.io | bash -s stable
source ~/.profile
rvm install ruby-1.9.3
rvm use --default ruby-1.9.3
gem install bundler



