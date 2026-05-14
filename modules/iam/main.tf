data "aws_iam_policy_document" "assume_role" {
    statement {
        sid = "AllowEC2AssumeRole"
        effect = "Allow" 
        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]

    }
}


resource "aws_iam_role" "ec2_assume_role" {
    name = "${local.name_prefix}-ec2-assume-role"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json

    tags = merge(
        local.common_tags,
        {
            "Name" = "${local.name_prefix}-ec2-assume-role"
        }
    )
}


resource "aws_iam_role_policy_attachment" "ssm" {
    role = aws_iam_role.ec2_assume_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${local.name_prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2_assume_role.name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2-instance-profile"
  })
}
