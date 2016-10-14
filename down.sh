#!/bin/bash

read -p "Enter cluster size: " cluster_size
image="es-t"

# stop and remove containers
for ((i=0; i<$cluster_size; i++)); do
    docker rm -f "$image$i"
done

# remove image
docker rmi -f "$image"
