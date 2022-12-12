module "vpc_dev" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_dev_name
  cidr = var.vpc_dev_cidr

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets = slice(local.subnets_cidr_list_dev , 1, 4)
  
  private_subnets  = slice(local.subnets_cidr_list_dev , 4, 7) 
  database_subnets = slice(local.subnets_cidr_list_dev , 7, 10) 
  elasticache_subnets = slice(local.subnets_cidr_list_dev, 10, 13)
  intra_subnets = slice(local.subnets_cidr_list_dev, 13, 16)

  enable_ipv6      = var.vpc_dev_enable_ipv6

  enable_nat_gateway     = var.vpc_dev_enable_nat_gateway     //true
  single_nat_gateway     = var.vpc_dev_use_single_nat_gateway //true
  one_nat_gateway_per_az = var.vpc_dev_use_one_nat_gateway_per_az

  create_database_subnet_group = var.vpc_dev_create_database_subnet_group
  create_elasticache_subnet_group = true

  manage_default_route_table = var.vpc_dev_manage_default_route_table
  enable_dns_hostnames       = var.vpc_dev_enable_dns_hostnames
  enable_dns_support         = var.vpc_dev_enable_dns_support
  enable_dhcp_options = true



  elasticache_inbound_acl_rules = local.network_acls_dev["elasticache_inbound"]
  elasticache_outbound_acl_rules = local.network_acls_dev["elasticache_outbound"]
  database_inbound_acl_rules = local.network_acls_dev["database_inbound"]
  database_outbound_acl_rules = local.network_acls_dev["database_outbound"]
  intra_inbound_acl_rules = local.network_acls_dev["infra_inbound"]
  intra_outbound_acl_rules = local.network_acls_dev["infra_outbound"]
  private_inbound_acl_rules = local.network_acls_dev["private_inbound"]
  private_outbound_acl_rules =local.network_acls_dev["private_outbound"]
  public_inbound_acl_rules = local.network_acls_dev["public_inbound"]
  public_outbound_acl_rules = local.network_acls_dev["public_outbound"]

 
  public_dedicated_network_acl   = true
  private_dedicated_network_acl   = true
  database_dedicated_network_acl = true
  elasticache_dedicated_network_acl = true
  intra_dedicated_network_acl = true

  enable_flow_log           = true
  flow_log_destination_type = "s3"
  flow_log_destination_arn  = module.s3_bucket_logs_vpc.s3_bucket_arn
  #public_subnet_tags = var.vpc_dev_public_subnet_tags

  tags = var.vpc_dev_tags

  vpc_tags = var.vpc_dev_vpc_tags
}




module "vpc_prod" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_prod_name
  cidr = var.vpc_prod_cidr

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets = slice(local.subnets_cidr_list_prod , 1, 4)
  
  private_subnets  = slice(local.subnets_cidr_list_prod , 4, 7) 
  database_subnets = slice(local.subnets_cidr_list_prod , 7, 10) 
  elasticache_subnets = slice(local.subnets_cidr_list_prod, 10, 13)
  intra_subnets = slice(local.subnets_cidr_list_prod, 13, 16)

  enable_ipv6      = var.vpc_prod_enable_ipv6

  enable_nat_gateway     = var.vpc_prod_enable_nat_gateway     //true
  single_nat_gateway     = var.vpc_prod_use_single_nat_gateway //true
  one_nat_gateway_per_az = var.vpc_prod_use_one_nat_gateway_per_az

  create_database_subnet_group = var.vpc_prod_create_database_subnet_group
  create_elasticache_subnet_group = true

  manage_default_route_table = var.vpc_prod_manage_default_route_table
  enable_dns_hostnames       = var.vpc_prod_enable_dns_hostnames
  enable_dns_support         = var.vpc_prod_enable_dns_support
  enable_dhcp_options = true



  elasticache_inbound_acl_rules = local.network_acls_prod["elasticache_inbound"]
  elasticache_outbound_acl_rules = local.network_acls_prod["elasticache_outbound"]
  database_inbound_acl_rules = local.network_acls_prod["database_inbound"]
  database_outbound_acl_rules = local.network_acls_prod["database_outbound"]
  intra_inbound_acl_rules = local.network_acls_prod["infra_inbound"]
  intra_outbound_acl_rules = local.network_acls_prod["infra_outbound"]
  private_inbound_acl_rules = local.network_acls_prod["private_inbound"]
  private_outbound_acl_rules =local.network_acls_prod["private_outbound"]
  public_inbound_acl_rules = local.network_acls_prod["public_inbound"]
  public_outbound_acl_rules = local.network_acls_prod["public_outbound"]

 
  public_dedicated_network_acl   = true
  private_dedicated_network_acl   = true
  database_dedicated_network_acl = true
  elasticache_dedicated_network_acl = true
  intra_dedicated_network_acl = true

  enable_flow_log           = true
  flow_log_destination_type = "s3"
  flow_log_destination_arn  = module.s3_bucket_logs_vpc.s3_bucket_arn
  #public_subnet_tags = var.vpc_prod_public_subnet_tags

  tags = var.vpc_prod_tags

  vpc_tags = var.vpc_prod_vpc_tags
}



module "log_bucket_for_s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"

  bucket        = local.destination_bucket_name
  acl           = "log-delivery-write"
  force_destroy = true

  attach_elb_log_delivery_policy        = true
  attach_lb_log_delivery_policy         = true
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.objects.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  
  versioning = {
    status     = true
    mfa_delete = false # might be true
  }
}

resource "aws_kms_key" "objects" {
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}

data "aws_caller_identity" "current" {}
resource "aws_kms_key" "replica" {

  description             = "S3 bucket replication KMS key"
  deletion_window_in_days = 7
}
# S3 Bucket
module "s3_bucket_logs_vpc" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  
  depends_on = [
    module.log_bucket_for_s3
  ]

  bucket        = local.bucket_name
  policy        = data.aws_iam_policy_document.flow_log_s3.json

  force_destroy = true
  attach_elb_log_delivery_policy        = true
  attach_lb_log_delivery_policy         = true
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.objects.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  # tags = local.tags
  logging = {
    target_bucket = module.log_bucket_for_s3.s3_bucket_id
    target_prefix = "log/"
  }

  tags = {
            ReplicateMe = "Yes"
          }
  versioning = {
    status     = true
    mfa_delete = false # might be true
  }

  intelligent_tiering = {
    general = {
      status = "Enabled"
      filter = {
        prefix = "/"
        tags = {
          Environment = "dev"
        }
      }
      tiering = {
        ARCHIVE_ACCESS = {
          days = 90
        }
        DEEP_ARCHIVE_ACCESS = {
          days = 180
        }
      }
    }
  }


  replication_configuration = {
    role = aws_iam_role.replication.arn

    rules = [
      {
        id       = "kms-and-filter"
        status   = true
        priority = 10

        delete_marker_replication = false

        source_selection_criteria = {
          replica_modifications = {
            status = "Enabled"
          }
          sse_kms_encrypted_objects = {
            enabled = true
          }
        }

        filter = {
          prefix = "/"
          tags = {
            ReplicateMe = "Yes"
          }
        }

        destination = {
          bucket        = "arn:aws:s3:::${local.destination_bucket_name}"
          # bucket        = "arn:aws:s3:::log_bucket_for_s3"
          storage_class = "STANDARD"

          replica_kms_key_id = aws_kms_key.replica.arn
          account_id         = data.aws_caller_identity.current.account_id

          access_control_translation = {
            owner = "Destination"
          }

          replication_time = {
            status  = "Enabled"
            minutes = 15
          }

          metrics = {
            status  = "Enabled"
            minutes = 15
          }
        }
      }]
  }

}


data "aws_iam_policy_document" "flow_log_s3" {
  statement {
    sid = "AWSPutObjects3Logs"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:*"]
    }

    actions = ["s3:PutObject"]

    resources = ["arn:aws:s3:::${var.s3_logs_bucket_name}/*"]
  }
  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = ["arn:aws:s3:::${var.s3_logs_bucket_name}/AWSLogs/*"]
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = ["arn:aws:s3:::${var.s3_logs_bucket_name}"]
  }
}


module "iam_account" {
  source = "terraform-aws-modules/iam/aws//modules/iam-user"

  name          = "k8s-user"
  pgp_key = "keybase:senatororgana"
  password_reset_required = false
  
}

output "password" {
value=module.iam_account.keybase_password_decrypt_command
}

# module "iam_eks_role" {
#   source    = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
#   role_name = "my-app"

#   cluster_service_accounts = {
#     (random_pet.this.id) = ["default:my-app"]
#   }

#   tags = {
#     Name = "eks-role"
#   }

#   role_policy_arns = {
#     AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   }
# }
