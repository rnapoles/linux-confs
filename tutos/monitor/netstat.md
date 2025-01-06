# find all open ports

```sh
netstat -a	
```

# find ports that are listening

```sh
netstat -l --inet	
```

# find TCP|UDP (numeric) ports that are listening

```sh
netstat -ln --tcp	
```

```sh
netstat -ln --udp	
```

# 

```sh
netstat -putona
```

```txt
p PID/Program name
u Lists all UDP ports
t Lists all TCP ports
o Displays timers
n Don't resolve names
a Displays all active connections on the system
```