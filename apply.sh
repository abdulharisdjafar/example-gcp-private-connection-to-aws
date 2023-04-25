# create ha vpn in gcp
cd gcp-create-ha-vpn
terraform plan
terraform apply -auto-approve 

cd ../

# create vpn in aws
cd aws-create-vpn
terraform plan
terraform apply -auto-approve 

cd ../

# peering connection between vpn gcp and aws
cd gcp-modify-ha-vpn
terraform plan
terraform apply  -auto-approve 

