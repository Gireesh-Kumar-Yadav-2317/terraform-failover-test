output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.security-groups.alb_security_group_id
}

output "ec2_security_group_id" {
  description = "EC2 security group ID"
  value       = module.security-groups.ec2_security_group_id
}

output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = module.iam.ec2_instance_profile_name
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.alb.alb_dns_name
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = module.alb.target_group_arn
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = module.autoscaling.autoscaling_group_name
}