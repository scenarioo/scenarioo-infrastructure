Vagrant.require_version ">= 2.0.0"
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64" # aka Ubuntu 16.04 LTS
  config.vm.network :private_network, ip: "192.168.111.222"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 8080, host: 8880
  config.vm.network "forwarded_port", guest: 9200, host: 9200

  config.vm.provider "virtualbox" do |v|
    v.memory = 6024
    v.cpus = 2
  end

  config.vm.define "mainserver"
  config.vm.provision "shell", path: "vagrantSetup.sh"
end