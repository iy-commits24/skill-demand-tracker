data "aws_ecr_repository" "tracker" {
  name = "sdt/tracker"
}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_region" "current" {}

data "aws_default_tags" "current" {}
