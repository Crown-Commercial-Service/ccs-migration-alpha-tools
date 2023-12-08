# Retrieve these so we don't need to pass in for every module invocation
# as that would introduce a breaking change
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
