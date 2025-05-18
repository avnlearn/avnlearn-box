
Vagrant.configure("2") do |config|
  # Noble Numbat
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.network "private_network", ip: "192.168.56.10"  # Change this IP as needed
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--name", "avnlearn-box"] 
  end
  config.vm.provision "shell", path: "public/START.sh"
  config.vm.provision "shell", path: "public/bootstrap.sh"
  config.vm.provision "shell", path: "public/php.ini.sh"
  config.vm.provision "shell", path: "public/phpmyadmin/setup.sh"
  config.vm.provision "shell", path: "public/avnlearn/setup.sh"
  config.vm.provision "shell", path: "public/fuelphp/setup.sh"
  config.vm.provision "shell", path: "public/cakephp/setup.sh"
  config.vm.provision "shell", path: "public/codeigniter/setup.sh"
  config.vm.provision "shell", path: "public/laravel/setup.sh"
  config.vm.provision "shell", path: "public/pyrocms/setup.sh"
  config.vm.provision "shell", path: "public/symfony/setup.sh"
  config.vm.provision "shell", path: "public/bludit/setup.sh"
  config.vm.provision "shell", path: "public/drupal/setup.sh"
  config.vm.provision "shell", path: "public/joomla/setup.sh"
  config.vm.provision "shell", path: "public/magento/setup.sh"
  config.vm.provision "shell", path: "public/mediawiki/setup.sh"
  config.vm.provision "shell", path: "public/opencart/setup.sh"
  config.vm.provision "shell", path: "public/moodle/setup.sh"
  config.vm.provision "shell", path: "public/processwire/setup.sh"
  config.vm.provision "shell", path: "public/wordpress/setup.sh"
  config.vm.provision "shell", path: "public/END.sh"
end
