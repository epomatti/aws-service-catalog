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

resource "aws_iam_policy" "launch" {
  name = "ServiceCatalogTerraformLaunchPolicy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "LaunchConstraintSC",
        "Effect" : "Allow",
        "Action" : [
          "cloudformation:SetStackPolicy",
          "cloudformation:DescribeStackEvents",
          "cloudformation:CreateStack",
          "cloudformation:DeleteStack",
          "cloudformation:UpdateStack",
          "cloudformation:ValidateTemplate",
          "cloudformation:GetTemplateSummary",
          "cloudformation:DescribeStacks",
          "servicecatalog:*",
          "ec2:*",
          "s3:GetObject",
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "launch" {
  role       = aws_iam_role.launch.name
  policy_arn = aws_iam_policy.launch.arn
}


resource "aws_iam_group" "group1" {
  name = "Group1"
  path = "/terraform/"
}

resource "aws_iam_group_policy_attachment" "group1" {
  group      = aws_iam_group.group1.name
  policy_arn = "arn:aws:iam::aws:policy/AWSServiceCatalogEndUserFullAccess"
}

resource "aws_iam_user" "user1" {
  name          = "User1"
  path          = "/terraform/"
  force_destroy = true
}

resource "aws_iam_user_login_profile" "user1" {
  user                    = aws_iam_user.user1.name
  password_reset_required = false
}

resource "aws_iam_user_group_membership" "user1" {
  user = aws_iam_user.user1.name

  groups = [
    aws_iam_group.group1.name
  ]
}
