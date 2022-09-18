# admin dev access policy

resource "aws_iam_policy" "adminaccess" {
    name = "adminaccess"
    description = "This policy allow admininstrator access to users"
    policy = file("./iam/administratoraccesspolicy.json")
  
}
            
# read only access
resource "aws_iam_policy" "readonly" {
    name = "readonly"
    description = "This policy allow readonly access to users"
    policy = file("./iam/readonlyaccess.json")
  
}
