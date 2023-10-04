locals {
  cfn_template_dir  = "${path.module}/../../templates/"
  cfn_template_key  = "cfn-template.json"
  cfn_template_path = "${local.cfn_template_dir}/${local.cfn_template_key}"
}

resource "random_string" "random" {
  length  = 10
  special = false
  lower   = true
  upper   = false
}

resource "aws_s3_bucket" "default" {
  bucket = "bucket-${var.product_name}-${random_string.random.result}"
}

resource "aws_s3_object" "default" {
  bucket = aws_s3_bucket.default.id
  key    = local.cfn_template_key
  source = local.cfn_template_path
  etag   = filemd5(local.cfn_template_path)
}
