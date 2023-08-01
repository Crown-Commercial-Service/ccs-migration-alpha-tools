# Run update service

This module sets up various resources to enable the running of [the update_service script](../../scripts/update_service/update_service.py) which is a tool to control the scaling and redeployment of individual ECS services. 

For details of operatin you should inspect the script itself.

This module creates an IAM policy and group which enable a standard user to operate the command.

The policy and the group will both be named `run-update-service`.
