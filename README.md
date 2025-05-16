# AvN Learn Vagrant Box

## Step 1: initializes

Initializes a new Vagrant environment by creating a Vagrantfile

```bash
vagrant init "avnlearn/avnlearn-box"
```

# Hosts

Certainly! Continuing from where we left off, you will need to add entries to your local `/etc/hosts` file to resolve the custom domains to the Vagrant box's IP address. Here’s how to do that:

## Linux `/etc/hosts` update

1. Open your terminal on your host machine.
2. Edit the `/etc/hosts` file using a text editor with superuser privileges. For example:
   ```bash
   sudo nano /etc/hosts
   ```
3. Add the following lines to the file, replacing `192.168.56.10` with the actual IP address of your Vagrant box (if different):

   ```bash
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
