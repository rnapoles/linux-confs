### Installation

 * [Installation guides](https://rabbitmq.com/download.html) for various platforms
 * [Kubernetes Cluster Operator](https://rabbitmq.com/kubernetes/operator/operator-overview.html)

### Enable Web admin
```sh
rabbitmq-plugins enable rabbitmq_management
```

From your browser go to `http://{your-ip-address}:15672/`
The default username and password for RabbitMQ management
plugin is: `guest/guest`

### Change default user password
```sh
rabbitmqctl change_password guest P@55w0rd
```

or

```sh
rabbitmqadmin change_password guest P@55w0rd
```

### Add an admin user named "admin":

```sh
rabbitmqctl add_user admin P@55w0rd
```

### Set administrative privileges.

```sh
rabbitmqctl set_user_tags admin administrator
```

### Delete user
```sh
rabbitmqctl delete_user guest
```

### List available plugins
```sh
rabbitmq-plugins list
rabbitmq-plugins list management*
rabbitmq-plugins enable rabbitmq_mqtt
```

* `rabbitmq_top`: Adds UNIX top-like information on the Erlang VM to the management UI. .
* `rabbitmq_management`: This plugin provides a web-based management interface for RabbitMQ.
* `rabbitmq_stomp`: This plugin adds support for the STOMP protocol.
* `rabbitmq_tracing`: This plugin adds support for tracing messages through RabbitMQ.
* `rabbitmq_federation`: This plugin allows RabbitMQ to federate with other RabbitMQ servers.
* `rabbitmq_shovel`: This plugin allows RabbitMQ to replicate messages to other RabbitMQ servers.
* `rabbitmq_mqtt`: This plugin adds support for the MQTT protocol
* `rabbitmq_sharding`: Sharding makes it easy to scale messages among queues
* `sensu-plugins-rabbitmq`: This plugin provides native RabbitMQ instrumentation for monitoring and metrics collection, including: service health, message, consumer, and queue health/metrics via `rabbitmq_management`, and more.

### Cluster

```sh
rabbitmqctl join_cluster rabbit@NodeA
rabbitmqctl cluster_status
```

### Docker

```sh
docker pull rabbitmq:3-management
docker run -d –hostname my-rabbit –name some-rabbit rabbitmq:3-management
```

### Kubernetes

```sh
helm install stable/rabbitmq
kubectl create namespace rabbitmq
helm install rabbitmq stable/rabbitmq –namespace rabbitmq
```

### Tutorials and Documentation

 * [RabbitMQ tutorials](https://rabbitmq.com/getstarted.html)
 * [All documentation guides](https://rabbitmq.com/documentation.html)
 * [RabbitMQ blog](https://blog.rabbitmq.com/)

Some key doc guides include

 * [CLI tools guide](https://rabbitmq.com/cli.html) 
 * [Clustering](https://www.rabbitmq.com/clustering.html) and [Cluster Formation](https://www.rabbitmq.com/cluster-formation.html) guides
 * [Configuration guide](https://rabbitmq.com/configure.html) 
 * [Client libraries and tools](https://rabbitmq.com/devtools.html)
 * [Monitoring](https://rabbitmq.com/monitoring.html) and [Prometheus/Grafana](https://www.rabbitmq.com/prometheus.html) guides
 * [Kubernetes Cluster Operator](https://rabbitmq.com/kubernetes/operator/operator-overview.html)
 * [Production checklist](https://rabbitmq.com/production-checklist.html)
 * [Quorum queues](https://rabbitmq.com/quorum-queues.html): a replicated, data safety- and consistency-oriented queue type
 * [Streams](https://rabbitmq.com/streams.html): a persistent and replicated append-only log with non-destructive consumer semantics
 * [Runtime Parameters and Policies](https://rabbitmq.com/parameters.html)
 * [Runnable tutorials](https://github.com/rabbitmq/rabbitmq-tutorials/)