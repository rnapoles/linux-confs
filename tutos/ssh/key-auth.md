### Generate key

```sh
ssh-keygen -o -t rsa -b 4096
```

### Copy key

```sh
ssh-copy-id -i ~/.ssh/id_rsa.pub <REMOTE_USER>@<HOST>
```

or

```sh
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

### Disable password auth

Edit /etc/ssh/sshd_config


```sh
ChallengeResponseAuthentication no
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin prohibit-password
StrictModes yes
```

Restart ssh:

```sh
service ssh restart 
```