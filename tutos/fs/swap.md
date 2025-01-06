## Creating a Swap File

### Step 1: Checking Current Swap Usage

```sh
swapon --show
free -h
```

### Step 2: Creating the Swap File

```sh
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

or

```sh
dd if=/dev/zero of=/swapfile bs=1G count=2
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```


### Step 3: Making the Swap File Permanent

```sh
cp /etc/fstab /etc/fstab.bak
```

Edit /etc/fstab:

```sh
/swapfile none swap sw 0 0
```

### Step 4: Monitoring Swap Usage

```sh
swapon --show
free -h
```

### Disable

```sh
swapoff -v /swapfile
```

### Swappiness

The swappiness parameter dictates how aggressively your system utilizes swap space.
A lower value causes the kernel to avoid swapping, while a higher value does the opposite.

Temporarily set swappiness to 10, you might prefer 10 for high RAM systems.

```sh
sysctl vm.swappiness=10
```

Permanently change swappiness

```sh
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
```
### References

- [How to add a swap file on Debian 12](https://osnote.com/how-to-add-a-swap-file-on-debian-12/ "How to add a swap file on Debian 12").
