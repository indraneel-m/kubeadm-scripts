
Vagrant.configure("2") do |config|
    config.vm.provision "shell", inline: <<-SHELL
        apt-get update -y
        echo "192.168.200.10  master-node" >> /etc/hosts
        echo "192.168.200.11  worker-node01" >> /etc/hosts
        echo "192.168.200.12  worker-node02" >> /etc/hosts
    SHELL

    config.vm.define "master" do |master|
      master.vm.box = "generic/debian11"
      master.vm.hostname = "master-node"
      master.vm.network "private_network", ip: "192.168.200.10"
      master.vm.provider :libvirt do |libvirt|
        libvirt.cpus = 8
        libvirt.memory = 81920
        libvirt.cpu_mode = "host-passthrough"
      end
      master.vm.provision :shell, path: "./scripts/vm-setup.sh", privileged: false
      master.vm.provision :shell, path: "./scripts/master-setup.sh", privileged: false
      master.vm.provision :shell, path: "./scripts/install-local-podman-registry.sh", privileged: false
      master.vm.provision :shell, path: "./scripts/startup.sh", privileged: false, run: 'always'
      master.vm.synced_folder "testfiles/", "/home/vagrant/testfiles", type: "9p", accessmode: "passthrough"
    end

    config.vm.define "master" do |node01|
      node01.vm.provider :libvirt do |libvirt|
        libvirt.cpus = 8
        libvirt.memory = 81920
        libvirt.cpu_mode = "host-passthrough"
        libvirt.pci :bus => '0x01', :slot => '0x00', :function => '0x0'
        libvirt.pci :bus => '0x02', :slot => '0x00', :function => '0x0'
      end
    end

    (1..2).each do |i|

    config.vm.define "node0#{i}" do |node|
      node.vm.box = "generic/debian11"
      node.vm.hostname = "worker-node0#{i}"
      node.vm.network "private_network", ip: "192.168.200.1#{i}"
      node.vm.provider :libvirt do |libvirt|
        libvirt.cpus = 2
        libvirt.memory = 4096
        libvirt.cpu_mode = "host-passthrough"
      end
      node.vm.provision :shell, path: "./scripts/vm-setup.sh", privileged: false
      node.vm.provision :shell, path: "./scripts/startup.sh", privileged: false, run: 'always'
    end
    end
  end
