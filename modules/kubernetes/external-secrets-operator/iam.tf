resource "aws_iam_role" "external_secrets_role" {
  name = "eks-${var.application_name}-external-secrets-operator"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = local.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${local.oidc_provider_host}:sub" = "system:serviceaccount:${var.external_secrets_operator_namespace}:${var.external_secrets_service_account}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "external_secrets_policy" {
  name = "eks-${var.application_name}-external-secrets-operator-policy"
  role = aws_iam_role.external_secrets_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowParameterStoreGetActions",
            "Action": [
                "ssm:GetParameters",
                "ssm:GetParameter",
                "ssm:GetParametersByPath"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:ssm:eu-west-2:${var.aws_account}:parameter/*"
        },
        {
            "Sid": "AllowAccessToKMSDefaultKey",
            "Action": [
                "kms:Decrypt"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:kms:eu-west-2:${var.aws_account}:key/${data.aws_kms_key.default_ssm_key.id}"
        }
    ]
}
EOF

  lifecycle {
    ignore_changes = [policy]
  }
}
