
Vagrant.configure("2") do |config|
    config.vm.provision "shell", inline: <<-SHELL
        apt-get update -y
        echo "10.0.0.10  master-node" >> /etc/hosts
        echo "10.0.0.11  worker-node01" >> /etc/hosts
        echo "10.0.0.12  worker-node02" >> /etc/hosts
    SHELL
    
    config.vm.define "master" do |master|
      master.vm.box = "generic/ubuntu2010"
      master.vm.hostname = "master-node"
      master.vm.network "private_network", ip: "10.0.0.10"
      master.vm.provider :libvirt do |libvirt|
        libvirt.cpus = 4
        libvirt.memory = 4048
        libvirt.cpu_mode = "host-passthrough"
      end
      master.vm.provision "file",
                        source: "./scripts/master.sh",
                        destination: "master.sh"
      master.vm.provision :shell do |shell|
        shell.path = "./scripts/master.sh"
        shell.reboot = true
      end
    end

    config.vm.define "node01" do |node01|
      node01.vm.provider :libvirt do |libvirt|
        libvirt.cpus = 2
        libvirt.memory = 4048
        libvirt.cpu_mode = "host-passthrough"
        libvirt.pci :bus => '0x02', :slot => '0x00', :function => '0x0'
      end
    end

    (1..2).each do |i|

    config.vm.define "node0#{i}" do |node01|
      node01.vm.box = "generic/ubuntu2010"
      node01.vm.hostname = "worker-node0#{i}"
      node01.vm.network "private_network", ip: "10.0.0.1#{i}"
      node01.vm.provider :libvirt do |libvirt|
        libvirt.cpus = 2
        libvirt.memory = 4048
        libvirt.cpu_mode = "host-passthrough"
      end
      node01.vm.provision "file",
                        source: "./scripts/worker-node.sh",
                        destination: "worker-node.sh"
      node01.vm.provision :shell do |shell|
        shell.path = "./scripts/worker-node.sh"
        shell.reboot = true
      end
    end
    
    end
  end
