output "subnets" {
  description = "Properties relating to the four subnets"
  value       = {
    "public" = {
      "ids" : [for s in aws_subnet.public : s.id]
    },
    "web" = {
      "ids" : [for s in aws_subnet.web : s.id]
    },
    "application" = {
      "ids" : [for s in aws_subnet.application : s.id]
    },
    "database" = {
      "ids" : [for s in aws_subnet.database : s.id]
    }
  }
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}
