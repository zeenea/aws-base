locals {
  molecule_tf_label = "molecule-${terraform.workspace}"
}

data "aws_ami" "from_vars" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.ami_name]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = [var.ami_owner]
}

resource "tls_private_key" "temporary" {
  algorithm = "RSA"
}

resource "aws_key_pair" "temporary" {
  key_name   = local.molecule_tf_label
  public_key = tls_private_key.temporary.public_key_openssh
}

data "aws_vpc" "main" {
  cidr_block = "10.244.0.0/16"
}

data "aws_subnet" "main" {
  vpc_id     = data.aws_vpc.main.id
  cidr_block = "10.244.1.0/24"
}

resource "aws_security_group" "molecule" {
  name_prefix = local.molecule_tf_label
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_security_group_rule" "allow_ssh_in" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.molecule.id
}

resource "aws_security_group_rule" "allow_all_out" {
  type = "egress"

  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.molecule.id
}

resource "aws_instance" "molecule" {

  associate_public_ip_address = true
  ami                         = data.aws_ami.from_vars.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.main.id
  key_name                    = local.molecule_tf_label
  iam_instance_profile = aws_iam_instance_profile.instance.name

  vpc_security_group_ids = [
    "${aws_security_group.molecule.id}"
  ]

  tags = {
    Name = local.molecule_tf_label
  }
}

data "aws_iam_policy_document" "ec2_assumable_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name_prefix = local.molecule_tf_label

  assume_role_policy = "${data.aws_iam_policy_document.ec2_assumable_role_policy.json}"
}

resource "aws_iam_instance_profile" "instance" {
  name = "${aws_iam_role.instance.name}"

  role = "${aws_iam_role.instance.name}"
}