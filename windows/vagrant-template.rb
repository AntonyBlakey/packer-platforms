Vagrant.configure("2") do |config|

  config.vm.guest = :windows
  config.vm.communicator = "winrm"

  config.winrm.username = "vagrant"
  config.winrm.password = "vagrant"

  # config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct:true
  config.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct:true
  config.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct:true

  config.vm.provider :vmware_fusion do | v, override |
    v.gui = true
    v.vmx["ethernet0.virtualDev"] = "vmxnet3"
  end

end
