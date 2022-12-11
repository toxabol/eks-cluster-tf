data "aws_eks_cluster_auth" "eks" {
	name = module.eks.cluster_name 
}


provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token = data.aws_eks_cluster_auth.eks.token

}


module "front_sg" {
  source      = "terraform-aws-modules/security-group/aws"
#   version     = "4.4.0"
  name        = "tf-public-front-sg"
  description = "ingress traffic from anywhere and ssh only from my ip(Tony)"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp" 
      description = "ssh port"
      cidr_blocks = var.myip
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = "-1" 
      description = "egress all"
      cidr_blocks = "0.0.0.0/0" 
    }
  ]
}





module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = var.eks_cluster_name
  cluster_endpoint_private_access = var.eks_cluster_endpoint_private_access
	cluster_endpoint_public_access = var.eks_cluster_endpoint_public_access
	cluster_version = "1.23"
  vpc_id = module.vpc.vpc_id
	subnet_ids = module.vpc.private_subnets
#  control_plane_subnet_ids = module.vpc.private_subnets
	control_plane_subnet_ids = module.vpc.intra_subnets

  enable_irsa = true
	create_kms_key = true
  cluster_encryption_config = {
    resources = ["secrets"]
  }
  kms_key_deletion_window_in_days = 7
  enable_kms_key_rotation         = true

  iam_role_additional_policies = {
    additional = aws_iam_policy.additional.arn
  }

cluster_addons = {
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

	eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = var.eks_default_instance_types

    attach_cluster_primary_security_group = false

  
  }

	eks_managed_node_groups = {
    # blue = {}
    eks_managed_nodes = {
      min_size     = var.eks_min_size
      max_size     = var.eks_max_size
      desired_size = var.eks_desired_size

      instance_types = var.eks_instance_types
      capacity_type  = "ON_DEMAND"
      labels = {
        Environment = "eks-managed-node"
      }

      tags = {
        Name = "eks-node"
      }


		}
	}

  create_aws_auth_configmap = false
  manage_aws_auth_configmap = false

    aws_auth_users = [
    {
      userarn  = data.aws_caller_identity.current.arn
      username = "Anton"
      groups   = ["system:masters"]
    },
    {
      userarn  = data.aws_caller_identity.current.arn
      username = "Anton"
      groups   = ["system:reader"]
    },
    {
      userarn  = module.iam_account.iam_user_arn
      username = module.iam_account.iam_user_name
      groups   = ["system:reader"]
    },
  ]

  aws_auth_accounts = [
    data.aws_caller_identity.current.id
  ]
}


data "aws_ami" "ami2" {
  most_recent = true
  owners      = ["amazon"]
  # amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"

  key_name           = "test_key"
  create_private_key = true

  tags = {
        Name = "test"
      }
}

resource "aws_instance" "staging" {

  key_name               = module.key_pair.key_pair_name                      
  instance_type          = "t3.nano"                   
  ami                    = data.aws_ami.ami2.id
  vpc_security_group_ids = [module.front_sg.security_group_id,module.eks.node_security_group_id]

  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true                        
  #
  root_block_device {
    volume_type           =  "gp2"                                   
    volume_size           = "8"                                    
    delete_on_termination = true                                
  }
  tags = {
        Name = "bastion"
      }

  user_data = <<-EOT
  #!/bin/bash
  yum install git -y
  curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.13/2022-10-31/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
  echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc

  EOT

}

output "main_ssh_key_id" {
  value = module.key_pair.private_key_openssh
  sensitive = true
}

resource "local_file" "private_key_openssh" {
    content  = module.key_pair.private_key_openssh
    directory_permission = "0777"
    file_permission = "0600"
    filename = "private_key.pem"
}



