# create EKS
# access EKS
# deploy k8s dashboard
# deploy apps
# deploy RDS
provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      aws_eks_cluster.eks_cluster.name,
      "--region",
      "us-east-1"
    ]
  }
}

# Create an OIDC provider for the EKS cluster
resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  url             = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  thumbprint_list = ["9451ad2b53c7f41fab22886cc07d482085336561"]
}
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role=aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "eks_service_policy_attachment" {
  role=aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}
resource "aws_security_group" "eks_cluster_rule" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]  # Adjust to your VPC CIDR
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Security group for the EKS Node Group
resource "aws_security_group" "eks_node_group_sg" {
  vpc_id = var.vpc_id

  # Allow inbound traffic on port 31336 from LB
  ingress {
    description      = "Allow traffic from LB on port 31336"
    from_port        = 31336
    to_port          = 31336
    protocol         = "tcp"
    security_groups  = [var.lb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.31"

  vpc_config {
    subnet_ids         = var.private_subnet_id  # Ensure this is a list
    security_group_ids = [aws_security_group.eks_cluster_rule.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy_attachment,
    aws_iam_role_policy_attachment.eks_service_policy_attachment
  ]
}

resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${var.cluster_name}-nodegroup-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_role_workerpolicy_attachment" {
  role = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "eks_node_role_ecrpolicy_attachment" {
  role = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "eks_node_role_cnipolicy_attachment" {
  role = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = var.private_subnet_id # Ensure this is a list

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 3
  }
  
  ami_type = "AL2_x86_64"
  instance_types = ["t3.medium"]
  remote_access {
    ec2_ssh_key = "ec2-deployer-key"
    source_security_group_ids = [var.bastion_sg]
  }
  # Add labels for node selection
  labels = {
    type = "applications"
    env  = "production"
  }
    # Linking the node group to the security group created for it
 
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_role_workerpolicy_attachment,
    aws_iam_role_policy_attachment.eks_node_role_ecrpolicy_attachment,
    aws_iam_role_policy_attachment.eks_node_role_cnipolicy_attachment
  ]
}
# Replace your kubernetes_config_map resource with these two:
# 1. Initial creation of aws-auth ConfigMap
resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.auth_cm_data

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.eks_node_group
  ]
}

# 2. Manage aws-auth ConfigMap data
resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.auth_cm_data

  force = true

  depends_on = [
    kubernetes_config_map_v1.aws_auth
  ]
}

# resource "kubernetes_config_map" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     mapRoles = yamlencode([
#       {
#         rolearn  = aws_iam_role.eks_nodegroup_role.arn
#         username = "system:node:{{EC2PrivateDNSName}}"
#         groups   = ["system:bootstrappers", "system:nodes"]
#       },
#       {
#         rolearn  = var.bastion_role
#         username = "bastion"
#         groups   = ["system:masters"]
#       },
#     #   {
#     #     rolearn  = aws_iam_role.eks_cluster_role.arn
#     #     username = "eks_admin"
#     #     groups   = ["system:masters"]  # This grants admin access, modify as necessary
#     #   },
#     #   {
#     #     rolearn  = var.admin_role_arn
#     #     username = "admin"
#     #     groups   = ["system:masters"]  # This grants admin access, modify as necessary
#     #   },
#       {
#         rolearn  = "arn:aws:iam::848417356303:role/terraform-20241030033148148400000001"
#         username = "terraform"
#         groups   = ["system:masters"]  # This grants admin access, modify as necessary
#       },
#     #   {
#     #     rolearn  = var.dev_role_arn
#     #     username = "developer"
#     #     groups   = ["view"]  # Restricted to viewing resources
#     #   }
#     ]),
#     mapUsers = yamlencode([
#       {
#         userarn  = "arn:aws:iam::848417356303:pragya"
#         username = "pragya"
#         groups   = ["system:masters"]
#       }
#     ])
#   }

#   depends_on = [
#     aws_eks_cluster.eks_cluster
#   ]
# }

# resource "kubernetes_cluster_role" "developer_role" {
#   metadata {
#     name = "dev_role"
#   }

#   rule {
#     api_groups = [""]
#     resources  = ["pods", "pods/log"]
#     verbs      = ["get", "list", "watch"]
#   }
# }

# resource "kubernetes_cluster_role_binding" "developer_role_binding" {
#   metadata {
#     name = "dev_role_binding"
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.developer_role.metadata[0].name
#   }

#   subject {
#     kind      = "User"
#     name      = "developer"
#     api_group = "rbac.authorization.k8s.io"
#   }
# }


resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "${var.cluster_name}-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "${aws_iam_openid_connect_provider.eks_oidc_provider.arn}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.issuer_url}:sub":"system:serviceaccount:kube-system:ebs-csi-controller-sa"
            "${local.issuer_url}:aud":"sts.amazonaws.com"
          }
        }
      }
    ]
  })
}



resource "aws_iam_role_policy_attachment" "attach_ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "ebs_csi_addon" {
  cluster_name                  = aws_eks_cluster.eks_cluster.name
  addon_name                    = "aws-ebs-csi-driver"
  resolve_conflicts             = "OVERWRITE"
  service_account_role_arn      = aws_iam_role.ebs_csi_driver_role.arn
  addon_version                 = "v1.36.0-eksbuild.1" # Check the latest version in AWS EKS Add-ons documentation
  configuration_values          = jsonencode({})
}
