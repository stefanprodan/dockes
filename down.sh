#!/bin/bash

image="es-t"
cluster_size=3

# stop and remove containers
for ((i=0; i<=$cluster_size; i++)); do
    docker rm -f "$image$i"
done

# remove image
docker rmi -f "$image"
