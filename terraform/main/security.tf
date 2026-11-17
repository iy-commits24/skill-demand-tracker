resource "aws_security_group" "alb" {
  name        = "sdt-sg-alb"
  description = "Allows HTTP traffic from the internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sdt-sg-alb"
  }
}

resource "aws_security_group" "ec2" {
  name        = "sdt-sg-ec2"
  description = "Allows HTTP traffic from ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Custom TCP - FastAPI"
    from_port       = local.fastapi_port
    to_port         = local.fastapi_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sdt-sg-ec2"
  }
}
