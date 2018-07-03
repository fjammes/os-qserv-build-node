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
  # Install EPEL packages
  - 'yum install -y byobu htop'
  # Disable SELinux
  - 'setenforce 0'
  - 'sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/sysconfig/selinux'
  - [sed, -i, 's|Environment="KUBELET_CGROUP_ARGS=|#Environment="KUBELET_CGROUP_ARGS=|', /etc/systemd/system/kubelet.service.d/10-kubeadm.conf]
  # Data and log are stored on Openstack host
  - [mkdir, -p, /qserv/custom]
  - [mkdir, /qserv/data]
  - [mkdir, /qserv/log]
  - [mkdir, /qserv/tmp]
  - [mkdir, /mnt/qserv]
  - [chown, -R, '1000:1000', /qserv]
  - [/bin/systemctl, daemon-reload]
  - [/bin/systemctl, restart,  docker]
  - [/bin/systemctl, restart,  systemd-sysctl]
  # Install vim8
  - 'curl -L https://copr.fedorainfracloud.org/coprs/mcepl/vim8/repo/epel-7/mcepl-vim8-epel-7.repo -o /etc/yum.repos.d/mcepl-vim8-epel-7.repo'
  - 'yum update -y vim-common vim-minimal && yum install -y vim'
  - 'su -c "cd /home/qserv && git clone https://github.com/lsst/qserv.git src/qserv" qserv'
  - 'su -c "cd /home/qserv/src && git clone https://github.com/fjammes/dot-config.git" qserv'
  - 'systemctl start docker'
  - 'su -c "docker pull qserv/qserv:dev" qserv'
# - 'su -c "/home/qserv/src/qserv/admin/tools/docker/3_build-git-image.sh -R tickets/DM-13979" qserv'
  - 'su -c "cd /home/qserv/src/dot-config && ./configure.sh" qserv'
