data "aws_eks_cluster_auth" "eks_dev" {
	name = module.eks_dev.cluster_name 
  #kubernetes = provider.k8s_dev
  
  
}


provider "kubernetes" {
  host                   = module.eks_dev.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_dev.cluster_certificate_authority_data)
  token = data.aws_eks_cluster_auth.eks_dev.token
  # alias = "k8s_dev"
}

data "aws_eks_cluster_auth" "eks_prod" {
	name = module.eks_prod.cluster_name 
  # provider = kubernetes.k8s_prod
  
  
}


provider "kubernetes" {
  host                   = module.eks_dev.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_prod.cluster_certificate_authority_data)
  token = data.aws_eks_cluster_auth.eks_prod.token
  alias = "k8s_prod"
}


module "front_sg_dev" {
  source      = "terraform-aws-modules/security-group/aws"
#   version     = "4.4.0"
  name        = "tf-dev-public-front-sg"
  description = "ingress ssh only from my ip(Tony)"
  vpc_id      = module.vpc_dev.vpc_id

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


module "front_sg_prod" {
  source      = "terraform-aws-modules/security-group/aws"
#   version     = "4.4.0"
  name        = "tf-prod-public-front-sg"
  description = "ingress ssh only from my ip(Tony)"
  vpc_id      = module.vpc_prod.vpc_id

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





module "eks_dev" {
  source = "terraform-aws-modules/eks/aws"
  # version = "19.0.4"
  cluster_name                    = var.eks_dev_cluster_name
  cluster_endpoint_private_access = var.eks_dev_cluster_endpoint_private_access
	cluster_endpoint_public_access = var.eks_dev_cluster_endpoint_public_access
	cluster_version = "1.23"
  vpc_id = module.vpc_dev.vpc_id
	subnet_ids = module.vpc_dev.private_subnets
#  control_plane_subnet_ids = module.vpc_dev.private_subnets
	control_plane_subnet_ids = module.vpc_dev.intra_subnets

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
    instance_types = var.eks_dev_default_instance_types

    attach_cluster_primary_security_group = false

  
  }

	eks_managed_node_groups = {
    # blue = {}
    dev_eks_managed_nodes = {
      min_size     = var.eks_dev_min_size
      max_size     = var.eks_dev_max_size
      desired_size = var.eks_dev_desired_size

      instance_types = var.eks_dev_instance_types
      capacity_type  = "ON_DEMAND"
      labels = {
        Environment = "dev_eks-managed-node"
      }

      tags = {
        Name = "dev-eks-node"
        join("/", ["kubernetes.io/cluster", module.eks_dev.cluster_name]) = "owned"
      }


		}
	}




  aws_auth_accounts = [
    data.aws_caller_identity.current.id
  ]
}


# data "aws_ami" "ami2" {
#   most_recent = true
#   owners      = ["amazon"]
#   # amazon

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }











module "eks_prod" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = var.eks_prod_cluster_name
  cluster_endpoint_private_access = var.eks_prod_cluster_endpoint_private_access
	cluster_endpoint_public_access = var.eks_prod_cluster_endpoint_public_access
	cluster_version = "1.23"
  vpc_id = module.vpc_prod.vpc_id
	subnet_ids = module.vpc_prod.private_subnets
#  control_plane_subnet_ids = module.vpc_prod.private_subnets
	control_plane_subnet_ids = module.vpc_prod.intra_subnets

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
    instance_types = var.eks_prod_default_instance_types

    attach_cluster_primary_security_group = false

  
  }

	eks_managed_node_groups = {
    # blue = {}
    prod_eks_managed_nodes = {
      min_size     = var.eks_prod_min_size
      max_size     = var.eks_prod_max_size
      desired_size = var.eks_prod_desired_size

      instance_types = var.eks_prod_instance_types
      capacity_type  = "ON_DEMAND"
      labels = {
        Environment = "prod_eks-managed-node"
      }

      tags = {
        Name = "prod-eks-node"
        join("/", ["kubernetes.io/cluster", module.eks_prod.cluster_name]) = "owned"
      }


		}
	}




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





module "key_pair_dev" {
  source  = "terraform-aws-modules/key-pair/aws"

  key_name           = "tf-dev-created-user-key"
  create_private_key = true

  tags = {
        Name = "tf-dev-created-user-key"
      }
}
module "key_pair_prod" {
  source  = "terraform-aws-modules/key-pair/aws"

  key_name           = "tf-prod-created-user-key"
  create_private_key = true

  tags = {
        Name = "tf-prod-created-user-key"
      }
}

resource "aws_instance" "dev" {

  key_name               = module.key_pair_dev.key_pair_name                      
  instance_type          = "t3.nano"                   
  ami                    = data.aws_ami.ami2.id
  vpc_security_group_ids = [module.front_sg_dev.security_group_id,module.eks_dev.node_security_group_id]

  subnet_id                   = module.vpc_dev.public_subnets[0]
  associate_public_ip_address = true                        
  #
  root_block_device {
    volume_type           =  "gp2"                                   
    volume_size           = "8"                                    
    delete_on_termination = true                                
  }
  tags = {
        Name = "dev_bastion"
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



resource "aws_instance" "prod" {

  key_name               = module.key_pair_prod.key_pair_name                      
  instance_type          = "t3.nano"                   
  ami                    = data.aws_ami.ami2.id
  vpc_security_group_ids = [module.front_sg_prod.security_group_id,module.eks_prod.node_security_group_id]

  subnet_id                   = module.vpc_prod.public_subnets[0]
  associate_public_ip_address = true                        
  #
  root_block_device {
    volume_type           =  "gp2"                                   
    volume_size           = "8"                                    
    delete_on_termination = true                                
  }
  tags = {
        Name = "prod_bastion"
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

output "main_ssh_key_id_dev" {
  value = module.key_pair_dev.private_key_openssh
  sensitive = true
}

resource "local_file" "dev_private_key_openssh" {
    content  = module.key_pair_dev.private_key_openssh
    directory_permission = "0777"
    file_permission = "0600"
    filename = "dev_private_key.pem"
}
output "main_ssh_key_id_prod" {
  value = module.key_pair_prod.private_key_openssh
  sensitive = true
}

resource "local_file" "prod_private_key_openssh" {
    content  = module.key_pair_prod.private_key_openssh
    directory_permission = "0777"
    file_permission = "0600"
    filename = "prod_private_key.pem"
}



