# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.ssh.insert_key = false
  #All roles in one

  #running ansible against all hosts as part of last provsioning job
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.provision "shell", path: "deploy.sh", privileged: false
end
