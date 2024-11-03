resource "aws_iam_group" "admin_group" {
  name="eks_admin"
}
resource "aws_iam_group" "dev_group" {
  name="eks_dev"
}
resource "aws_iam_role" "admin_role" {
  name = "eks_admin_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
    }]
  })

  tags = {
    "Role" = "admin"
  }
}

resource "aws_iam_role" "dev_role" {
  name = "eks_dev_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
    }]
  })

  tags = {
    "Role" = "dev"
  }
}
resource "aws_iam_policy" "admin_policy" {
  name = "admin_policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": aws_iam_role.admin_role.arn,
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Role": "admin"
        }
      }
    }]
  })
}
resource "aws_iam_policy" "dev_policy" {
  name = "dev_policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": aws_iam_role.dev_role.arn,
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Role": "dev"
        }
      }
    }]
  })
}


resource "aws_iam_group_policy_attachment" "admin_group_policy_attachment" {
  group      = aws_iam_group.admin_group.name
  policy_arn = aws_iam_policy.admin_policy.arn
}

resource "aws_iam_group_policy_attachment" "dev_group_policy_attachment" {
  group      = aws_iam_group.dev_group.name
  policy_arn = aws_iam_policy.dev_policy.arn
}
data "aws_caller_identity" "current" {}


resource "aws_iam_role" "service_account_role" {
  name = "${var.cluster_name}-dev-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "${var.oidc_provider}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${var.issuer_url}:sub": "system:serviceaccount:shorturl:shorturl",
            "${var.issuer_url}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Attach policies to the role as required
resource "aws_iam_role_policy_attachment" "example_policy_attachment" {
  role       = aws_iam_role.service_account_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"  # Example policy, adjust as needed
}
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "SecretsManagerAccessPolicy"
  description = "Policy to allow access to AWS Secrets Manager for database credentials."
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        "Resource": ["arn:aws:secretsmanager:us-east-1:848417356303:secret:prod/db/postgres*","arn:aws:secretsmanager:us-east-1:848417356303:secret:prod/googleOauth*"]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.service_account_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}


resource "aws_iam_role" "eks_secret_service_account_role" {
  name = "my-eks-service-account-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "${var.oidc_provider}"
        }
        Condition = {
          StringEquals = {
            "${var.issuer_url}:sub" = "system:serviceaccount:kube-system:external-secrets-sa",
            "${var.issuer_url}:aud"= "sts.amazonaws.com"
          }
        }
      },
    ]
  })
}
resource "aws_iam_policy" "secrets_manager_policy_sa" {
  name        = "secrets_manager_access"
  description = "Access to secrets in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
        ]
        Resource = "arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:*"
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "secrets_manager_attach" {
  role       = aws_iam_role.eks_secret_service_account_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy_sa.arn
}


resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = "EKSClusterAutoscalerPolicy"
  description = "IAM policy for EKS Cluster Autoscaler"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role" "cluster_autoscaler_role" {
  name = "EKSClusterAutoscalerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "${var.oidc_provider}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.issuer_url}:sub":"system:serviceaccount:kube-system:cluster-autoscaler"
            "${var.issuer_url}:aud":"sts.amazonaws.com"
          }
        }
      }
    ]
  })
}


