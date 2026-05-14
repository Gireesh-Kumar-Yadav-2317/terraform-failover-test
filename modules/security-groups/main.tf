resource "aws_security_group"  "alb" {
    name = "${local.name_prefix}-alb-sg"
    description = "Security group for ALB"
    vpc_id = var.vpc_id

    tags = merge(local.common_tags, {
        Name = "${local.name_prefix}-alb-sg"

    })
}


resource "aws_vpc_security_group_ingress_rule" "alb_ingree"{
    security_group_id = aws_security_group.alb.id
    description = "Allow HTTP traffic from anywhere"
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
} 


resource "aws_vpc_security_group_egress_rule" "alb_egress" {
    security_group_id = aws_security_group.alb.id
    description = "Allow all outbound traffic"
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"

}

resource "aws_security_group" "ec2" {
    name = "${local.name_prefix}-ec2-sg"
    description = "Security group for EC2 instances" 

    vpc_id = var.vpc_id

    tags = merge (
        {
            Name = "${local.name_prefix}-ec2-sg"

        }
        ,
        local.common_tags
    )  
}



resource "aws_vpc_security_group_ingress_rule" "ec2_ingress" {
    security_group_id = aws_security_group.ec2.id
    description = "Allow HTTP traffic from ALB security group"
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_egress_rule" "ec2_all" {
    security_group_id = aws_security_group.ec2.id
    description = "Allow all outbound traffic"
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"

}

resource "aws_vpc_security_group_ingress_rule" "ec2_ssh" {
  for_each = toset(var.allowed_ssh_cidr_blocks)

  security_group_id = aws_security_group.ec2.id

  description = "Allow SSH"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = each.value
}

resource "aws_vpc_security_group_ingress_rule" "ec2_http_from_alb" {
  security_group_id            = aws_security_group.ec2.id
  referenced_security_group_id = aws_security_group.alb.id

  description = "Allow HTTP from ALB"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}