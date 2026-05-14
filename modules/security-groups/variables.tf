variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to EC2"
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}