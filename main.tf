provider "aws" {
  region = local.region
}

### Locals ###

data "aws_caller_identity" "current" {}

locals {
  account_id   = data.aws_caller_identity.current.account_id
  region       = "sa-east-1"
  project_name = "awsome-product"
}

### S3 ###

resource "aws_s3_bucket" "main" {
  bucket = "${local.project_name}-${local.region}-epomatti"
}

resource "aws_s3_object" "template" {
  bucket = aws_s3_bucket.main.id
  key    = "cfn-template.json"
  source = "./cfn-template.json"
  etag   = filemd5("./cfn-template.json")
}

### Product ###

resource "aws_servicecatalog_portfolio" "portfolio" {
  name          = "My App Portfolio w/ Terraform"
  description   = "List of my organizations apps created with Terraform"
  provider_name = "Pomatti"
}

resource "aws_servicecatalog_product" "main" {
  name        = "MyProduct"
  owner       = "Evandro Pomatti"
  distributor = "Pomatti"
  description = "This will create an awsome product."

  type = "CLOUD_FORMATION_TEMPLATE"

  provisioning_artifact_parameters {
    name         = "v1"
    type         = "CLOUD_FORMATION_TEMPLATE"
    template_url = "https://${aws_s3_bucket.main.bucket_domain_name}/${aws_s3_object.template.key}"
  }
}

resource "aws_servicecatalog_product_portfolio_association" "myproduct" {
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  product_id   = aws_servicecatalog_product.main.id
}

### Constraints ###

# Template
resource "aws_servicecatalog_constraint" "default" {
  description  = "Small instance sizes"
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  product_id   = aws_servicecatalog_product.main.id
  type         = "TEMPLATE"

  parameters = file("${path.module}/template-constraint.json")
}

# Launch
resource "aws_iam_policy" "launch" {
  name   = "ServiceCatalogTerraformLaunchPolicy"
  policy = file("${path.module}/launch-constraint.json")
}

resource "aws_iam_role" "launch" {
  name = "test_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "servicecatalog.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "launch" {
  role       = aws_iam_role.launch.name
  policy_arn = aws_iam_policy.launch.arn
}

resource "aws_servicecatalog_constraint" "launch" {
  description  = "Launch constraints"
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  product_id   = aws_servicecatalog_product.main.id
  type         = "LAUNCH"

  parameters = jsonencode({
    "RoleArn" : aws_iam_role.launch.arn
  })
}

### Output ###

output "bucket" {
  value = aws_s3_bucket.main.bucket_domain_name
}
