#!/bin/bash

NEW_USER=developer

sed -i "s/.*RSAAuthentication.*/RSAAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i "s/.*AuthorizedKeysFile.*/AuthorizedKeysFile\t\.ssh\/authorized_keys/g" /etc/ssh/sshd_config
sed -i "s/.*PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
echo "${NEW_USER}      ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
service sshd restart

useradd -p "" $NEW_USER
passwd -fu $NEW_USER
sudo -u $NEW_USER mkdir /home/$NEW_USER/.ssh
sudo -u $NEW_USER chmod 700 /home/$NEW_USER/.ssh
sudo -u $NEW_USER ssh-keygen -t rsa -b 2048 -N "" -f /home/$NEW_USER/.ssh/id_rsa
cat /home/$NEW_USER/.ssh/id_rsa.pub > /home/$NEW_USER/.ssh/authorized_keys
chmod 600 /home/$NEW_USER/.ssh/authorized_keys
chown $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh/authorized_keys