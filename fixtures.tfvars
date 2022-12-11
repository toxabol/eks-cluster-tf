region                          = "eu-west-1"
environment                     = "test"
project_name                    = "upsale"
myip = "78.137.63.168/32"
//vpc var

vpc_name = "tf-dev-upsale"
vpc_cidr = "10.101.0.0/16"

# vpc_private_subnets  = ["10.101.1.0/24", "10.101.2.0/24", "10.101.3.0/24"]
# vpc_public_subnets   = ["10.101.4.0/24", "10.101.5.0/24", "10.101.6.0/24"]
# vpc_database_subnets = ["10.101.7.0/24", "10.101.8.0/24"]
# #vpc_elasticache_subnets =
vpc_enable_ipv6      = false

vpc_enable_nat_gateway         = true
vpc_use_single_nat_gateway     = true
vpc_use_one_nat_gateway_per_az = false

vpc_create_database_subnet_group = true

vpc_manage_default_route_table = true

vpc_enable_dns_hostnames = true
vpc_enable_dns_support   = true

# vpc_public_subnet_tags = {
#   Name = "vpc-terraform-public"
# }

vpc_tags = {
  Owner       = "Name"
  Environment = "vps-terraform"
}

vpc_vpc_tags = {
  Name = "vpc-terraform"
}



s3_logs_bucket_name = "logs-vpc-upsale"


s3_reserve_log_bucket = "reserve-s3-vpc-upsale-bucket"

eks_cluster_name = "dev-cluster"
eks_cluster_endpoint_private_access = true
eks_cluster_endpoint_public_access = false
eks_instance_types = ["t3.medium"]
eks_desired_size = 1
eks_max_size = 1
eks_min_size = 1

eks_default_instance_types = ["t3.medium"]


