# -*- mode: ruby -*-
# vi: set ft=ruby :
# Require YAML module
require 'yaml'

# Read YAML file with box details
cluster = YAML.load_file('cluster.yaml')

# Globals
MASTER_IP = cluster['network']['master']

# Generates kubetoken
KUBETOKEN = %x|kubeadm token generate|

# The configuration
Vagrant.configure("2") do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = false
  # forward ssh agent to easily ssh into the different machines
  config.ssh.forward_agent = true

  config.vm.box = cluster['image']
  config.vm.box_check_update = false

  # Master
  config.vm.define "master" do |master|
    # VM config
    master.vm.provider :virtualbox do |vm|
      vm.cpus = 2
      vm.memory = "2048"
      # vm.customize ["modifyhd", "", "--resize", "8000"]

      vm.check_guest_additions = false
      vm.functional_vboxsf = false
    end

    master.vm.hostname = "master"
    # Network
    master.vm.network :private_network, ip: MASTER_IP
    master.vm.network "forwarded_port", guest: 8443, host: 8443
    # kubectl
    master.vm.network "forwarded_port", guest: 6443, host: 6443
    # dashboard
    master.vm.network "forwarded_port", guest: 8001, host: 8001
    # Provisioning
    master.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/host.pub"
    master.vm.provision :shell, path: "provision.sh"
    master.vm.provision :shell, path: "master/provision-master.sh", privileged: false, env: {
        "KUBETOKEN" => KUBETOKEN,
        "MASTER_IP" => MASTER_IP,
        "POD_CIDR" => cluster['pod']['cidr']
    }
  end

  # Minions
  (1..cluster['minions']).each do |i|
    config.vm.define "minion#{i}" do |minion|
      # VM config
      minion.vm.provider "virtualbox" do |vm|
        vm.cpus = 1
        vm.memory = "1024"

        vm.check_guest_additions = false
        vm.functional_vboxsf = false
      end
      minion.vm.hostname = "minion#{i}"
      minion.vm.network :private_network, ip: cluster['network']['minion'] + "#{i + 10}"
      # Provisioning
      minion.vm.provision :shell, path: "provision.sh"
      minion.vm.provision :shell, path: "minion/provision-minion.sh", env: {
          "KUBETOKEN" => KUBETOKEN,
          "MASTER_IP" => MASTER_IP
      }
    end
  end
end