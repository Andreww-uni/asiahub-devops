Vagrant.configure("2") do |config|
  config.vm.box      = "ubuntu/jammy64"
  config.vm.hostname = "asiahub-server"

  # Збільшуємо таймаут до 5 хвилин
  config.vm.boot_timeout = 300

  config.vm.network "private_network", ip: "192.168.56.20"

  config.vm.provider "virtualbox" do |vb|
    vb.name   = "asiahub-server"
    vb.memory = 2048
    vb.cpus   = 2
    # Для Windows — іноді допомагає
    vb.gui = false
  end

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update -qq
    apt-get install -y -qq curl git
    echo "✅ AsiaHub VM is ready!"
    echo "   IP: 192.168.56.20"
  SHELL
end