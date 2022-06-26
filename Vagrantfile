# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vbguest.auto_update = false
  config.vm.provider "virtualbox" do |vb, override|
    vb.gui = false
    vb.cpus = 2
    vb.memory = 2048
  end

  # three development boxes: CentOS 6, Debian 10 and Debian 11
  config.vm.define "centos6", primary: true do |centos6|
    centos6.vm.box = "generic/centos6"
    centos6.vm.hostname = "CentOS6-Freeswitch"
    centos6.vm.provider "virtualbox" do |vb|
      vb.name = centos6.vm.hostname
    end
  end

  config.vm.define "debian11" do |debian11|
    debian11.vm.box = "generic/debian11"
    debian11.vm.hostname = "Debian11-Freeswitch"
    debian11.vm.provider "virtualbox" do |vb|
      vb.name = debian11.vm.hostname
    end
  end

  config.vm.synced_folder ".", "/home/vagrant/freeswitch"
  config.vm.provision "shell", privileged: false, inline: <<-'SCRIPT'
    #!/usr/bin/env bash
    set -e

    if command -v apt-get &> /dev/null; then
      sudo apt-get -y update
      sudo apt-get -y upgrade
      sudo apt-get -y install git
    elif command -v yum &> /dev/null; then
      sudo yum -y update
      sudo yum -y install git
    fi

    git clone http://github.com/jmrbcu/dotfiles.git ~/.dotfiles
    ~/.dotfiles/install.sh all
  SCRIPT
end
