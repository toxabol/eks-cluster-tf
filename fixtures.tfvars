region                          = "eu-west-1"
environment                     = "test"
project_name                    = "upsale"
myip = "78.137.62.225/32"


vpc_dev_name = "tf-dev-upsale"
vpc_dev_cidr = "10.101.0.0/16"


vpc_dev_enable_ipv6      = false

vpc_dev_enable_nat_gateway         = true
vpc_dev_use_single_nat_gateway     = true
vpc_dev_use_one_nat_gateway_per_az = false

vpc_dev_create_database_subnet_group = true

vpc_dev_manage_default_route_table = true

vpc_dev_enable_dns_hostnames = true
vpc_dev_enable_dns_support   = true


vpc_dev_tags = {
  Owner       = "Name"
  Environment = "vps-terraform-dev"
}

vpc_dev_vpc_tags = {
  Name = "vpc-dev-upsale-terraform"
}





vpc_prod_name = "tf-prod-upsale"
vpc_prod_cidr = "10.101.0.0/16"


vpc_prod_enable_ipv6      = false

vpc_prod_enable_nat_gateway         = true
vpc_prod_use_single_nat_gateway     = true
vpc_prod_use_one_nat_gateway_per_az = false

vpc_prod_create_database_subnet_group = true

vpc_prod_manage_default_route_table = true

vpc_prod_enable_dns_hostnames = true
vpc_prod_enable_dns_support   = true


vpc_prod_tags = {
  Owner       = "Name"
  Environment = "vps-terraform-prod"
}

vpc_prod_vpc_tags = {
  Name = "vpc-prod-upsale-terraform"
}



s3_logs_bucket_name = "logs-vpc-upsale"


s3_reserve_log_bucket = "reserve-s3-vpc-upsale-bucket"

eks_dev_cluster_name = "dev-cluster"
eks_dev_cluster_endpoint_private_access = true
eks_dev_cluster_endpoint_public_access = false
eks_dev_instance_types = ["t3.medium"]
eks_dev_desired_size = 1
eks_dev_max_size = 1
eks_dev_min_size = 1

eks_dev_default_instance_types = ["t3.medium"]


eks_prod_cluster_name = "dev-cluster"
eks_prod_cluster_endpoint_private_access = true
eks_prod_cluster_endpoint_public_access = false
eks_prod_instance_types = ["t3.medium"]
eks_prod_desired_size = 1
eks_prod_max_size = 1
eks_prod_min_size = 1

eks_prod_default_instance_types = ["t3.medium"]



