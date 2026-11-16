resource "aws_ecr_repository" "tracker" {
  name                 = "sdt/tracker"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  lifecycle {
    prevent_destroy = true
  }
}
