#cloud-config
host: #HOST
fqdn: #HOST
write_files:
- path: "/tmp/mount_volume.sh"
  permissions: "0544"
  owner: "root"
  content: |
    #!/bin/sh
    set -e
    while [ ! -b /dev/vdb1 ] ;
    do
      sleep 2
      echo "---WAITING FOR CINDER VOLUME---"
    done
    mount /dev/vdb1 /mnt/qserv
    chown -R 1000:1000 /mnt/qserv
- path: "/etc/docker/daemon.json"
  permissions: "0544"
  owner: "root"
  content: |
    {
      "storage-driver": "overlay2",
      "storage-opts": [
        "overlay2.override_kernel_check=true"
      ],
      "insecure-registries": ["${registry_host}"],
      "registry-mirrors": ["http://${registry_host}:${registry_port}"]
    }
- path: "/etc/sysctl.d/90-kubernetes.conf"
  permissions: "0544"
  owner: "root"
  content: |
    # Enable netfilter on bridges
    # Required for weave (k8s v1.9.1) to start
    net.bridge.bridge-nf-call-iptables = 1
- path: "/etc/systemd/system/docker.service.d/docker-opts.conf"
  permissions: "0544"
  owner: "root"
  content: |
    [Service]
    LimitMEMLOCK=${systemd_memlock}

packages:
# Install epel directory first to enable
# some packages installation (like byobu)
- epel-release

users:
- name: qserv
  gecos: Qserv daemon
  groups: docker
  lock-passwd: true
  shell: /bin/bash
  ssh-authorized-keys:
  - ${key}
  sudo: ALL=(ALL) NOPASSWD:ALL

runcmd:
  - 'su -c "mkdir /home/qserv/src && cd /home/qserv/src && git clone https://github.com/fjammes/dot-config.git" qserv'
  - '/home/qserv/src/dot-config/centos/prepare.sh'
  - 'su -c "/home/qserv/src/dot-config/configure.sh" qserv'
