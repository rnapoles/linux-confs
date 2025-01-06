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

