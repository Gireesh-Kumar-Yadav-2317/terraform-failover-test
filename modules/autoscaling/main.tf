
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  user_data = <<-EOF
#!/bin/bash
set -ex

dnf update -y
dnf install -y httpd

systemctl enable httpd
systemctl start httpd

echo "OK - $(hostname)" > /var/www/html/index.html
EOF
}

resource "aws_launch_template" "web_server" {
  name_prefix   = "${local.name_prefix}-web-server-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  vpc_security_group_ids = [
    var.ec2_security_group_id
  ]

  user_data = base64encode(local.user_data)

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name = "${local.name_prefix}-web-server"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_tags,
      {
        Name = "${local.name_prefix}-web-server-volume"
      }
    )
  }

  update_default_version = true
}

resource "aws_autoscaling_group" "web_server_asg" {
  name = "${local.name_prefix}-web-server-asg"

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = var.private_subnet_ids

  health_check_type         = "ELB"
  health_check_grace_period = 300

  target_group_arns = [
    var.target_group_arn
  ]

  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }

  metrics_granularity = "1Minute"

  lifecycle {
    create_before_destroy = true
  }


  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-app"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = local.common_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 120
    }
  }
}