# Run service container one-off command

This module sets up various resources to enable the running of a one-off command within an ECS Task container, as it would be used within a particular service.

The intersection of Task Definition and Service is important because although the Task defines the Docker image and therefore the operation, a Service is configured to run a particular Task with a particular set of network and security group settings.

Therefore we have chosen to drive the config of this feature by Service rather than Task. Besides the above reasons it also massively simplifies the configuration, requiring only two variables to invoke this module:

1. The ARN of the ECS Cluster in which to run
2. An `aws_ecs_service` resource - the service as which to act.

The command is exercised by [a Python script](../../scripts/run_service_container_one_off_command/run_command.py) and for details of the operation and arguemnts etc you should inspect that. In summary however, this script requires

This module also creates IAM policies to enable a standard user to operate the command, and an IAM group into which you may add users to gain the permissions needed.

The policy and the group will both be named `run-SERVICE_NAME-service-command` where SERVICE_NAME is the name of the service resource passed in to the module invocation. 
