# # This terraform script creates the groups and then attaches policies to them.
# dev group
resource "aws_iam_group" "devops-administrator" {
  name = "DevOps-Admininstrator"

}


resource "aws_iam_group_membership" "devops-administrator" {
  name  = "add-user-to-devops-administrator"
  users = var.userdevops
  group = aws_iam_group.devops-administrator.name

}


# devops group
resource "aws_iam_group" "dev-administrator" {
  name = "Dev-Admininstrator"

}
resource "aws_iam_group_membership" "dev-administrator" {
  name  = "add-user-to-dev-administrator"
  users = var.usernamedev
  group = aws_iam_group.dev-administrator.name # can it be .self

}


# spare group
resource "aws_iam_group" "spare-access" {
  name = "spare-access"

}
resource "aws_iam_group_membership" "spare-access" {
  name  = "add-user-to-userspare-access"
  users = var.userspare
  group = aws_iam_group.spare-access.name

}