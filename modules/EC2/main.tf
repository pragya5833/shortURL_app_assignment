resource "tls_private_key" "privatekey" {
  algorithm = "RSA"
  rsa_bits  = 2048
#   lifecycle {
#     prevent_destroy = true
#   }
}

resource "aws_key_pair" "bastionkey" {
  key_name   = "ec2-deployer-key"
  public_key = tls_private_key.privatekey.public_key_openssh
#   lifecycle {
#     prevent_destroy = true
#   }
}


resource "local_file" "private_key" {
  sensitive_content = tls_private_key.privatekey.private_key_pem
  filename          = "${path.module}/ec2-deployer-key.pem"
  file_permission   = "0600"
}
resource "aws_iam_role" "bastion_trust_relationship" {
  assume_role_policy = jsonencode({
    Version="2012-10-17"
    Statement=[{
        Effect="Allow"
        Action="sts:AssumeRole"
        Principal={Service="ec2.amazonaws.com"}
    }]
  })
#   lifecycle {
#     prevent_destroy = true
#   }
}
resource "aws_iam_role_policy" "bastion_eks_policy" {
  name = "bastion_eks_policy"
  role = aws_iam_role.bastion_trust_relationship.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*",
          "sts:GetCallerIdentity",
          "iam:ListRoles"
        ]
        Resource = "*"
      },{
        Effect = "Allow"
        Action = [
          "*"
        ]
        Resource = "*"
      }
    ]
  })
#   lifecycle {
#     prevent_destroy = true
#   }
}
resource "aws_iam_role_policy_attachment" "bastionEKSPolicy" {
  role = aws_iam_role.bastion_trust_relationship.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   lifecycle {
#     prevent_destroy = true
#   }
    
}
resource "aws_iam_role_policy_attachment" "bastionECRPolicy" {
  role = aws_iam_role.bastion_trust_relationship.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   lifecycle {
#     prevent_destroy = true
#   }
}

resource "aws_iam_instance_profile" "bastion_profile" {
  role = aws_iam_role.bastion_trust_relationship.name
#   lifecycle {
#     prevent_destroy = true
#   }
}
resource "aws_iam_role_policy_attachment" "bastion_admin_policy" {
  role       = aws_iam_role.bastion_trust_relationship.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"  # Since it's running Terraform
#   lifecycle {
#     prevent_destroy = true
#   }
}
resource "aws_instance" "bastion_host" {
  ami           = "ami-0c2b8ca1dad447f8a"  # Example AMI ID for Amazon Linux 2 in us-east-1
  instance_type = "t2.medium"              # Adjust size as necessary
  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
  associate_public_ip_address = true  # Assign a public IP address
  key_name               = aws_key_pair.bastionkey.key_name
  vpc_security_group_ids = [aws_security_group.bastion_security_group.id]
  subnet_id              = var.public_subnet_id     # Specify the subnet
#   lifecycle {
#     prevent_destroy = true
#   }

user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y git unzip jq

    # Install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/

    # Create .kube directory
    mkdir -p /home/ec2-user/.kube
    chown ec2-user:ec2-user /home/ec2-user/.kube

    # Update kubeconfig
    aws eks update-kubeconfig --name ${var.cluster_name} --region us-east-1
    cp /root/.kube/config /home/ec2-user/.kube/config
    chown ec2-user:ec2-user /home/ec2-user/.kube/config
  EOF

}
resource "aws_security_group" "bastion_security_group" {
  vpc_id = var.vpc_id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    # cidr_blocks = [var.allowed_cidrs]
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
#   lifecycle {
#     prevent_destroy = true
#   }
}
