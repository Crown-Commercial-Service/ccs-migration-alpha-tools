# DMP ECS Task Definition

Collection of resources to specify a Task Definition in Elastic Container Service. This version differs slightly from [the original ECS Task Definition resource group](../ecs-fargate-task-definition) in ways which are designed to make it easier to adopt within the already mature DMP Terraform environments.

Includes (non-exhaustive):

* Task Definition
* Task Role and JSON document describing the IAM permission to pass the Task Role

There is a lot of commonality with the original ECS Task Definition resource group but the decision was taken _not_ to refactor them into a single module because it would introduce a lot of tightly-structured logic into a construct which (tbh) already stretches the idea of clear declarative code a little bit.

So we're bolting this module alongside that and when (if?) DMP is ever shut down, it can safely be removed.
