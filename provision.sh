
terraform apply --auto-approve

terraform output | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' > ansible/inventory
cd ansible 
ansible-playbook  playbook.yml