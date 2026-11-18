resource "aws_launch_template" "ec2" {
  name          = "sdt-ec2-template"
  description   = "tracker container"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.ec2.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh.tftpl", {
    region    = data.aws_region.current.region
    registry  = split("/", data.aws_ecr_repository.tracker.repository_url)[0]
    host_port = local.fastapi_port
    image     = data.aws_ecr_repository.tracker.name
    tag       = var.image_tag
  }))

  # Enable EC2 instance to get temporary credentials to pull from ECR using IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(data.aws_default_tags.current.tags, { Name = "sdt-ec2" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(data.aws_default_tags.current.tags, { Name = "sdt-ec2-volume" })
  }
}

resource "aws_autoscaling_group" "ec2" {
  name                      = "sdt-ec2-asg"
  max_size                  = 6
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  target_group_arns         = [aws_lb_target_group.ec2.arn]

  launch_template {
    id      = aws_launch_template.ec2.id
    version = aws_launch_template.ec2.latest_version
  }
}
