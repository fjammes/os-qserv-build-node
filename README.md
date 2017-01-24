# Launch a Qserv build node on Openstack

```bash
# Command below displays build node public ip address in its output 
openstack stack create --template main.yaml -e env-galactica-drm.yaml qserv-build-node
```

# Test docker registry mirror

```bash
curl http://<registry-mirror-ip>:5000/v2/_catalog
```
