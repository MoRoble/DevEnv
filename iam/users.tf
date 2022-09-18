# Iam user accounts 

resource "aws_iam_user" "dev-accounts" {
    for_each = {for name in var.usernamedev: name => name}
  name = each.value
}

resource "aws_iam_user" "devops-accounts" {
    for_each = {for name in var.userdevops: name => name}
  name = each.value
}

resource "aws_iam_user" "spare-accounts" {
    for_each = {for name in var.userspare: name => name}
  name = each.value
}

