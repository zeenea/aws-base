provider "aws" {
  region = "eu-west-1"
}

variable "instance_type" {
  type        = "string"
  default     = "t2.small"
  description = "EC2 instance type"
}

variable "ami_name" {
  type = "string"
}

variable "ami_owner" {
  type = "string"
}

variable "user" {
  type = "string"
}

module "instance" {
  source = "../../utils/tf_mods/mod_instance"

  instance_type = var.instance_type
  ami_name = var.ami_name
  ami_owner = var.ami_owner
  user = var.user
}


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
  value = module.instance.ssh_private_key
}

output "public_ip" {
  value = module.instance.public_ip
}

