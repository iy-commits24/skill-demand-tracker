data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "sdt-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}


# PullOnly policy attached to the role to give the least privilege
resource "aws_iam_role_policy_attachment" "ecr_pull" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}


# SSM policy to avoid opening ports for SSH
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# Instance profile role wrapper to attach role to EC2
resource "aws_iam_instance_profile" "ec2" {
  name = "sdt-ec2-profile"
  role = aws_iam_role.ec2.name
}
