terraform -chdir=newVM apply -state=..\tfstate\terraform.tfstate -var-file="templateVM.tfvars"
