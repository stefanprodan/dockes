#!/bin/bash
set -e

read -p "Enter cluster size: " cluster_size
read -p "Enter storage path: " storage
read -p "Enter node memory (mb): " memory

heap=$((memory/2))
image="es-t"
network="es-net"
cluster="cluster-t"

# build image
if [ ! "$(docker images -q  $image)" ];then
    docker build -t $image .
fi

# create bridge network
if [ ! "$(docker network ls --filter name=$network -q)" ];then
    docker network create $network
fi

# concat all nodes addresses
hosts=""
for ((i=0; i<$cluster_size; i++)); do
    hosts+="$image$i"
	[ $i != $(($cluster_size-1)) ] && hosts+=","
done

# starting nodes
for ((i=0; i<$cluster_size; i++)); do
    echo "Starting node $i"

    docker run -d -p 920$i:9200 \
        --name "$image$i" \
        --network "$network" \
        -v "$storage":/usr/share/elasticsearch/data \
        -v "$PWD/config/elasticsearch.yml":/usr/share/elasticsearch/config/elasticsearch.yml \
        --cap-add=IPC_LOCK --ulimit nofile=65536:65536 --ulimit memlock=-1:-1 \
        --memory="${memory}m" --memory-swap="${memory}m" --memory-swappiness=0 \
		-e ES_HEAP_SIZE="${heap}m" \
        -e ES_JAVA_OPTS="-Dmapper.allow_dots_in_name=true" \
        --restart unless-stopped \
        $image \
        -Des.node.name="$image$i" \
        -Des.cluster.name="$cluster" \
        -Des.network.host=_eth0_ \
        -Des.discovery.zen.ping.multicast.enabled=false \
        -Des.discovery.zen.ping.unicast.hosts="$hosts" \
        -Des.cluster.routing.allocation.awareness.attributes=disk_type \
        -Des.node.rack=dc1-r1 \
        -Des.node.disk_type=spinning \
        -Des.node.data=true \
        -Des.bootstrap.mlockall=true \
        -Des.threadpool.bulk.queue_size=500 
done

echo "waiting 15s for cluster to form"
sleep 15

# find host IP
host="$(ifconfig eth0 | sed -En 's/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')"

# get cluster status
status="$(curl -fsSL "http://${host}:9200/_cat/health?h=status")"
echo "cluster health status is $status"
