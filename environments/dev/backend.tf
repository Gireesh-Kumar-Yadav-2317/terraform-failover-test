terraform {
  backend "s3" {
    bucket         = "terraform-failover-test-state"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-failover-test-lock"
    encrypt        = true
  }
}