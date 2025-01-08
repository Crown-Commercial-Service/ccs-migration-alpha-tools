# Postgres Extract, Transform and Load (ETL)

This folder contains Terraform configuration for the ETL resources.
These resources are designed to extract data from an RDS instance, load it into an S3 bucket, then process it using Kubernetes jobs and AWS Step functions.

## ETL Workflow

**Extract**: `Source RDS -> ECS Task -> S3 Bucket (Extract)`
- Dumps data from the source RDS database in the source account using Extract ECS task
- The dump is compressed and stored in an S3 bucket

**Transform**: `S3 Bucket (Extract) -> Kubernetes Dispatcher -> Transform Job -> S3 Bucket (Load)`
- A Kubernetes dispatcher monitors the S3 bucket (via SQS) for new dump objects
- Another Kubernetes job loads the dump, applies SQL transformations (I.e. removing PII), and writes the cleaned dump back to a target S3 bucket.

**Load**: `S3 Bucket (Load) -> ECS Task -> Target RDS`
- The cleaned dump is restored into the target RDS database using Load ECS tasks.

## Modules

We have `extract` and `load` modules that contain Terraform code for extracting RDS data, ECS tasks, a Step Function for extraction and loading, S3 bucket definitions, IAM roles/policies for accessing S3, RDS, etc and shared variables across modules.

AWS Services: RDS for source and target databases, S3 for intermediate storage, ECS for running extraction and loading tasks and Step Functions for orchestration.

Kubernetes: Dispatcher to monitor S3 for changes and Jobs for data transformation

Jenkins: Orchestrates the pipeline by triggering Step Functions, monitoring jobs and logging execution. Please refer to the `ccs-jenkins-jobs` repo for the [Postgres ETL job](https://jenkins-eks.techopsdev.com/job/digitalmarketplace-1.5/job/postgres-etl/).

## Important Notes

#### IAM policies

1. ECR Repository Access: Grants access to the ECR repositories for different environments (Dev, SBX, Prod).

  ```terraform
  resources = [
      "arn:aws:ecr:${var.aws_region}:473251818902:repository/${var.migrator_name}",   # Dev
      "arn:aws:ecr:${var.aws_region}:473251818902:repository/${var.migrator_name}:*", # Dev
      "arn:aws:ecr:${var.aws_region}:665505400356:repository/${var.migrator_name}",   # SBX
      "arn:aws:ecr:${var.aws_region}:665505400356:repository/${var.migrator_name}:*", # SBX
      "arn:aws:ecr:${var.aws_region}:974531504241:repository/${var.migrator_name}",   # Prod
      "arn:aws:ecr:${var.aws_region}:974531504241:repository/${var.migrator_name}:*"  # Prod
    ]
  ```

2. ECS Exec actions: Allows ECS exec actions for managing ECS tasks.

  ```terraform
  actions = [
      "ssmmessages:OpenDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:CreateControlChannel"
    ]
  ```

#### Step Functions
Contains environment variables for container `pg_dump` within **Extract** ECS task.
- `DUMP_FILENAME` is the filename for the database dump.
- `EXECUTION_ID` is used to monitor the Kubernetes job in Postgres ETL Jenkins pipeline.
- `LOAD_ENVIRONMENT` is used to provide an indication of the S3 bucket name that is successfully uploaded to S3 from RDS.

```json
{
  "Name": "pg_dump",
  "Environment": [
    {
      "Name": "DUMP_FILENAME",
      "Value": "etl-dump"
    },
    {
      "Name": "EXECUTION_ID",
      "Value.$": "$$.Execution.Id"
    },
    {
      "Name": "LOAD_ENVIRONMENT",
      "Value.$": "$.LOAD_ENVIRONMENT"
    }
  ]
}
```

Contains environment variables for container `pg_restore` within **Load** ECS task.
- `LOAD_ENVIRONMENT` is the variable of the S3 bucket name that is successfully downloaded from S3 and load into RDS.

```json
{
  "Name": "pg_restore",
  "Environment": [
    {
      "Name": "LOAD_FILENAME",
      "Value.$": "$.LOAD_FILENAME"
    }
  ]
}
```

#### SQS Integration for ETL process

The SQS queues are used to watch the S3 bucket in the Extract environment. We only need it in the `extract` module. The main queue `postgres-etl-s3` receives messages about the data extraction events and a dead-letter queue `postgres-etl-s3-dlq` handles messages that cannot be processed successfully.
