locals {
  templates_dir = "${path.module}/../../templates/"
}

resource "aws_servicecatalog_portfolio" "portfolio" {
  name          = "My App Portfolio w/ Terraform"
  description   = "List of my organizations apps created with Terraform"
  provider_name = "Pomatti"
}

resource "aws_servicecatalog_product" "main" {
  name        = "Linux Desktop"
  owner       = "Evandro Pomatti"
  distributor = "Pomatti"
  description = "This will create a Linux Desktop"

  type = "CLOUD_FORMATION_TEMPLATE"

  provisioning_artifact_parameters {
    name         = "v1"
    type         = "CLOUD_FORMATION_TEMPLATE"
    template_url = "https://${var.bucket_domain_name}/cfn-template.json"
  }
}

resource "aws_servicecatalog_product_portfolio_association" "myproduct" {
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  product_id   = aws_servicecatalog_product.main.id
}

resource "aws_servicecatalog_constraint" "default" {
  description  = "Small instance sizes"
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  product_id   = aws_servicecatalog_product.main.id
  type         = "TEMPLATE"

  parameters = file("${local.templates_dir}/template-constraint.json")
}

resource "aws_servicecatalog_constraint" "launch" {
  description  = "Launch constraints"
  portfolio_id = aws_servicecatalog_portfolio.portfolio.id
  product_id   = aws_servicecatalog_product.main.id
  type         = "LAUNCH"

  parameters = jsonencode({
    "RoleArn" : "${var.launch_role_arn}"
  })
}

resource "aws_servicecatalog_principal_portfolio_association" "user1" {
  portfolio_id  = aws_servicecatalog_portfolio.portfolio.id
  principal_arn = var.iam_user1_arn
}
