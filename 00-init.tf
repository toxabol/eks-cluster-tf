provider "aws" {
  region = local.region
}

locals {
  region = var.region
  subnets_cidr_list = cidrsubnets(var.vpc_cidr, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8)
  global_tags = {
    Env        = var.environment
    Project    = var.project_name
    Managed_by = "Terraform"

  }
  bucket_name = var.s3_logs_bucket_name
  destination_bucket_name = var.s3_reserve_log_bucket





  network_acls = {
    # default_inbound = [
    #   {
    #     rule_number = 900
    #     rule_action = "allow"
    #     from_port   = 1024
    #     to_port     = 65535
    #     protocol    = "tcp"
    #     cidr_block  = "0.0.0.0/0"
    #   },
    # ]
    # default_outbound = [
    #   {
    #     rule_number = 900
    #     rule_action = "allow"
    #     from_port   = 32768
    #     to_port     = 65535
    #     protocol    = "tcp"
    #     cidr_block  = "0.0.0.0/0"
    #   },
    # ]
    public_inbound = [{
        rule_number = 100
        rule_action = "allow"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "tcp"
        cidr_block  = module.vpc.vpc_cidr_block
       },
      {
        rule_number = 200
        rule_action = "allow"
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_block  = var.myip
      },
      {
        rule_number = 300
        rule_action = "allow"
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 400
        rule_action = "allow"
        from_port   = "443"
        to_port     = "443"
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 9000
        rule_action = "deny"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "all"
        cidr_block  = "0.0.0.0/0"
       }
    ]
    public_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "tcp"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      {
        rule_number = 200
        rule_action = "allow"
        from_port   = "1024"
        to_port     = "65535"
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 300
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 400
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 500
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      # {
      #   rule_number = 140
      #   rule_action = "allow"
      #   icmp_code   = -1
      #   icmp_type   = 8
      #   protocol    = "icmp"
      #   cidr_block  = "10.0.0.0/22"
      # },
      {
        rule_number = 9000
        rule_action = "deny"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "all"
        cidr_block  = module.vpc.vpc_cidr_block
      }
    ]
    private_inbound = [{
        rule_number = 100
        rule_action = "allow"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "tcp"
        cidr_block  = module.vpc.vpc_cidr_block
       },
      {
        rule_number = 200
        rule_action = "allow"
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      {
        rule_number = 300
        rule_action = "allow"
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      {
        rule_number = 400
        rule_action = "allow"
        from_port   = "443"
        to_port     = "443"
        protocol    = "tcp"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      {
        rule_number = 9000
        rule_action = "deny"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "all"
        cidr_block  = module.vpc.vpc_cidr_block
       }
    ]
    private_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "tcp"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      {
        rule_number = 200
        rule_action = "allow"
        from_port   = "1024"
        to_port     = "65535"
        protocol    = "tcp"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      {
        rule_number = 300
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      {
        rule_number = 400
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      {
        rule_number = 500
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      # {
      #   rule_number = 140
      #   rule_action = "allow"
      #   icmp_code   = -1
      #   icmp_type   = 8
      #   protocol    = "icmp"
      #   cidr_block  = "10.0.0.0/22"
      # },
      {
        rule_number = 9000
        rule_action = "deny"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "all"
        cidr_block  = module.vpc.vpc_cidr_block
      }
    ]
    database_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = "3306"
        to_port     = "3306"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[0]
       },
      {
        rule_number = 101
        rule_action = "allow"
        from_port   = "3306"
        to_port     = "3306"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[1]
      },
      {
        rule_number = 102
        rule_action = "allow"
        from_port   = "3306"
        to_port     = "3306"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[2]
      },
      # {
      #   rule_number = 400
      #   rule_action = "allow"
      #   from_port   = "443"
      #   to_port     = "443"
      #   protocol    = "tcp"
      #   cidr_block  = module.vpc.vpc_cidr_block
      # },
      {
        rule_number = 9000
        rule_action = "deny"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "all"
        cidr_block  = module.vpc.vpc_cidr_block
       }
    ]
    database_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = "3306"
        to_port     = "3306"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[0]
       },
      {
        rule_number = 101
        rule_action = "allow"
        from_port   = "3306"
        to_port     = "3306"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[1]
      },
      {
        rule_number = 102
        rule_action = "allow"
        from_port   = "3306"
        to_port     = "3306"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[2]
      },
      # {
      #   rule_number = 400
      #   rule_action = "allow"
      #   from_port   = "443"
      #   to_port     = "443"
      #   protocol    = "tcp"
      #   cidr_block  = module.vpc.vpc_cidr_block
      # },
      {
        rule_number = 9000
        rule_action = "deny"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "all"
        cidr_block  = module.vpc.vpc_cidr_block
       }
    ]
    elasticache_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = "6379"
        to_port     = "6379"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[0]
       },
      {
        rule_number = 101
        rule_action = "allow"
        from_port   = "6379"
        to_port     = "6379"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[1]
      },
      {
        rule_number = 102
        rule_action = "allow"
        from_port   = "6379"
        to_port     = "6379"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[2]
      },
      {
        rule_number = 020
        rule_action = "allow"
        from_port   = "11211"
        to_port     = "11211"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[0]
       },
      {
        rule_number = 201
        rule_action = "allow"
        from_port   = "11211"
        to_port     = "11211"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[1]
      },
      {
        rule_number = 202
        rule_action = "allow"
        from_port   = "11211"
        to_port     = "11211"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[2]
      },
      # {
      #   rule_number = 400
      #   rule_action = "allow"
      #   from_port   = "443"
      #   to_port     = "443"
      #   protocol    = "tcp"
      #   cidr_block  = module.vpc.vpc_cidr_block
      # },
      {
        rule_number = 9000
        rule_action = "deny"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "all"
        cidr_block  = module.vpc.vpc_cidr_block
       }
    ]
    elasticache_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = "6379"
        to_port     = "6379"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[0]
       },
      {
        rule_number = 101
        rule_action = "allow"
        from_port   = "3306"
        to_port     = "3306"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[1]
      },
      {
        rule_number = 102
        rule_action = "allow"
        from_port   = "3306"
        to_port     = "3306"
        protocol    = "tcp"
        cidr_block  = module.vpc.private_subnets_cidr_blocks[2]
      },
      # {
      #   rule_number = 400
      #   rule_action = "allow"
      #   from_port   = "443"
      #   to_port     = "443"
      #   protocol    = "tcp"
      #   cidr_block  = module.vpc.vpc_cidr_block
      # },
      {
        rule_number = 9000
        rule_action = "deny"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "all"
        cidr_block  = module.vpc.vpc_cidr_block
       }
    ]
    infra_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "all"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      # {
      #   rule_number = 400
      #   rule_action = "allow"
      #   from_port   = "443"
      #   to_port     = "443"
      #   protocol    = "tcp"
      #   cidr_block  = module.vpc.vpc_cidr_block
      # },
      {
        rule_number = 9000
        rule_action = "deny"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "all"
        cidr_block  = module.vpc.vpc_cidr_block
       }
    ]
    infra_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "all"
        cidr_block  = module.vpc.vpc_cidr_block
      },
      # {
      #   rule_number = 400
      #   rule_action = "allow"
      #   from_port   = "443"
      #   to_port     = "443"
      #   protocol    = "tcp"
      #   cidr_block  = module.vpc.vpc_cidr_block
      # },
      {
        rule_number = 9000
        rule_action = "deny"
        from_port   = "0"
        to_port     = "65535"
        protocol    = "all"
        cidr_block  = module.vpc.vpc_cidr_block
       }
    ]
  }
}
