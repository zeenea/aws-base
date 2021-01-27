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
