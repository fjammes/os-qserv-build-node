# Launch a Qserv build node on Openstack

```bash
# Command below displays build node public ip address in its output 
openstack stack create --template main.yaml -e LSST_conf.yaml qserv-build-node

# Show stack
openstack stack show qserv-build-node

# ssh (using correct key)
ssh centos@141.142.211.178

# Delete stack
openstack stack delete qserv-build-node
```
