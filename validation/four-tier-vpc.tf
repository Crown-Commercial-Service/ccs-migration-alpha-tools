module "four_tier_vpc" {
  source = "../modules/four-tier-vpc"

  aws_region = "eu-west-1"
  database_ports = [
    { db_type : "postgres", "port" : 5432 }
  ]
  eks_cluster_name = "test"
  resource_name_prefixes = {
    normal        = "CORE:DEMO"
    hyphens       = "CORE-DEMO"
    hyphens_lower = "core-demo"
  }
  vpc_cidr_block = "10.1.0.0/16"
}
