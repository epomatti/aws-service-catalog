terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  project_name = "awsome-product"
}

module "bucket" {
  source       = "./modules/s3"
  product_name = local.project_name
}

module "iam" {
  source = "./modules/iam"
}

module "service_catalog" {
  source             = "./modules/servicecatalog"
  bucket_domain_name = module.bucket.bucket_domain_name
  launch_role_arn    = module.iam.launch_role_arn
  iam_user1_arn      = module.iam.iam_user1_arn
}

# This will be informed when launching the product
resource "aws_key_pair" "deployer" {
  key_name   = "ServiceCatalogLinuxDesktopKeyPair"
  public_key = file("${path.module}/tmp_key.pub")
}
