variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging resources"
  type        = string
}
variable "environment" {
  description = "Environment name for tagging resources"
  type        = string
}
variable "owner" {
  description = "Owner name for tagging resources"
  type        = string
}
variable "state_bucket_name" {
  description = "Unique S3 bucket name for Terraform state"
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
}