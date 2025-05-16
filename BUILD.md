### Step 1: Set Up Your Base Environment

1. **Install Vagrant**: Make sure you have Vagrant installed on your machine. You can download it from [Vagrant's official website](https://www.vagrantup.com/downloads).

2. **Install VirtualBox**: Vagrant typically uses VirtualBox as the default provider. Download and install it from [VirtualBox's official website](https://www.virtualbox.org/).

### Step 2: Creates and configure

Creates and configures guest machines

```bash
make up
```

> ## Alternative
>
> ```bash
> vagrant up
> ```

### Step 3: Packages

This packages a currently running VirtualBox or Hyper-V environment into a re-usable box

```bash
make package
```

> ## Alternative
>
> ```bash
> vagrant package --output "avnlearn-box.box"
> ```

### Step 4: Add

```bash
make add
```

> ## Alternative
>
> ```bash
> vagrant box add "avnlearn/avnlearn-box" "avnlearn-box.box"
> ```

### Step 5: Clean

```bash
make clean
```

> ## Alternative
>
> ```bash
> vagrant destroy -f
> ```

## Notes

> Custom Username, Password and other... is edit `public/bootstrap.sh`
