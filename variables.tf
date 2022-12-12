# variable "environment" {
#   description = "environment name"
# }

# variable "project_name" {
#   description = "The project name. Used for tags, resources names, etc "
# }


variable "region" {
  type        = string
  description = "AWS region"
} //used
variable "environment" {
  description = "environment name"
}

variable "project_name" {
  description = "The project name. Used for tags, resources names, etc "
}

// VPC VARIABLES
variable "vpc_dev_name" {
  type        = string
  description = "The name of the VPC specified as argument to this module"
}
variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
}
# variable "vpc_dev_private_subnets" {
#   type        = list(string)
#   description = "List of IDs of private subnets (module docs, actually list of CIDR)"
# }
# variable "vpc_dev_public_subnets" {
#   type        = list(string)
#   description = "List of IDs of public subnets (module docs, actually list of CIDR)"
# }
# variable "vpc_dev_database_subnets" {
#   type        = list(string)
#   description = "List of IDs of database subnets(module docs, actually list of CIDR)"
# }
variable "vpc_dev_enable_ipv6" {
  type        = bool
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block."
}
variable "vpc_dev_enable_nat_gateway" {
  type        = bool
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
}
variable "vpc_dev_use_single_nat_gateway" {
  type        = bool
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
}
variable "vpc_dev_use_one_nat_gateway_per_az" {
  type        = bool
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires var.azs to be set, and the number of public_subnets created to be greater than or equal to the number of availability zones specified in var.azs. (module docs)"
}
variable "vpc_dev_create_database_subnet_group" {
  type        = bool
  description = "Controls if database subnet group should be created (n.b. database_subnets must also be set)"
}
variable "vpc_dev_manage_default_route_table" {
  type        = bool
  description = "Should be true to manage default route table"
}
variable "vpc_dev_enable_dns_hostnames" {
  type        = bool
  description = "Should be true to enable DNS hostnames in the VPC"
}
variable "vpc_dev_enable_dns_support" {
  type        = bool
  description = "Should be true to enable DNS support in the VPC"
}
# variable "vpc_dev_public_subnet_tags" {
#   type        = map(string)
#   description = "vpc tags for public subnets"
# }
variable "vpc_dev_tags" {
  type        = map(string)
  description = "tags for vpc"
}
variable "vpc_dev_vpc_tags" {
  type        = map(string)
  description = "tags for vpc"
}















variable "vpc_prod_name" {
  type        = string
  description = "The name of the VPC specified as argument to this module"
}
variable "vpc_prod_cidr" {
  type        = string
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
}
# variable "vpc_prod_private_subnets" {
#   type        = list(string)
#   description = "List of IDs of private subnets (module docs, actually list of CIDR)"
# }
# variable "vpc_prod_public_subnets" {
#   type        = list(string)
#   description = "List of IDs of public subnets (module docs, actually list of CIDR)"
# }
# variable "vpc_prod_database_subnets" {
#   type        = list(string)
#   description = "List of IDs of database subnets(module docs, actually list of CIDR)"
# }
variable "vpc_prod_enable_ipv6" {
  type        = bool
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block."
}
variable "vpc_prod_enable_nat_gateway" {
  type        = bool
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
}
variable "vpc_prod_use_single_nat_gateway" {
  type        = bool
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
}
variable "vpc_prod_use_one_nat_gateway_per_az" {
  type        = bool
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires var.azs to be set, and the number of public_subnets created to be greater than or equal to the number of availability zones specified in var.azs. (module docs)"
}
variable "vpc_prod_create_database_subnet_group" {
  type        = bool
  description = "Controls if database subnet group should be created (n.b. database_subnets must also be set)"
}
variable "vpc_prod_manage_default_route_table" {
  type        = bool
  description = "Should be true to manage default route table"
}
variable "vpc_prod_enable_dns_hostnames" {
  type        = bool
  description = "Should be true to enable DNS hostnames in the VPC"
}
variable "vpc_prod_enable_dns_support" {
  type        = bool
  description = "Should be true to enable DNS support in the VPC"
}
# variable "vpc_prod_public_subnet_tags" {
#   type        = map(string)
#   description = "vpc tags for public subnets"
# }
variable "vpc_prod_tags" {
  type        = map(string)
  description = "tags for vpc"
}
variable "vpc_prod_vpc_tags" {
  type        = map(string)
  description = "tags for vpc"
}

variable "s3_logs_bucket_name" {
  type        = string
  description = "The name of the s3 bucket collecting logs"
}

variable "s3_reserve_log_bucket" {
  type        = string
  description = "The name of the s3 bucket collecting logs"
}

variable "eks_dev_cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "eks_dev_cluster_endpoint_private_access" {
  type        = bool
  description = "Should be true if you want be able to access private endpoint in cluster"
}
variable "eks_dev_cluster_endpoint_public_access" {
  type        = bool
  description = "Should be true if you want be able to access public endpoint in cluster"
}


variable "eks_dev_default_instance_types" {
  type        = list(string)
  description = "List of instance types used in created EKS cluster by default"
}
variable "eks_dev_instance_types" {
  type        = list(string)
  description = "List of instance types used in created EKS cluster(specified)"
}

variable "eks_dev_min_size" {
  description = "Minimum number of instances/nodes"
  type        = number
  default     = 0
}

variable "eks_dev_max_size" {
  description = "Max number of instances/nodes"
  type        = number
  default     = 0
}
variable "eks_dev_desired_size" {
  description = "Desired number of instances/nodes"
  type        = number
  default     = 0
}
















variable "eks_prod_cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "eks_prod_cluster_endpoint_private_access" {
  type        = bool
  description = "Should be true if you want be able to access private endpoint in cluster"
}
variable "eks_prod_cluster_endpoint_public_access" {
  type        = bool
  description = "Should be true if you want be able to access public endpoint in cluster"
}


variable "eks_prod_default_instance_types" {
  type        = list(string)
  description = "List of instance types used in created EKS cluster by default"
}
variable "eks_prod_instance_types" {
  type        = list(string)
  description = "List of instance types used in created EKS cluster(specified)"
}

variable "eks_prod_min_size" {
  description = "Minimum number of instances/nodes"
  type        = number
  default     = 0
}

variable "eks_prod_max_size" {
  description = "Max number of instances/nodes"
  type        = number
  default     = 0
}
variable "eks_prod_desired_size" {
  description = "Desired number of instances/nodes"
  type        = number
  default     = 0
}



variable "myip" {
  type        = string
  description = "Source ip for ssh in security groups/nACL in public networks"
}
