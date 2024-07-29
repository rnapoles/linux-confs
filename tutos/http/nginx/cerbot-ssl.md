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

### Get certs for example.com and www.example.com
```sh
systemctl status certbot.timer
```

### Verifying Certbot Auto-Renewal
```sh
systemctl status certbot.timer
```

### To test the renewal process, you can do a dry run with certbot:
```sh
certbot renew --dry-run
```
