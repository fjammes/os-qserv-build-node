set -e
set -x
terraform destroy -auto-approve
terraform apply -auto-approve
