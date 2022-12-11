module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets = slice(local.subnets_cidr_list , 1, 4)
  
  private_subnets  = slice(local.subnets_cidr_list , 4, 7) 
  database_subnets = slice(local.subnets_cidr_list , 7, 10) 
  elasticache_subnets = slice(local.subnets_cidr_list, 10, 13)
  intra_subnets = slice(local.subnets_cidr_list, 13, 16)

  enable_ipv6      = var.vpc_enable_ipv6

  enable_nat_gateway     = var.vpc_enable_nat_gateway     //true
  single_nat_gateway     = var.vpc_use_single_nat_gateway //true
  one_nat_gateway_per_az = var.vpc_use_one_nat_gateway_per_az

  create_database_subnet_group = var.vpc_create_database_subnet_group
  create_elasticache_subnet_group = true

  manage_default_route_table = var.vpc_manage_default_route_table
  enable_dns_hostnames       = var.vpc_enable_dns_hostnames
  enable_dns_support         = var.vpc_enable_dns_support
  enable_dhcp_options = true



  elasticache_inbound_acl_rules = local.network_acls["elasticache_inbound"]
  elasticache_outbound_acl_rules = local.network_acls["elasticache_outbound"]
  database_inbound_acl_rules = local.network_acls["database_inbound"]
  database_outbound_acl_rules = local.network_acls["database_outbound"]
  intra_inbound_acl_rules = local.network_acls["infra_inbound"]
  intra_outbound_acl_rules = local.network_acls["infra_outbound"]
  private_inbound_acl_rules = local.network_acls["private_inbound"]
  private_outbound_acl_rules =local.network_acls["private_outbound"]
  public_inbound_acl_rules = local.network_acls["public_inbound"]
  public_outbound_acl_rules = local.network_acls["public_outbound"]

 
  public_dedicated_network_acl   = true
  private_dedicated_network_acl   = true
  database_dedicated_network_acl = true
  elasticache_dedicated_network_acl = true
  intra_dedicated_network_acl = true

  enable_flow_log           = true
  flow_log_destination_type = "s3"
  flow_log_destination_arn  = module.s3_bucket_logs_vpc.s3_bucket_arn
  #public_subnet_tags = var.vpc_public_subnet_tags

  tags = var.vpc_tags

  vpc_tags = var.vpc_vpc_tags
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
