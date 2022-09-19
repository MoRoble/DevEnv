# attach policy to the dev group
resource "aws_iam_group_policy_attachment" "attach-policy" {
  group      = aws_iam_group.dev-administrator.name
  policy_arn = aws_iam_policy.adminaccess.arn

}

resource "aws_iam_group_policy_attachment" "attach-policy1" {
  group      = aws_iam_group.spare-access.name
  policy_arn = aws_iam_policy.readonly.arn

}

resource "aws_iam_group_policy_attachment" "attach-policy2" {
  group      = aws_iam_group.devops-administrator.name
  policy_arn = aws_iam_policy.adminaccess.arn

}
