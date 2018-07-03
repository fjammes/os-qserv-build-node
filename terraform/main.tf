/* This terraform configuration provision a Qserv cluster on OpenStack
**/

provider "openstack" {
  # OpenStack params are infered trough env vars by default, you must source <your-openstack-provider>-rc.sh file beforehand
}

### LOCAL VARS SECTION ###

# Local variables needed for configuration
locals {
  safe_username = "${replace(var.user_name, ".", "")}"
  ssh_key_name  = "${var.instance_prefix}${local.safe_username}-terraform-build"
}

### DATA SECTION ###

# Flavor of the cluster nodes
data "openstack_compute_flavor_v2" "node_flavor" {
  name = "${var.flavor}"
}

# Image of the cluster nodes
data "openstack_images_image_v2" "node_image" {
  name = "${var.snapshot}"
}

# Network of the cluster
data "openstack_networking_network_v2" "network" {
  name = "${var.network}"
}

# Cloud-Init config file filled with cluster parameters
data "template_file" "cloud_init" {
  template = "${file("cloud_config.tpl")}"

  vars {
    systemd_memlock = "${var.limit_memlock}"
    key             = "${file("${var.ssh_private_key}.pub")}"
    registry_host   = "${var.docker_registry_host}"
    registry_port   = "${var.docker_registry_port}"
  }
}

### RESOURCE SECTION ###

# Creates a keypair from the local provided keypair
resource "openstack_compute_keypair_v2" "keypair" {
  name       = "${local.ssh_key_name}"
  public_key = "${file("${var.ssh_private_key}.pub")}"
}

# Allocate a floating ip
resource "openstack_networking_floatingip_v2" "floating_ip" {
  pool = "${var.ip_pool}"
}

# Creates the build node
resource "openstack_compute_instance_v2" "buildnode" {
  name            = "${var.instance_prefix}buildnode"
  image_id        = "${data.openstack_images_image_v2.node_image.id}"
  flavor_id       = "${data.openstack_compute_flavor_v2.node_flavor.id}"
  key_pair        = "${openstack_compute_keypair_v2.keypair.name}"
  security_groups = "${var.security_groups}"
  user_data       = "${replace(data.template_file.cloud_init.rendered, "#HOST", "${var.instance_prefix}buildnode")}"

  network {
    uuid = "${data.openstack_networking_network_v2.network.id}"
  }
}

# Associates the floating ip to the gateway server
resource "openstack_compute_floatingip_associate_v2" "floating_ip" {
  floating_ip = "${openstack_networking_floatingip_v2.floating_ip.address}"
  instance_id = "${openstack_compute_instance_v2.buildnode.id}"
}

