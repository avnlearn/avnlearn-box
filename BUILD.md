Creating a custom Vagrant box allows you to package a specific environment that can be easily shared and reused. Here’s a step-by-step guide on how to create a custom Vagrant box, along with a useful example.

### Step 1: Set Up Your Base Environment

1. **Install Vagrant**: Make sure you have Vagrant installed on your machine. You can download it from [Vagrant's official website](https://www.vagrantup.com/downloads).

2. **Install VirtualBox**: Vagrant typically uses VirtualBox as the default provider. Download and install it from [VirtualBox's official website](https://www.virtualbox.org/).

### Step 2: Create a New Vagrant Project

1. **Create a new directory** for your Vagrant project:

   ```bash
   mkdir avnlearn-box
   cd my-custom-box
   ```

2. **Initialize a new Vagrantfile**:
   ```bash
   vagrant init
   ```

### Step 3: Configure the Vagrantfile

Edit the `Vagrantfile` to specify the base box and any configurations you want. Here’s an example configuration:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64" # Base box
  config.vm.network "forwarded_port", guest: 80, host: 8080 # Forward port 80 to 8080
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y nginx
  SHELL
end
```

### Step 4: Build the Vagrant Box

1. **Start the Vagrant environment**:

   ```bash
   vagrant up
   ```

2. **SSH into the Vagrant box**:

   ```bash
   vagrant ssh
   ```

3. **Make any additional changes** you want in the box (e.g., install software, configure settings).

### Step 5: Package the Custom Box

Once you have your environment set up, you can package it into a custom box:

1. **Exit the SSH session**:

   ```bash
   exit
   ```

2. **Package the box**:
   ```bash
   vagrant package --output my-custom-box.box
   ```

### Step 6: Add the Custom Box to Vagrant

You can now add your custom box to Vagrant:

```bash
vagrant box add my-custom-box my-custom-box.box
```

### Step 7: Use the Custom Box

You can create a new Vagrant project using your custom box:

1. **Create a new directory for the new project**:

   ```bash
   mkdir my-new-project
   cd my-new-project
   ```

2. **Initialize a new Vagrantfile**:

   ```bash
   vagrant init my-custom-box
   ```

3. **Start the new Vagrant environment**:
   ```bash
   vagrant up
   ```

### Useful Example: Web Development Environment

The example above sets up a basic web server using Nginx. This custom box can be reused for web development projects, allowing developers to quickly spin up a consistent environment without having to configure everything from scratch each time.

### Conclusion

Creating a custom Vagrant box is a powerful way to streamline your development workflow. By packaging your environment, you can ensure consistency across different projects and share your setup with team members easily.

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
   192.168.56.10 cakephp.local
   192.168.56.10 codeigniter.local
   192.168.56.10 php.local
   192.168.56.10 symfony.local
   ```


4. Save the file and exit the editor.

## Apache2 Conf

```conf
<VirtualHost *:80>
        ServerName mediawiki.local
        Redirect permanent / https://mediawiki.local/
    </VirtualHost>

   <VirtualHost *:443>
      ServerName mediawiki.local
      DocumentRoot /var/www/mediawiki
      SSLEngine on
      SSLCertificateFile /etc/ssl/certs/selfsigned.crt
      SSLCertificateKeyFile /etc/ssl/private/selfsigned.key
      <Directory /var/www/mediawiki>
         AllowOverride All
         Require all granted
      </Directory>
   </VirtualHost>
```
