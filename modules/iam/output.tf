output "launch_role_arn" {
  value = aws_iam_role.launch.arn
}

output "iam_user1_arn" {
  value = aws_iam_user.user1.arn
}
