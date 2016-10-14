# dockes

Provisioning and running a multi-node Elasticsearch cluster on a single Docker host.

# Install

Clone this repository on your Docker host, cd into dockes directory and run sh.up:

```bash
$ bash sh.up
Enter cluster size: 3
Enter storage path: /storage
Enter node memory (mb): 1024
Successfully built b9f33d9910e1
Starting node 0
c0c7ac1e9b284b2f90ff0f2b621a8a0ea3a79096ddff88178544da1741a72c3a
Starting node 1
318bbda182684c624eee55b87b91a614843276f70ad43221873827485aef506a
Starting node 2
318bbda182684c624eee55b87b91a614843276f70ad43221873827485aef506a
waiting 30s for the cluster to start
cluster health status is green
```
