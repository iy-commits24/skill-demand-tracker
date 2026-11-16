terraform {
  backend "s3" {
    # bucket argument is not set, the bucket is to be provided at init: terraform init -backend-config="bucket=<name>"
    key          = "main/terraform.tfstate"
    region       = "ap-southeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
