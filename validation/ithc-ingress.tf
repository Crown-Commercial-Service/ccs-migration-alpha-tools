module "ithc_ingres" {
  source = "../modules/ithc-ingress-caution"

  database_subnet_az_ids = {
    "a" = "subnet-1234",
    "b" = "subnet-5678",
  }
  database_subnet_cidr_blocks = {
    "a" = "10.1.1.0/24",
    "b" = "10.1.2.0/24"
  }
  database_subnets_nacl_id                = "12345"
  db_bastion_instance_public_key          = "ssh-blah aaaaaa"
  db_bastion_instance_root_device_size_gb = 10
  db_bastion_instance_subnet_cidr_block   = "10.1.4.0/24"
  db_bastion_instance_subnet_id           = "subnet-12345"
  db_bastion_instance_type                = "t3.small"
  db_clients_security_group_ids = [
    "sg-1234",
    "sg-5678"
  ]
  ithc_operative_cidr_safelist = [
    "13.4.2.2/32"
  ]
  public_subnets_nacl_id = "nacl-1234"
  resource_name_prefixes = {
    normal        = "TEST:123",
    hyphens       = "TEST-123",
    hyphens_lower = "test-123",
  }
  vpc_cidr_block                           = "10.1.0.0/16"
  vpc_id                                   = "vpc-1234"
  vpc_scanner_instance_public_key          = "ssh-blah bbbbbb"
  vpc_scanner_instance_root_device_size_gb = 10
  vpc_scanner_instance_subnet_id           = "subnet-abcd"
  vpc_scanner_instance_type                = "t3.small"
}
