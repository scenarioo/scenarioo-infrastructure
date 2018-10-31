Vagrant.require_version ">= 1.8.0"
# For vagrant < 2.x fix place where base boxes are fetched https://github.com/hashicorp/vagrant/issues/9442
Vagrant::DEFAULT_SERVER_URL.replace('https://vagrantcloud.com')
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64" # aka Ubuntu 16.04 LTS
  config.vm.network :private_network, ip: "192.168.111.222"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 8080, host: 8880
  config.vm.network "forwarded_port", guest: 9200, host: 9200

  config.vm.provider "virtualbox" do |v|
    v.memory = 4024
    v.cpus = 2
  end

  # Don't replace the default insecure key or our dockerized ansible won't be able to login
  config.ssh.insert_key = false
  config.vm.define "mainserver"
  config.vm.provision "shell", inline: "apt-get -y update; apt-get -y install jq bats"
end