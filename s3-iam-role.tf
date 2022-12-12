resource "random_pet" "this" {
  length = 2
}

resource "aws_iam_role" "replication" {
  name = "s3-bucket-replication-${random_pet.this.id}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  name = "s3-bucket-replication-${random_pet.this.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${local.bucket_name}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${local.bucket_name}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.destination_bucket_name}/*"
    }
  ]
}
POLICY
}





module "aws_ebs_csi_driver_iam" "dev" {
  source                      = "github.com/andreswebs/terraform-aws-eks-ebs-csi-driver//modules/iam"
  cluster_oidc_provider       = module.eks.dev.cluster_oidc_issuer_url
  k8s_namespace               = "kube-system"
  iam_role_name               = "ebs-csi-controller-${module.eks.dev.cluster_name}"
}
module "aws_ebs_csi_driver_iam" "prod" {
  source                      = "github.com/andreswebs/terraform-aws-eks-ebs-csi-driver//modules/iam"
  cluster_oidc_provider       = module.eks.prod.cluster_oidc_issuer_url
  k8s_namespace               = "kube-system"
  iam_role_name               = "ebs-csi-controller-${module.eks.prod.cluster_name}"
}

module "iam_assumable_role_custom_trust_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.5.4"

  create_role = true

  role_name = "AWSTestRoleEKSReadOnly"

  trusted_role_arns = [
    data.aws_caller_identity.current.arn,
    module.iam_account.iam_user_arn
  ]
  custom_role_trust_policy = data.aws_iam_policy_document.custom_trust_policy.json
  custom_role_policy_arns  =[aws_iam_policy.eks_read_only.arn, "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"] #["arn:aws:iam::aws:policy/AmazonCognitoReadOnly"]
}

data "aws_iam_policy_document" "custom_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_iam_policy" "eks_read_only" {
  name = "AWSTestPolicyEKSReadOnly"

  policy = <<POLICY
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "eks:DescribeNodegroup",
               "eks:ListNodegroups",
               "eks:DescribeCluster",
               "eks:ListClusters",
               "eks:AccessKubernetesApi",
               "ssm:GetParameter",
               "eks:ListUpdates",
               "eks:ListFargateProfiles"
           ],
           "Resource": "*"
       }
   ]
}
POLICY
}

resource "aws_iam_policy" "ebs_access" {
  name = "AmazonEKS_EBS_CSI_Driver_Policy_tf"

  policy = file("policy_json/example-iam-policy.json") 

}




resource "aws_iam_policy_attachment" "dev_ebs_access" {
  name       = "AmazonEKS_EBS_CSI_Driver_Policy_tf-atachment"
  roles      = [aws_iam_role.ebs_trust_role.name]
  policy_arn = aws_iam_policy.ebs_access.arn
}
resource "aws_iam_role" "dev_ebs_trust_role" {
  name = "AmazonEKS_EBS_CSI_DriverRole_tf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect: "Allow",
        Principal: {
          Federated: "arn:aws:iam::${data.aws_caller_identity.current.id}:oidc-provider/${module.eks.dev.oidc_provider}"
        },
        Action: "sts:AssumeRoleWithWebIdentity",
        Condition: {
          StringEquals: {
            "${module.eks.dev.oidc_provider}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
      }
    ]
  })
}




resource "aws_iam_policy_attachment" "prod_ebs_access" {
  name       = "AmazonEKS_EBS_CSI_Driver_Policy_tf-atachment"
  roles      = [aws_iam_role.prod_ebs_trust_role.name]
  policy_arn = aws_iam_policy.ebs_access.arn
}
resource "aws_iam_role" "prod_ebs_trust_role" {
  name = "AmazonEKS_EBS_CSI_DriverRole_tf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect: "Allow",
        Principal: {
          Federated: "arn:aws:iam::${data.aws_caller_identity.current.id}:oidc-provider/${module.eks.prod.oidc_provider}"
        },
        Action: "sts:AssumeRoleWithWebIdentity",
        Condition: {
          StringEquals: {
            "${module.eks.prod.oidc_provider}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
      }
    ]
  })
}

output "oidc_dev_provider" {
  value = module.eks.dev.oidc_provider
  
}
output "oidc_prod_provider" {
  value = module.eks.prod.oidc_provider
  
}
# output "oidc_2_url" {
#   value = module.eks.cluster_oidc_issuer_url
  
# }

resource "aws_iam_policy_attachment" "replication" {
  name       = "s3-bucket-replication-${random_pet.this.id}"
  roles      = [aws_iam_role.replication.name]
  policy_arn = aws_iam_policy.replication.arn
}


















resource "aws_iam_role" "eks-cluster" {
  name = "eks-cluster-assume-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

# data "tls_certificate" "eks" {
#   url = module.eks.cluster_oidc_issuer_url
# }

# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   url             = module.eks.cluster_oidc_issuer_url
# }


data "aws_iam_policy_document" "dev_aws_load_balancer_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.dev.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [module.eks.dev.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "dev_aws_load_balancer_controller" {
  assume_role_policy = data.aws_iam_policy_document.dev_aws_load_balancer_controller_assume_role_policy.json
  name               = "aws-load-balancer-controller"
}
resource "aws_iam_role" "prod_aws_load_balancer_controller" {
  assume_role_policy = data.aws_iam_policy_document.prod_aws_load_balancer_controller_assume_role_policy.json
  name               = "aws-load-balancer-controller"
}

data "aws_iam_policy_document" "prod_aws_load_balancer_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.prod.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [module.eks.prod.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "dev_aws_load_balancer_controller" {
  assume_role_policy = data.aws_iam_policy_document.dev_aws_load_balancer_controller_assume_role_policy.json
  name               = "aws-load-balancer-controller"
}
resource "aws_iam_role" "prod_aws_load_balancer_controller" {
  assume_role_policy = data.aws_iam_policy_document.prod_aws_load_balancer_controller_assume_role_policy.json
  name               = "aws-load-balancer-controller"
}


resource "aws_iam_policy" "aws_load_balancer_controller" {
  policy = file("policy_json/AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerController"
}

resource "aws_iam_role_policy_attachment" "dev_aws_load_balancer_controller_attach" {
  role       = aws_iam_role.dev_aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

output "dev_aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.dev_aws_load_balancer_controller.arn
}

resource "aws_iam_role_policy_attachment" "prod_aws_load_balancer_controller_attach" {
  role       = aws_iam_role.prod_aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

output "prod_aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.prod_aws_load_balancer_controller.arn
}


resource "aws_iam_policy" "additional" {
  name = "tf-dev-cluster-additional"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

module "ebs_csi_irsa_role" "dev" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = join("-", [module.eks.dev.cluster_name, "eks-ebs_csi_irsa_role"])
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.dev.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
        Name = join("-", [module.eks.dev.cluster_name, "eks-ebs_csi_irsa_role"])
      }
}

module "load_balancer_controller_irsa_role" "dev" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = join("-", [module.eks.dev.cluster_name, "eks-load_balancer_controller_irsa_role"])
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.dev.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
        Name = join("-", [module.eks.dev.cluster_name, "eks-load_balancer_controller_irsa_role"])
      }
}







module "ebs_csi_irsa_role" "prod" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = join("-", [module.eks.prod.cluster_name, "eks-ebs_csi_irsa_role"])
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.prod.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
        Name = join("-", [module.eks.prod.cluster_name, "eks-ebs_csi_irsa_role"])
      }
}

module "load_balancer_controller_irsa_role" "prod" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = join("-", [module.eks.prod.cluster_name, "eks-load_balancer_controller_irsa_role"])
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.prod.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
        Name = join("-", [module.eks.prod.cluster_name, "eks-load_balancer_controller_irsa_role"])
      }
}