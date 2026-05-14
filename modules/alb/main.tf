resource "aws_lb" "this" {
    name = "${local.name_prefix}-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [var.alb_security_group_id]

    subnets = var.public_subnet_ids

    enable_deletion_protection = false

    tags = merge(
        local.common_tags,
        {
            "Name" = "${local.name_prefix}-alb"
        }
    )
}