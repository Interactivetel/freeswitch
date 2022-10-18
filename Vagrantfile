# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.provider "parallels" do |prl|
    prl.update_guest_tools = true
    prl.memory = 2048
    prl.cpus = 2
  end

  config.vm.provider "virtualbox" do |vb|
    vb.vbguest.auto_update = true
    vb.gui = false
    vb.memory = 2048
    vb.cpus = 2
  end

  # two development boxes: CentOS 6 and Debian 10
  config.vm.define "centos6", primary: true do |centos6|
    centos6.vm.box = "generic/centos6"
    centos6.vm.hostname = "FreeSWITCH-CentOS6"
    
    centos6.vm.provider "virtualbox" do |vb|
      vb.name = centos6.vm.hostname
    end

    centos6.vm.provider "parallels" do |prl|
      prl.update_guest_tools = false
      prl.name = centos6.vm.hostname
    end
  end

  config.vm.define "debian11" do |debian11|
    debian11.vm.box = "generic/debian11"
    debian11.vm.hostname = "FreeSWITCH-Debian11"
    
    debian11.vm.provider "virtualbox" do |vb|
      vb.name = debian11.vm.hostname
    end

    debian11.vm.provider "parallels" do |prl|
      prl.name = debian11.vm.hostname
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
