variable "flavor" {
  description = "Flavor of the cluster nodes"
}

variable "snapshot" {
  description = "Name of the image to use in nodes"
}

variable "network" {
  description = "OpenStack network name"
}

variable "instance_prefix" {
  description = "The prefix to append to your node's name"
}

variable "security_groups" {
  description = "List of security groups to add to nodes"
  type        = "list"
  default     = ["default"]
}

variable "ssh_private_key" {
  description = "The private key used to ssh on nodes"
  default     = "~/.ssh/id_rsa"
}

variable "base_image" {
  description = "Base image for the snapshot instance"
  default     = "CentOS 7 latest"
}

variable "snapshot_flavor" {
  description = "Flavor of the snapshot instance"
  default     = "m1.medium"
}

variable "ip_pool" {
  description = "Name of the floating ip pool"
  default     = "public"
}

variable "user_name" {
  description = "OpenStack username, please source terraform-setup.sh to set it automaticaly"
}

variable "docker_registry_host" {
  description = "Docker registry server IP"
  default     = ""
}

variable "docker_registry_port" {
  description = "Docker registry server port"
  default     = 5000
}

variable "limit_memlock" {
  description = "Amout of memory which can be locked in containers (in Bytes)"
  default     = "infinity"
}
