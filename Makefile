molecule_create_network:
	bash -c "cd molecule/utils/tf_mods/mod_network && terraform init -input=false && terraform apply -auto-approve"

molecule_destroy_network:
	bash -c "cd molecule/utils/tf_mods/mod_network && terraform destroy -force"
