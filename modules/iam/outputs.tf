output "ec2_role_name" {
  description = "IAM role name for EC2"
  value       = aws_iam_role.ec2_assume_role.name
}

output "ec2_instance_profile_name" {
  description = "IAM instance profile name"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "ec2_instance_profile_arn" {
  description = "IAM instance profile ARN"
  value       = aws_iam_instance_profile.ec2_instance_profile.arn
}