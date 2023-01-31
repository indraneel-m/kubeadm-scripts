
Vagrant.configure("2") do |config|
    config.vm.provision "shell", inline: <<-SHELL
        apt-get update -y
        echo "192.168.200.10  master-node" >> /etc/hosts
        echo "192.168.200.11  worker-node01" >> /etc/hosts
        echo "192.168.200.12  worker-node02" >> /etc/hosts
        echo "192.168.200.13  worker-node02" >> /etc/hosts
    SHELL

    $kernel_dep_packages = './scripts/kernel-builder/kernel-deb-packages.tar'
    if (File.exist?("#$kernel_dep_packages")) then
      config.vm.provision "file",
                          source: "#$kernel_dep_packages",
                          destination: "kernel-deb-packages.tar"

      config.vm.provision "shell", reboot: true, inline: <<-SHELL
          tar xf kernel-deb-packages.tar
          dpkg -i linux-headers*.deb linux-image*.deb linux-libc-dev*.deb
          rm kernel-deb-packages.tar
          rm *.deb
      SHELL
    end

    config.vm.define "master" do |master|
      master.vm.box = "generic/debian11"
      master.vm.hostname = "master-node"
      master.vm.network "private_network", ip: "192.168.200.10"
      master.vm.provider :libvirt do |libvirt|
        libvirt.cpus = 8
        libvirt.memory = 8192
        libvirt.cpu_mode = "host-passthrough"
#        libvirt.pci :bus => '0x01', :slot => '0x00', :function => '0x0'
#        libvirt.pci :bus => '0x02', :slot => '0x00', :function => '0x0'
      end
      master.vm.provision :shell, path: "./scripts/vm-setup.sh", privileged: false
      master.vm.provision :shell, path: "./scripts/master-setup.sh", privileged: false
      master.vm.provision :shell, path: "./scripts/startup.sh", privileged: false, run: 'always'
      master.vm.synced_folder "testfiles/", "/home/vagrant/testfiles", type: "9p", accessmode: "passthrough"
    end

    (1..3).each do |i|

    config.vm.define "node0#{i}" do |node|
      node.vm.box = "generic/debian11"
      node.vm.hostname = "worker-node0#{i}"
      node.vm.network "private_network", ip: "192.168.200.1#{i}"
      node.vm.provider :libvirt do |libvirt|
        libvirt.cpus = 3
        libvirt.memory = 8192
        libvirt.cpu_mode = "host-passthrough"
      end
      node.vm.provision :shell, path: "./scripts/vm-setup.sh", privileged: false
      node.vm.provision :shell, path: "./scripts/startup.sh", privileged: false, run: 'always'
    end
    end
  end
