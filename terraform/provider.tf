provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "production-observability-platform"
      Environment = "portfolio"
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
