
cp terraform.example.tfvars terraform.tfvars

# create ~/.lsst/qserv-cluster/petasky/os-openrc.sh with password
export CLUSTER_CONFIG_DIR=~/.lsst/qserv-cluster/petasky

. ./terraform-setup.sh
terraform init
terraform apply

ssh -i ~/.ssh/id_rsa_openstack qserv@193.55.95.162
