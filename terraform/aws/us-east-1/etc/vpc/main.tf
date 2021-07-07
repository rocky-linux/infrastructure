module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  # Fail safe for now, flip to true or delete the following line to deploy this configuration.
  create_vpc = false
  
  name = "rocky-etc-us-east-1"
  cidr = "10.16.240.0/20"

  # IPv6, set to true and Amazon will provision a /56 for this VPC
  enable_ipv6 = false

  azs = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]

  # Subnets
  ## A private subnet includes a route to get to the internet via a NAT Gateway, an intra subnet does not.
  ## More info: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest#private-versus-intra-subnets
  public_subnets = ["10.16.240.0/24", "10.16.241.0/24", "10.16.242.0/24", "10.16.243.0/24"]
  private_subnets = ["10.16.244.0/24", "10.16.245.0/24", "10.16.246.0/24", "10.16.247.0/24"]
  intra_subnets = ["10.16.248.0/24", "10.16.249.0/24", "10.16.250.0/24", "10.16.251.0/24"]

  ## We might want these, we might not. If not, I would make the private subnets /23s instead and fill the space that way.
  database_subnets = ["10.16.252.0/26", "10.16.252.64/26", "10.16.252.128/26", "10.16.252.192/26"]
  elasticache_subnets = ["10.16.253.0/26", "10.16.253.64/26", "10.16.253.128/26", "10.16.253.192/26"]
  redshift_subnets = ["10.16.254.0/26", "10.16.254.64/26", "10.16.254.128/26", "10.16.254.192/26"]

  ## There is one /24 remaining at 10.16.255.0/24 for any other usage we might need.

  # VPC Options
  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  
  # NAT Gateway: 1 per AZ
  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true

  # NAT Gateway: 1 per subnet
  # enable_nat_gateway = true
  # single_nat_gateway = false
  # one_nat_gateway_per_az = false

  # NAT Gateway: 1 per VPC
  # enable_nat_gateway = true
  # single_nat_gateway = true
  # one_nat_gateway_per_az = false

  # DHCP
  enable_dhcp_options              = true
  dhcp_options_domain_name         = "etc.us-east-1.aws.rockylinux.org"
  dhcp_options_domain_name_servers = ["10.16.244.6", "10.16.245.6", "10.16.246.6", "10.16.247.6"]

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = [{}]
  default_security_group_egress  = [{}]

  # Product-specific configs:
  ## Database, flip these 3 vars to true to make RDS instances available publicly.
  create_database_subnet_group = false
  create_database_subnet_route_table     = false
  create_database_internet_gateway_route = false

  ## Elasticache, flip these to true to have AWS manage the subnet and routing for EC
  create_elasticache_subnet_group = false
  create_elasticache_subnet_route_table = false

  ## Redshift, flip these to true to have AWS manage the subnet and routing for Redshift
  create_redshift_subnet_group = false
  create_redshift_subnet_route_table = false
}
