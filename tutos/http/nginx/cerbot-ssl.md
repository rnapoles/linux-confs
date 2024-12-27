### Install
```sh
apt install certbot python3-certbot-nginx
```

### Edit
```sh
nano /etc/nginx/sites-available/example.com
```

```
...
server_name example.com www.example.com;
...
```

### Load conf
```sh
ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/example.com
```

### Check conf
```sh
nginx -t
```

### Reload nginx conf
```sh
systemctl reload nginx
```

### Get certs for example.com and www.example.com
```sh
certbot --nginx -d example.com -d www.example.com
```

### Check certbot services
```sh
systemctl status certbot.timer
systemctl list-timers
systemctl list-units | grep certbot
```

### Verifying Certbot Auto-Renewal
```sh
grep -c skipped /var/log/letsencrypt/letsencrypt.log
systemctl status certbot.timer
journalctl -u certbot-renewal.timer
```

### To test the renewal process, you can do a dry run with certbot:
```sh
certbot renew --dry-run
```
