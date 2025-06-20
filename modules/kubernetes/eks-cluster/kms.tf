resource "aws_kms_key" "eks" {
  description             = "Used by EKS for encryption at rest, e.g. EBS and EFS volumes"
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"

  # Prevent destruction of key
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "eks" {
  name          = "alias/eks"
  target_key_id = aws_kms_key.eks.key_id
}

resource "aws_kms_key_policy" "autoscaling_key_policy" {
  key_id = aws_kms_key.eks.id
  policy = jsonencode({
    Statement = [
      {
        "Sid" : "AllowRootUserAccess",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow service-linked role use of the customer managed key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:CreateGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : true
          }
        }
      }
    ]
    Version = "2012-10-17"
  })
}