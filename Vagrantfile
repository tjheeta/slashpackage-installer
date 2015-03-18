# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  config.vm.provider "virtualbox" do |vb|
    # vb.gui = true
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

  config.vm.provider :lxc do |lxc, override|
    override.vm.box = "fgrehm/trusty64-lxc"
    lxc.backingstore = "btrfs"
  end

  config.vm.provision "shell", inline: "sudo apt-get update && apt-get install -y build-essential"
  config.vm.provision "shell", path: "machine-setup.sh"
end
