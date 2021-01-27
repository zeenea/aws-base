# ================================================================================
#   OUTPUT
# ================================================================================
output "name" {
  value = terraform.workspace
}
output "user" {
  value = var.user
}

output "port" {
  value = 22
}

output "ssh_private_key" {
  value = tls_private_key.temporary.private_key_pem
}

output "public_ip" {
  value = aws_instance.molecule.public_ip
}

output "instance_role_name" {
  value = aws_iam_role.instance.name
}