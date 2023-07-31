# ECR Repository Group

Resources allowing the creation of several ECR repositories.

It's been chosen to treat ECR repos in a plural sense because it allows us to simplify provision of IAM resources for use by deployment agents.

Multiple ECR repos can be created. For each repo we include:

* ECR Repository definition
* JSON describing an IAM policy which allows this repo's images to be pulled
* Managed IAM policy allowing the user to perform a `docker login` via the use of [the helper scripts](../../scripts/ecr_repository/README.md) and to push images to each of the repositories
* IAM user group with the permissions of that managed policy

## Caveat - Use once only!

Because this module can create several repos, its naming of secondary resources assumes there is only a single use of this module across your whole project. If used more than once, creation of IAM policies and groups will fail on the basis of duplicate names.
