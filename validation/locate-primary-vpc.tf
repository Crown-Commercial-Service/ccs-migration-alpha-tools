module "locate_primary_vpc" {
  source = "../modules/locate_primary_vpc"

  /* This module is utilised to look up VPC and peering attributes in a project's
     infrastructure code.

     There are no arguments / parameters.
  */
}
