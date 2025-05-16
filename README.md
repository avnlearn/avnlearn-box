# AvN Learn Vagrant Box

## Test and Custom Vagrant Box

### Step 1: Build the Vagrant Box

1. **Start the Vagrant environment**:

   ```bash
   vagrant up
   ```

2. **SSH into the Vagrant box**:

   ```bash
   vagrant ssh
   ```

3. **Make any additional changes**

   ```bash
   # public/provision.sh
   export WP_DATABASE_NAME="wordpress"
   export WP_DATABASE_USER="wpuser"
   export WP_DATABASE_PASSWORD="password"
   export WEB_HOSTNAME="localhost"
   export WORDPRESS_USER="admin"
   export WORDPRESS_PASSWORD="admin@123"
   ```

4. **Exit the SSH session**:

   ```bash
   exit
   ```

### Step 2: Production Vagrant Box

```bash
vagrant package --output avnlearn-box.box
```

### Step 3: Destory

```bash
vagrant destroy
```

## Use of Vagrant Box

### Step 1: Add the Custom Box to Vagrant

You can now add your custom box to Vagrant:

```bash
vagrant box add avnlearn-box avnlearn-box.box
```

### Step 2: Use the Custom Box

You can create a new Vagrant project using your custom box:

1. **Create a new directory for the new project**:

   ```bash
   mkdir my-new-project
   cd my-new-project
   ```

2. **Initialize a new Vagrantfile**:

   ```bash
   vagrant init avnlearn-box
   ```

   **Output File** : `Vagrantfile`

   ```ruby
   # -*- mode: ruby -*-
   # vi: set ft=ruby :

   # All Vagrant configuration is done below. The "2" in Vagrant.configure
   # configures the configuration version (we support older styles for
   # backwards compatibility). Please don't change it unless you know what
   # you're doing.
   Vagrant.configure("2") do |config|
   # The most common configuration options are documented and commented below.
   # For a complete reference, please see the online documentation at
   # https://docs.vagrantup.com.

   # Every Vagrant development environment requires a box. You can search for
   # boxes at https://vagrantcloud.com/search.
   config.vm.box = "avnlearn-box"

   # Disable automatic box update checking. If you disable this, then
   # boxes will only be checked for updates when the user runs
   # `vagrant box outdated`. This is not recommended.
   # config.vm.box_check_update = false

   # Create a forwarded port mapping which allows access to a specific port
   # within the machine from a port on the host machine. In the example below,
   # accessing "localhost:8080" will access port 80 on the guest machine.
   # NOTE: This will enable public access to the opened port
   # config.vm.network "forwarded_port", guest: 80, host: 8080

   # Create a forwarded port mapping which allows access to a specific port
   # within the machine from a port on the host machine and only allow access
   # via 127.0.0.1 to disable public access
   # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

   # Create a private network, which allows host-only access to the machine
   # using a specific IP.
   # config.vm.network "private_network", ip: "192.168.33.10"

   # Create a public network, which generally matched to bridged network.
   # Bridged networks make the machine appear as another physical device on
   # your network.
   # config.vm.network "public_network"

   # Share an additional folder to the guest VM. The first argument is
   # the path on the host to the actual folder. The second argument is
   # the path on the guest to mount the folder. And the optional third
   # argument is a set of non-required options.
   # config.vm.synced_folder "../data", "/vagrant_data"

   # Disable the default share of the current code directory. Doing this
   # provides improved isolation between the vagrant box and your host
   # by making sure your Vagrantfile isn't accessible to the vagrant box.
   # If you use this you may want to enable additional shared subfolders as
   # shown above.
   # config.vm.synced_folder ".", "/vagrant", disabled: true

   # Provider-specific configuration so you can fine-tune various
   # backing providers for Vagrant. These expose provider-specific options.
   # Example for VirtualBox:
   #
   # config.vm.provider "virtualbox" do |vb|
   #   # Display the VirtualBox GUI when booting the machine
   #   vb.gui = true
   #
   #   # Customize the amount of memory on the VM:
   #   vb.memory = "1024"
   # end
   #
   # View the documentation for the provider you are using for more
   # information on available options.

   # Enable provisioning with a shell script. Additional provisioners such as
   # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
   # documentation for more information about their specific syntax and use.
   # config.vm.provision "shell", inline: <<-SHELL
   #   apt-get update
   #   apt-get install -y apache2
   # SHELL
   end
   ```

3. **Start the new Vagrant environment**:
   ```bash
   vagrant up
   ```

## Update `/etc/hosts`

Certainly! Continuing from where we left off, you will need to add entries to your local `/etc/hosts` file to resolve the custom domains to the Vagrant box's IP address. Here’s how to do that:

### Update `/etc/hosts`

1. Open your terminal on your host machine.
2. Edit the `/etc/hosts` file using a text editor with superuser privileges. For example:
   ```bash
   sudo nano /etc/hosts
   ```
3. Add the following lines to the file, replacing `192.168.56.10` with the actual IP address of your Vagrant box (if different):

   ```bash
   # 127.0.0.1 bludit.local
   192.168.56.10 bludit.local
   192.168.56.10 drupal.local
   192.168.56.10 joomla.local
   192.168.56.10 magento.local
   192.168.56.10 moodle.local
   192.168.56.10 processwire.local
   192.168.56.10 wordpress.local
   192.168.56.10 mediawiki.local
   192.168.56.10 laravel.local
   192.168.56.10 cakephp.local
   192.168.56.10 fuelphp.local
   192.168.56.10 symfony.local
   192.168.56.10 codeigniter.local
   192.168.56.10 php.local
   192.168.56.10 symfony.local
   ```

4. Save the file and exit the editor.

## Use Manjaro Linux

1. **Check Avahi Service**: The `.local` domain typically relies on the Avahi service (mDNS) for hostname resolution. Ensure that the Avahi daemon is running:
   ```bash
   systemctl status avahi-daemon
   ```
   If it's not running, you can start it with:
   ```bash
   sudo systemctl start avahi-daemon
   ```

2. **Install Avahi**: If Avahi is not installed, you can install it using:
   ```bash
   sudo pacman -S avahi
   ```

3. **Check Firewall Settings**: Ensure that your firewall is not blocking mDNS traffic. You may need to allow UDP traffic on port 5353:
   ```bash
   sudo ufw allow 5353/udp
   ```

4. **Check `/etc/nsswitch.conf`**: Ensure that the `hosts` line in your `/etc/nsswitch.conf` file includes `mdns`:
   ```plaintext
   hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4
   ```

5. **Test with `ping`**: Try pinging the hostname to see if it resolves:
   ```bash
   ping cakephp.local
   ```

6. **Check `/etc/hosts`**: If you want to manually resolve `cakephp.local`, you can add an entry to your `/etc/hosts` file:
   ```plaintext
   127.0.0.1 cakephp.local
   ```

7. **Restart Network Services**: Sometimes, simply restarting your network services can help:
   ```bash
   sudo systemctl restart NetworkManager
   ```

8. **Check for Conflicting Services**: Ensure that no other services are conflicting with Avahi, such as other mDNS services.

After trying these steps, check if `cakephp.local` resolves correctly. If you continue to have issues, please provide more details about your setup and any error messages you encounter.
