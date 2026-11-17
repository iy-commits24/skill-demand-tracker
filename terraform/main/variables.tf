variable "image_tag" {
  description = "Image tag to deploy. Deployment pipeline can pass a git SHA"
  type        = string
  default     = "latest"
}
