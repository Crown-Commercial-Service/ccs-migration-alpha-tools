data "aws_vpc" "primary" {
  tags = {
    "PrimaryVPC" = "Yes"
  }
}
