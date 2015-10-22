Vagrant.configure("2") do |config|

  config.vm.provider :vmware_fusion do | v, override |
    v.gui = true
    v.vmx["ethernet0.virtualDevice"] = "vmxnet3"
  end

  config.ssh.insert_key = false

end
