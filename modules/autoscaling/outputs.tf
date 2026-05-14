output "autoscaling_group_name" {
  value = aws_autoscaling_group.web_server_asg.name
}

output "launch_template_id" {
  value = aws_launch_template.web_server.id
}